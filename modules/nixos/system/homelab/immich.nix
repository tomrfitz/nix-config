{
  config,
  lib,
  ...
}:
let
  cfg = config.trf.homelab;
in
{
  config = lib.mkIf (cfg.enable && config.services.immich.enable) {
    services.immich = {
      group = "media";
      mediaLocation = "${cfg.paths.mediaRoot}/photos";
      openFirewall = cfg.openFirewall;
    };
  };
}
