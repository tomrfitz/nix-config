{
  config,
  lib,
  ...
}:
let
  cfg = config.trf.homelab;
in
{
  config = lib.mkIf (cfg.enable && config.services.jellyfin.enable) {
    services.jellyfin = {
      group = "media";
      openFirewall = cfg.openFirewall;
    };
  };
}
