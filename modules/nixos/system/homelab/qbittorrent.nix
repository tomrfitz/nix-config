{
  config,
  lib,
  ...
}:
let
  cfg = config.trf.homelab;
in
{
  config = lib.mkIf (cfg.enable && config.services.qbittorrent.enable) {
    services.qbittorrent = {
      group = "media";
      openFirewall = cfg.openFirewall;
    };
  };
}
