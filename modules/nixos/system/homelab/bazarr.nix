{
  config,
  lib,
  ...
}:
let
  cfg = config.trf.homelab;
in
{
  config = lib.mkIf (cfg.enable && config.services.bazarr.enable) {
    services.bazarr = {
      group = "media";
      openFirewall = cfg.openFirewall;
    };
  };
}
