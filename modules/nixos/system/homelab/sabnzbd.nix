{
  config,
  lib,
  ...
}:
let
  cfg = config.trf.homelab;
in
{
  config = lib.mkIf (cfg.enable && config.services.sabnzbd.enable) {
    services.sabnzbd = {
      group = "media";
      openFirewall = cfg.openFirewall;
      settings.misc.host = "0.0.0.0";
    };
  };
}
