{
  config,
  lib,
  ...
}:
let
  cfg = config.trf.homelab;
in
{
  config = lib.mkIf (cfg.enable && config.services.radarr.enable) {
    services.radarr = {
      group = "media";
      openFirewall = cfg.openFirewall;
      settings.auth = {
        enabled = true;
        method = "Forms";
        required = "Enabled";
      };
    };
  };
}
