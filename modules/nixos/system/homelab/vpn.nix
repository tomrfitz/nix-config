# Mullvad VPN for homelab services.
#
# Routes all traffic through Mullvad by default. Services listed in
# excludedServices bypass the VPN via PID-based split tunneling.
# All inter-service communication uses localhost regardless of VPN status.
#
# Tailscale coexistence: A separate nftables table (mullvad-ts) marks
# Tailscale CGNAT traffic (100.64.0.0/10) with Mullvad's split-tunnel
# fwmarks so it bypasses the VPN firewall. This survives Mullvad reconnects
# because Mullvad only manages its own `inet mullvad` table.
# Ref: https://mullvad.net/en/help/split-tunneling-with-linux-advanced
# Ref: https://theorangeone.net/posts/tailscale-mullvad/
{
  config,
  lib,
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
    # Priority constraints from Mullvad docs: must be between -200 and 0.
    # Mullvad's prerouting is at -199; our -100 runs after it.
    # WSL's kernel lacks nft_fib — disable the NixOS firewall whose nftables
    # rules depend on it. WSL is behind Windows' firewall anyway.
    networking.firewall.enable = lib.mkIf isWSL false;

    networking.nftables = {
      enable = true;
      tables.mullvad-ts = {
        family = "inet";
        content = ''
          chain outgoing {
            type route hook output priority 0; policy accept;
            # tailscaled marks its own traffic with 0x80000
            meta mark 0x80000 ct mark set 0x00000f41 meta mark set 0x6d6f6c65
            ip daddr 100.64.0.0/10 ct mark set 0x00000f41 meta mark set 0x6d6f6c65
          }

          chain incoming {
            type filter hook prerouting priority -100; policy accept;
            ip saddr 100.64.0.0/10 ct mark set 0x00000f41 meta mark set 0x6d6f6c65
          }
        '';
      };
    };

    systemd.services =
      let
        mullvad = "${config.services.mullvad-vpn.package}/bin/mullvad";
      in
      {
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
          ${mullvad} dns set default --block-ads --block-trackers --block-malware
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
