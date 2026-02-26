{
  config,
  lib,
  ...
}:
let
  cfg = config.trf.homelab;
in
{
  config = lib.mkIf (cfg.enable && config.services.plex.enable) {
    services.plex = {
      group = "media";
      openFirewall = cfg.openFirewall;
    };
  };
}
