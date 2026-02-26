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
      dataDir = "${cfg.paths.configRoot}/radarr";
      openFirewall = cfg.openFirewall;
    };
  };
}
