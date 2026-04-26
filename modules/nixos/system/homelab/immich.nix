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
      host = "0.0.0.0";
      group = "media";
      mediaLocation = "${cfg.paths.mediaRoot}/photos";
      inherit (cfg) openFirewall;
    };
  };
}
