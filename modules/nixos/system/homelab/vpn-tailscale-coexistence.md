# Running Mullvad with Tailscale on NixOS (lockdown mode + inbound access)

## Context

I run a NixOS homelab (NixOS-WSL) where Mullvad with lockdown mode protects download traffic, and Tailscale provides remote SSH access via MagicDNS. This is a common homelab pattern: VPN kill-switch for untrusted traffic, mesh VPN for management.

Getting both to coexist required solving three distinct problems. Documenting the full path here since existing guides only cover the first one.

## Environment

- NixOS 24.11 (unstable channel) on WSL2
- Mullvad 2025.14+ (CLI syntax changes noted below)
- Tailscale with MagicDNS
- systemd-resolved for split DNS
- Lockdown mode enabled

## Problem 1: Mullvad lockdown blocks Tailscale traffic

**Symptoms:** With lockdown mode on, inbound SSH over Tailscale hangs at TCP connect. `tailscale ping` works (userspace ICMP) but `ssh <host>` never completes. Outbound Tailscale control plane traffic is also blocked.

**Root cause:** Mullvad's `inet mullvad` nftables table drops all traffic not routed through the Mullvad tunnel. Tailscale's `tailscale0` interface and its CGNAT range (100.64.0.0/10) are not recognized as tunnel traffic.

**What didn't work:**

- `mullvad lan set allow` — does not cover 100.64.0.0/10 (CGNAT, not LAN). Confirmed by [#6086](https://github.com/mullvad/mullvadvpn-app/issues/6086).
- `mullvad split-tunnel add $(pgrep tailscaled)` — PID-based split tunneling only affects **outbound** traffic from the excluded process. Inbound SSH connections arriving on `tailscale0` are still dropped.
- Adding tailscaled to excluded services — same limitation, outbound only.

**Solution:** Create a separate nftables table (`inet mullvad-ts`) that marks Tailscale traffic with Mullvad's split-tunnel fwmarks. Mullvad's firewall recognizes these marks and allows the traffic through. Since this is a separate table, Mullvad can't wipe it during reconnects (it only manages its own `inet mullvad` table).

The mark values come from [Mullvad's split-tunneling docs](https://mullvad.net/en/help/split-tunneling-with-linux-advanced):

- Conntrack mark: `0x00000f41`
- Fwmark: `0x6d6f6c65`

Prior art: [TheOrangeOne](https://theorangeone.net/posts/tailscale-mullvad/), [rakhesh](https://rakhesh.com/linux-bsd/mullvad-and-tailscale-coexisting-or-hello-nftables/), [shervinsahba/mullvad-tailscale-nft](https://github.com/shervinsahba/mullvad-tailscale-nft).

## Problem 2: CIDR-based nftables rules break Mullvad's DNS

**Symptoms:** With the commonly-suggested nftables rule `ip daddr 100.64.0.0/10 ct mark set 0x00000f41 meta mark set 0x6d6f6c65`, SSH over Tailscale works but DNS resolution for non-Tailscale domains fails completely.

**Root cause:** Mullvad's tunnel DNS resolver is at **100.64.0.7**, which falls within the Tailscale CGNAT range (100.64.0.0/10). The CIDR-based rule marks Mullvad's own DNS traffic for split-tunnel bypass, routing it outside the tunnel where it's unreachable.

This is a subtle conflict: both Mullvad and Tailscale use addresses in 100.64.0.0/10 for completely different purposes. The blog posts that pioneered the CIDR approach may not have hit this because Mullvad's DNS address allocation could vary by relay or configuration.

**Solution:** Match on interface instead of CIDR. Use `iifname "tailscale0"` for inbound traffic and conntrack mark propagation for reply packets:

```nft
table inet mullvad-ts {
  chain outgoing {
    type route hook output priority 0; policy accept;
    # tailscaled marks its own traffic (control plane, DERP relays)
    meta mark 0x80000 ct mark set 0x00000f41 meta mark set 0x6d6f6c65
    # Reply packets for established Tailscale connections (e.g. SSH responses)
    ct mark 0x00000f41 meta mark set 0x6d6f6c65
  }

  chain incoming {
    type filter hook prerouting priority -100; policy accept;
    iifname "tailscale0" ct mark set 0x00000f41 meta mark set 0x6d6f6c65
  }
}
```

This avoids the CIDR overlap entirely:

- Inbound Tailscale traffic is identified by interface, not address
- Outbound replies use conntrack to propagate the mark from the inbound leg
- tailscaled's own outbound traffic is identified by its fwmark (`0x80000`)
- Mullvad's DNS traffic to 100.64.0.7 is unaffected (it arrives on `wg0-mullvad`, not `tailscale0`)

## Problem 3: Mullvad's DNS resolver (100.64.0.7) unreachable

**Symptoms:** Even with the interface-based nftables rules correctly in place, `resolvectl query github.com` times out. `ping 100.64.0.7` shows 100% packet loss. Meanwhile, the tunnel itself works fine — `ping 10.64.0.1` (tunnel gateway) responds, and `curl http://1.1.1.1` through the tunnel succeeds.

**Diagnosis:**

- `ip route get 100.64.0.7` → correctly routed through `wg0-mullvad` via Mullvad's routing table
- `ip rule list` → policy routing is correct (no fwmark → Mullvad table → wg0-mullvad)
- `mullvad status` → Connected, relay responding
- General traffic through tunnel works, only DNS to 100.64.0.7 fails

**Status:** Root cause unknown. The tunnel carries traffic, routing is correct, but 100.64.0.7 specifically doesn't respond. This may be relay-specific, WSL-specific, or a Mullvad-side issue.

**Workaround:** Use custom DNS routed through the Mullvad tunnel:

```bash
mullvad dns set custom 1.1.1.1 1.0.0.1
```

This routes DNS queries to Cloudflare through the Mullvad tunnel (still encrypted, still uses the tunnel's exit IP). Confirmed working. The tradeoff is losing Mullvad's built-in ad/tracker/malware DNS blocking, which can be replaced with a self-hosted solution (Pi-hole, NextDNS, etc.).

## Additional notes

**WSL kernel limitation:** Enabling `networking.nftables` on NixOS also activates the NixOS firewall's nftables rules, which use `fib` expressions. WSL's Microsoft-built kernel lacks the `nft_fib` module, causing the `nftables.service` to fail. Fix: disable the NixOS firewall on WSL (`networking.firewall.enable = false`) — WSL sits behind Windows Defender Firewall anyway. The custom `mullvad-ts` table only uses basic nftables features (marks, conntrack, interface matching) that WSL's kernel supports.

**Mullvad CLI 2025.14+ changes:** `mullvad split-tunnel set state on` was removed (split tunneling is always available). `mullvad split-tunnel pid add` became `mullvad split-tunnel add`.

**DNS routing with systemd-resolved:** When Mullvad is connected, its `wg0-mullvad` interface registers DNS with a `~.` catch-all domain, so resolved routes all general queries through it. Tailscale registers `*.ts.net` on `tailscale0` for MagicDNS. Don't set global nameservers to MagicDNS (100.100.100.100) — it can't resolve non-Tailscale domains. Use a public resolver as global fallback; Mullvad's per-link DNS takes precedence when connected.

## Full NixOS module

Working NixOS module for the complete setup: [`modules/nixos/system/homelab/vpn.nix`](https://github.com/tomrfitz/nix-config/blob/lean/modules/nixos/system/homelab/vpn.nix)

## Potential upstream improvements

1. **Mullvad:** `mullvad lan set allow` could support CGNAT ranges (100.64.0.0/10), or offer an `--include-cgnat` flag. This would eliminate the need for custom nftables tables when running alongside Tailscale. (Ref: [#6086](https://github.com/mullvad/mullvadvpn-app/issues/6086))
2. **Mullvad:** Interface-based exclusions (`mullvad split-tunnel exclude-interface tailscale0`) covering both inbound and outbound traffic would be a cleaner solution than PID-based exclusion for VPN coexistence.
3. **Mullvad:** Investigate why the tunnel DNS resolver (100.64.0.7) is unreachable in some configurations despite the tunnel functioning correctly.
