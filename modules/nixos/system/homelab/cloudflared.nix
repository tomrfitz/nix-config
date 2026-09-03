# Cloudflare Tunnel — exposes homelab services outside eduroam. Routes are
# managed in the Cloudflare Zero Trust dashboard; the tunnel token is a sops
# secret handed to the unit as a systemd credential, so the service itself
# runs unprivileged (DynamicUser).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.trf.homelab;
in
{
  options.trf.homelab.cloudflared.enable = lib.mkEnableOption "Cloudflare Tunnel";

  config = lib.mkIf (cfg.enable && cfg.cloudflared.enable) {
    sops.secrets."cloudflared/tunnel-token" = { };

    # Unit name is referenced by vpn.excludedServices — keep it.
    systemd.services.cloudflared-tunnel = {
      description = "Cloudflare Tunnel";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        DynamicUser = true;
        StateDirectory = "cloudflared";
        LoadCredential = "token:${config.sops.secrets."cloudflared/tunnel-token".path}";
        Restart = "on-failure";
        RestartSec = 5;
      };
      environment.HOME = "/var/lib/cloudflared";
      script = ''
        exec ${pkgs.cloudflared}/bin/cloudflared tunnel run --token-file "$CREDENTIALS_DIRECTORY/token"
      '';
    };
  };
}
