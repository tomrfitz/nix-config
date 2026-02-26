# Prowlarr uses DynamicUser — no user/group options to set.
{
  config,
  lib,
  ...
}:
let
  cfg = config.trf.homelab;
in
{
  config = lib.mkIf (cfg.enable && config.services.prowlarr.enable) {
    services.prowlarr = {
      openFirewall = cfg.openFirewall;
      settings.auth = {
        enabled = true;
        method = "Forms";
        required = "Enabled";
      };
    };
  };
}
