# Wraps calibre-server (library management) + calibre-web (browsing UI).
# calibre-server port overridden to 8180 to avoid SABnzbd's default 8080.
{
  config,
  lib,
  ...
}:
let
  cfg = config.trf.homelab;
in
{
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf config.services.calibre-server.enable {
        services.calibre-server = {
          group = "media";
          port = 8180;
          libraries = [ cfg.paths.booksRoot ];
          openFirewall = cfg.openFirewall;
        };
      })
      (lib.mkIf config.services.calibre-web.enable {
        services.calibre-web = {
          group = "media";
          openFirewall = cfg.openFirewall;
          options.calibreLibrary = cfg.paths.booksRoot;
        };
      })
    ]
  );
}
