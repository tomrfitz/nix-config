# Jellyseerr uses DynamicUser — no user/group options to set.
{
  config,
  lib,
  ...
}:
let
  cfg = config.trf.homelab;
in
{
  config = lib.mkIf (cfg.enable && config.services.jellyseerr.enable) {
    services.jellyseerr = {
      openFirewall = cfg.openFirewall;
    };
  };
}
