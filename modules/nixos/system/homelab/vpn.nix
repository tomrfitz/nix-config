# Mullvad VPN for homelab services.
#
# Routes all traffic through Mullvad by default. Services listed in
# excludedServices bypass the VPN via PID-based split tunneling.
# All inter-service communication uses localhost regardless of VPN status.
#
# Tailscale coexistence: A separate nftables table (mullvad-ts) marks
# Tailscale CGNAT traffic (100.64.0.0/10) with Mullvad's split-tunnel
# fwmarks so it bypasses the VPN firewall. A policy routing rule sends
# CGNAT replies to Tailscale's routing table before Mullvad captures them.
# Both survive Mullvad reconnects — Mullvad only manages its own tables/rules.
# Ref: https://mullvad.net/en/help/split-tunneling-with-linux-advanced
# Ref: https://theorangeone.net/posts/tailscale-mullvad/
{
  config,
  lib,
  pkgs,
  isWSL,
  ...
}:
let
  cfg = config.trf.homelab;
  vpn = cfg.vpn;
in
{
  options.trf.homelab.vpn = {
    enable = lib.mkEnableOption "Mullvad VPN for homelab";

    excludedServices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "systemd service names whose internet traffic bypasses the VPN via split tunneling.";
    };
  };

  config = lib.mkIf (cfg.enable && vpn.enable) {
    sops.secrets."mullvad/account" = {
      restartUnits = [ "mullvad-daemon.service" ];
    };

    services.mullvad-vpn = {
      enable = true;
      enableExcludeWrapper = true;
    };

    services.resolved.enable = true;

    # ── Tailscale coexistence via nftables ──────────────────────────────
    # Mullvad's lockdown firewall (inet mullvad) drops all non-tunnel traffic.
    # `mullvad lan set allow` does NOT cover Tailscale's 100.64.0.0/10 CGNAT
    # range (ref: https://github.com/mullvad/mullvadvpn-app/issues/6086).
    #
    # Fix: mark Tailscale traffic with Mullvad's split-tunnel conntrack mark
    # (0x00000f41) and fwmark (0x6d6f6c65). Mullvad's firewall recognises
    # these marks and allows the traffic through.
    #
    # Priority: outgoing uses filter hook at -1 (just before Mullvad's
    # priority 0 output filter). A route hook doesn't work — ct mark set
    # there isn't visible to Mullvad's filter at the same priority.
    # Mullvad's prerouting is at -199; our incoming -100 runs after it.
    # WSL's kernel lacks nft_fib — disable the NixOS firewall whose nftables
    # rules depend on it. WSL is behind Windows' firewall anyway.
    networking.firewall.enable = lib.mkIf isWSL false;

    networking.nftables = {
      enable = true;
      tables.mullvad-ts = {
        family = "inet";
        content = ''
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
        '';
      };
    };

    systemd.services =
      let
        mullvad = "${config.services.mullvad-vpn.package}/bin/mullvad";
      in
      {
        # ── Policy routing for Tailscale replies ──────────────────────
        # The nftables marks handle Mullvad's *firewall* (accept/drop),
        # but policy routing runs before netfilter output hooks. Without
        # this, reply packets (e.g. SYN-ACK for inbound SSH) hit Mullvad's
        # routing table (rule 5209) and exit via wg0-mullvad instead of
        # tailscale0. This rule sends CGNAT-destined traffic to Tailscale's
        # routing table first.
        tailscale-route-fix = {
          description = "Add policy route for Tailscale CGNAT replies";
          after = [
            "tailscaled.service"
            "mullvad-daemon.service"
          ];
          wants = [ "tailscaled.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = "${lib.getExe' pkgs.iproute2 "ip"} rule add to 100.64.0.0/10 lookup 52 priority 5205";
            ExecStop = "${lib.getExe' pkgs.iproute2 "ip"} rule del to 100.64.0.0/10 lookup 52 priority 5205";
          };
        };

        mullvad-daemon.postStart = ''
          # Wait for daemon readiness
          while ! ${mullvad} status &>/dev/null; do sleep 1; done

          # Login if not already authenticated
          if ! ${mullvad} account get &>/dev/null; then
            ACCOUNT="$(cat ${config.sops.secrets."mullvad/account".path})"
            ${mullvad} account login "$ACCOUNT"
          fi

          ${mullvad} auto-connect set on
          ${mullvad} lockdown-mode set on
          # Mullvad's own DNS (100.64.0.7) is unreachable despite the tunnel
          # working — cause unknown. Route DNS through tunnel to Cloudflare instead.
          ${mullvad} dns set custom 1.1.1.1 1.0.0.1
        '';
      }
      # Register excluded services' PIDs with Mullvad split tunnel after they start
      // lib.listToAttrs (
        map (svc: {
          name = svc;
          value = {
            after = [ "mullvad-daemon.service" ];
            wants = [ "mullvad-daemon.service" ];
            serviceConfig.ExecStartPost = [
              "+${mullvad} split-tunnel add $MAINPID"
            ];
          };
        }) vpn.excludedServices
      );
  };
}
