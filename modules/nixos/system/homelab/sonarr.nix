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
      openFirewall = cfg.openFirewall;
    };
  };
}
