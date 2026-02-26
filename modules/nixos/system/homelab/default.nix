{
  config,
  lib,
  user,
  isWSL,
  ...
}:
let
  cfg = config.trf.homelab;
in
{
  imports = [
    ./sonarr.nix
    ./radarr.nix
    ./lidarr.nix
    ./bookshelf.nix
    ./prowlarr.nix
    ./bazarr.nix
    ./sabnzbd.nix
    ./plex.nix
    ./jellyfin.nix
    ./tautulli.nix
    ./jellyseerr.nix
    ./calibre.nix
    ./qbittorrent.nix
    ./immich.nix
    ./booklore.nix
    ./recyclarr.nix
    ./openbooks.nix
  ];

  options.trf.homelab = {
    enable = lib.mkEnableOption "homelab service profile";

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open firewall ports for enabled homelab services.";
    };

    paths = {
      mediaRoot = lib.mkOption {
        type = lib.types.str;
        default = "/mnt/z/data/media";
        description = "Root media path (TRaSH-style).";
      };

      usenetRoot = lib.mkOption {
        type = lib.types.str;
        default = "/mnt/k/data/usenet";
        description = "Usenet downloads root (TRaSH-style: incomplete/, complete/{tv,movies,music,books}).";
      };

      torrentsRoot = lib.mkOption {
        type = lib.types.str;
        default = "/mnt/k/data/torrents";
        description = "Torrent downloads root (TRaSH-style: books/, movies/, music/, tv/).";
      };

      booksRoot = lib.mkOption {
        type = lib.types.str;
        default = "/mnt/z/data/media/books";
        description = "Root books path.";
      };

      configRoot = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/homelab";
        description = "Linux-local app config/state root.";
      };
    };

  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          !isWSL
          || (
            lib.hasPrefix "/mnt/" cfg.paths.mediaRoot
            && lib.hasPrefix "/mnt/" cfg.paths.usenetRoot
            && lib.hasPrefix "/mnt/" cfg.paths.torrentsRoot
            && lib.hasPrefix "/mnt/" cfg.paths.booksRoot
          );
        message = "For WSL hosts, homelab paths should live under /mnt/<drive>/...";
      }
    ];

    services.tailscale.enable = lib.mkDefault true;

    users.groups.media = { };
    users.users.${user}.extraGroups = [ "media" ];

    systemd.tmpfiles.rules = [
      "d ${cfg.paths.configRoot} 0750 ${user} users - -"
    ];
  };
}
