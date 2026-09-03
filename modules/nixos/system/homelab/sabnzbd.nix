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
      inherit (cfg) openFirewall;
      # Merge the existing stateful sabnzbd.ini on every start instead of
      # regenerating it read-only from declared settings (stateVersion >=
      # 26.05 default) — UI-managed servers/credentials/categories survive;
      # declared keys below still override.
      allowConfigWrite = true;
      settings.misc = {
        host = "0.0.0.0";
        inet_exposure = "api+web (auth needed)";
        enable_https = true;
      };
    };
  };
}
