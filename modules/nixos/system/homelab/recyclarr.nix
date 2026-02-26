{
  config,
  lib,
  ...
}:
let
  cfg = config.trf.homelab;
in
{
  config = lib.mkIf (cfg.enable && config.services.recyclarr.enable) {
    services.recyclarr = {
      schedule = "daily";
    };
  };
}
