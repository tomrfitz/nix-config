# Tautulli is monitoring-only — no media group needed.
{
  config,
  lib,
  ...
}:
let
  cfg = config.trf.homelab;
in
{
  config = lib.mkIf (cfg.enable && config.services.tautulli.enable) {
    services.tautulli = {
      openFirewall = cfg.openFirewall;
    };
  };
}
