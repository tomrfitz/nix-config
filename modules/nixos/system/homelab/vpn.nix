# Mullvad VPN for homelab services.
#
# Routes all traffic through Mullvad by default. Services listed in
# excludedServices bypass the VPN via PID-based split tunneling.
# All inter-service communication uses localhost regardless of VPN status.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.trf.homelab;
  vpn = cfg.vpn;
in
{
  options.trf.homelab.vpn = {
    enable = lib.mkEnableOption "Mullvad VPN for homelab";

    accountOpRef = lib.mkOption {
      type = lib.types.str;
      description = "1Password op:// reference for the Mullvad account number.";
    };

    excludedServices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "systemd service names whose internet traffic bypasses the VPN via split tunneling.";
    };
  };

  config = lib.mkIf (cfg.enable && vpn.enable) {
    services.mullvad-vpn = {
      enable = true;
      enableExcludeWrapper = true;
    };

    services.resolved.enable = true;

    systemd.services =
      let
        mullvad = "${config.services.mullvad-vpn.package}/bin/mullvad";
        op = "${pkgs._1password-cli}/bin/op";
      in
      {
        mullvad-daemon = {
          serviceConfig.LoadCredential = "op-sa-token:/etc/op/service-account-token";
          postStart = ''
            # Wait for daemon readiness
            while ! ${mullvad} status &>/dev/null; do sleep 1; done

            # Login if not already authenticated
            if ! ${mullvad} account get &>/dev/null; then
              export OP_SERVICE_ACCOUNT_TOKEN="$(cat "$CREDENTIALS_DIRECTORY/op-sa-token")"
              ACCOUNT="$(${op} read "${vpn.accountOpRef}")"
              ${mullvad} account login "$ACCOUNT"
            fi

            ${mullvad} auto-connect set on
            ${mullvad} lockdown-mode set on
            ${mullvad} dns set default --block-ads --block-trackers --block-malware
            ${mullvad} split-tunnel set state on
          '';
        };
      }
      # Register excluded services' PIDs with Mullvad split tunnel after they start
      // lib.listToAttrs (
        map (svc: {
          name = svc;
          value = {
            after = [ "mullvad-daemon.service" ];
            wants = [ "mullvad-daemon.service" ];
            serviceConfig.ExecStartPost = [
              "+${mullvad} split-tunnel pid add $MAINPID"
            ];
          };
        }) vpn.excludedServices
      );
  };
}
