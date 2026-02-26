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
  };

  trf.wsl.gpu.enable = true;

  services.ollama.enable = true;

  trf.homelab = {
    enable = true;

    # Keep firewall closed by default; expose via Tailscale first.
    exposePorts = false;

    # TRaSH-style roots on StableBit DrivePool-mounted Z: drive in WSL.
    paths = {
      mediaRoot = lib.mkDefault "/mnt/z/data/media";
      downloadsRoot = lib.mkDefault "/mnt/z/data/torrents";
      booksRoot = lib.mkDefault "/mnt/z/data/media/books";
    };

    # Current stack
    apps = {
      bazarr = true;
      calibre = true;
      lidarr = true;
      plex = true;
      radarr = true;
      readarr = true;
      sabnzbd = true;
      sonarr = true;
      tautulli = true;

      # Planned migrations/additions
      booklore = false;
      immich = false;
      jellyfin = false;
      jellyseerr = false;
    };
  };
}
