{
  config,
  lib,
  ...
}:
let
  cfg = config.trf.homelab;
in
{
  config = lib.mkIf (cfg.enable && config.services.lidarr.enable) {
    services.lidarr = {
      group = "media";
      openFirewall = cfg.openFirewall;
    };
  };
}
