# Running Mullvad with Tailscale on NixOS (lockdown mode + inbound access)

## Context

I run a NixOS homelab (NixOS-WSL) where Mullvad with lockdown mode protects download traffic, and Tailscale provides remote SSH access via MagicDNS. This is a common homelab pattern: VPN kill-switch for untrusted traffic, mesh VPN for management.

Getting both to coexist required solving four distinct problems. Documenting the full path here since existing guides only cover the first one.

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
- `mullvad split-tunnel add $(pgrep tailscaled)` — PID-based split tunneling only affects **outbound** traffic from the excluded process. Inbound SSH connections arriving on `tailscale0` are still dropped. However, PID-based split tunneling *is* needed for a separate problem — see Problem 3½ (bootstrap ordering).

**Solution:** Create a separate nftables table (`inet mullvad-ts`) that marks Tailscale traffic with Mullvad's split-tunnel fwmarks. Mullvad's firewall recognizes these marks and allows the traffic through. Since this is a separate table, Mullvad can't wipe it during reconnects (it only manages its own `inet mullvad` table).

The mark values come from [Mullvad's split-tunneling docs](https://mullvad.net/en/help/split-tunneling-with-linux-advanced):

- Conntrack mark: `0x00000f41`
- Fwmark: `0x6d6f6c65`

Prior art: [TheOrangeOne](https://theorangeone.net/posts/tailscale-mullvad/), [rakhesh](https://rakhesh.com/linux-bsd/mullvad-and-tailscale-coexisting-or-hello-nftables/), [shervinsahba/mullvad-tailscale-nft](https://github.com/shervinsahba/mullvad-tailscale-nft).

## Problem 2: CIDR-based nftables rules break Mullvad's DNS (inbound chain)

**Symptoms:** With the commonly-suggested nftables rule `ip daddr 100.64.0.0/10 ct mark set 0x00000f41 meta mark set 0x6d6f6c65` in a **prerouting** chain, SSH over Tailscale works but DNS resolution for non-Tailscale domains fails completely.

**Root cause:** Mullvad's tunnel DNS resolver is at **100.64.0.7**, which falls within the Tailscale CGNAT range (100.64.0.0/10). A CIDR-based prerouting rule marks Mullvad's own DNS traffic for split-tunnel bypass, routing it outside the tunnel where it's unreachable.

This is a subtle conflict: both Mullvad and Tailscale use addresses in 100.64.0.0/10 for completely different purposes. The blog posts that pioneered the CIDR approach may not have hit this because Mullvad's DNS address allocation could vary by relay or configuration.

**Solution:** Match on interface instead of CIDR for the **incoming** (prerouting) chain. Use `iifname "tailscale0"` — this avoids the CIDR overlap because Mullvad's DNS arrives on `wg0-mullvad`, not `tailscale0`.

Note: using `ip daddr 100.64.0.0/10` in the **outgoing** chain is safe — it only matches locally-originated packets destined for Tailscale peers (e.g. SSH to another machine). Mullvad's DNS traffic to 100.64.0.7 goes through the tunnel and never matches the output chain's CIDR rule because it's already routed to `wg0-mullvad` by Mullvad's routing table.

## Problem 3: Hook type matters — `route` vs `filter`

**Symptoms:** With the outgoing chain using `type route hook output priority 0`, outbound SSH to Tailscale peers (e.g. `ssh 100.106.13.30`) gets "connection refused". The ct mark is being set (verified with nft counters) but Mullvad's output filter still drops the packets.

**Root cause:** Mullvad's output chain uses `type filter hook output priority filter` (priority 0). A `route` hook and a `filter` hook at the same priority are different hook types — the ct mark set in the route hook is not visible to Mullvad's filter hook when they run at the same priority. The packets get marked but Mullvad's filter evaluates without seeing the mark and rejects them (Mullvad's output chain ends with `reject`, which the SSH client reports as "connection refused" rather than a timeout).

**Solution:** Use `type filter hook output priority -1` instead of `type route`. Priority -1 ensures our chain runs just before Mullvad's priority 0 filter, and using the same hook type (`filter`) guarantees mark visibility.

```nft
table inet mullvad-ts {
  chain outgoing {
    type filter hook output priority -1; policy accept;
    # tailscaled marks its own traffic (control plane, DERP relays)
    meta mark 0x80000 ct mark set 0x00000f41 meta mark set 0x6d6f6c65
    # New outbound connections to Tailscale CGNAT (e.g. SSH to peers)
    ip daddr 100.64.0.0/10 ct mark set 0x00000f41 meta mark set 0x6d6f6c65
    # Reply packets for established Tailscale connections
    ct mark 0x00000f41 meta mark set 0x6d6f6c65
  }

  chain incoming {
    type filter hook prerouting priority -100; policy accept;
    iifname "tailscale0" ct mark set 0x00000f41 meta mark set 0x6d6f6c65
  }
}
```

How the rules work together:

- **Inbound:** Tailscale traffic identified by interface (`tailscale0`), not address — avoids the DNS overlap
- **Outbound (tailscaled):** tailscaled's own traffic identified by its fwmark (`0x80000`) — covers control plane, DERP relays
- **Outbound (new connections):** SSH and other new connections to Tailscale peers identified by CIDR (`100.64.0.0/10`) — safe in the output chain
- **Outbound (replies):** Conntrack propagates the mark from the inbound leg for established connections
- **Mullvad DNS:** Traffic to 100.64.0.7 is unaffected — it arrives on `wg0-mullvad` (not `tailscale0`) and is routed through the tunnel (not matched by the output CIDR rule)

## Problem 3½: Bootstrap ordering — tailscaled can't auth after restart

**Symptoms:** After a WSL restart, tailscaled starts but can't reach the control plane (`controlplane.tailscale.com`). Logs show "connection refused" and "network is unreachable" for bootstrap DNS servers. Tailscale stays in a logged-out state until Mullvad is manually disconnected.

**Root cause:** The nftables rules from Problem 3 handle steady-state traffic, but they rely on either `tailscale0` existing (incoming chain) or tailscaled setting fwmark `0x80000` on its packets (outgoing chain). During initial authentication — before the tunnel is established — tailscaled's control plane traffic may not carry the fwmark, and `tailscale0` doesn't exist yet. Mullvad's lockdown blocks these unrecognized packets.

**Solution:** Add tailscaled to Mullvad's PID-based split tunnel via `vpn.excludedServices`. This registers tailscaled's PID with `mullvad split-tunnel add $MAINPID` on startup, exempting its outbound traffic from lockdown. The systemd service ordering (`after = [ "mullvad-daemon.service" ]`) ensures Mullvad is ready to accept the split-tunnel registration.

PID-based and nftables approaches are complementary:

- **PID split-tunnel** covers tailscaled's own outbound traffic (control plane auth, DERP relay connections) — works from first boot
- **nftables** covers inbound traffic on `tailscale0`, outbound connections to peers (SSH), and reply packets — works once the tunnel is established

## Problem 4: Mullvad's DNS resolver (100.64.0.7) unreachable

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

Working NixOS module for the complete setup: [`modules/nixos/system/homelab/vpn.nix`](https://github.com/tomrfitz/nix-config/blob/main/modules/nixos/system/homelab/vpn.nix)

## Potential upstream improvements

1. **Mullvad:** `mullvad lan set allow` could support CGNAT ranges (100.64.0.0/10), or offer an `--include-cgnat` flag. This would eliminate the need for custom nftables tables when running alongside Tailscale. (Ref: [#6086](https://github.com/mullvad/mullvadvpn-app/issues/6086))
2. **Mullvad:** Interface-based exclusions (`mullvad split-tunnel exclude-interface tailscale0`) covering both inbound and outbound traffic would be a cleaner solution than PID-based exclusion for VPN coexistence.
3. **Mullvad:** Investigate why the tunnel DNS resolver (100.64.0.7) is unreachable in some configurations despite the tunnel functioning correctly.
