{
  config,
  lib,
  ...
}:
let
  cfg = config.trf.homelab;
in
{
  config = lib.mkIf (cfg.enable && config.services.sonarr.enable) {
    services.sonarr = {
      group = "media";
      inherit (cfg) openFirewall;
      settings.auth = {
        enabled = true;
        method = "Forms";
        required = "Enabled";
      };
    };
  };
}
