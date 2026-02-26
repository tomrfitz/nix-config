{
  hostName,
  user,
  lib,
  ...
}:
{
  system.stateVersion = "26.05";
  networking.hostName = hostName;

  wsl = {
    enable = true;
    defaultUser = user;
    interop = {
      register = true;
      includePath = true;
    };
  };

  trf.wsl.gpu.enable = true;

  services.ollama.enable = true;

  trf.homelab = {
    enable = true;
    bookshelf.enable = true;
    paths = {
      mediaRoot = lib.mkDefault "/mnt/z/data/media";
      usenetRoot = lib.mkDefault "/mnt/k/data/usenet";
      torrentsRoot = lib.mkDefault "/mnt/k/data/torrents";
      booksRoot = lib.mkDefault "/mnt/z/data/media/books";
    };
  };

  # Homelab services — enable individually, conventions layered by homelab modules.
  services = {
    bazarr.enable = true;
    # REVISIT(upstream): re-enable calibre; ref: qmake build failure (calibre pkg) + flask-limiter (calibre-web); checked: 2026-02-26
    # calibre-server.enable = true;
    # calibre-web.enable = true;
    lidarr.enable = true;
    plex.enable = true;
    radarr.enable = true;
    # readarr replaced by bookshelf (Readarr fork with Hardcover metadata)
    # readarr.enable = true;
    sabnzbd.enable = true;
    sonarr.enable = true;
    tautulli.enable = true;
    recyclarr.enable = true;
  };
}
