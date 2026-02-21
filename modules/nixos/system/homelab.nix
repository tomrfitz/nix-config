{
  config,
  lib,
  user,
  isWSL,
  ...
}:
let
  cfg = config.trf.homelab;

  appPorts = {
    bazarr = [ 6767 ];
    calibre = [ 8083 ];
    immich = [ 2283 ];
    jellyfin = [ 8096 ];
    jellyseerr = [ 5055 ];
    lidarr = [ 8686 ];
    plex = [ 32400 ];
    radarr = [ 7878 ];
    readarr = [ 8787 ];
    sabnzbd = [ 8080 ];
    sonarr = [ 8989 ];
    tautulli = [ 8181 ];
  };

  enabledAppNames = lib.attrNames (lib.filterAttrs (_: enabled: enabled) cfg.apps);
  allowedPorts = lib.unique (lib.concatMap (name: appPorts.${name} or [ ]) enabledAppNames);
in
{
  options.trf.homelab = {
    enable = lib.mkEnableOption "homelab service profile";

    exposePorts = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open firewall ports for enabled homelab apps.";
    };

    paths = {
      mediaRoot = lib.mkOption {
        type = lib.types.str;
        default = "/mnt/z/data/media";
        description = "Root media path (TRaSH-style).";
      };

      downloadsRoot = lib.mkOption {
        type = lib.types.str;
        default = "/mnt/z/data/torrents";
        description = "Root downloads path (TRaSH-style).";
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

    apps =
      lib.genAttrs
        [
          "bazarr"
          "booklore"
          "calibre"
          "immich"
          "jellyfin"
          "jellyseerr"
          "lidarr"
          "plex"
          "radarr"
          "readarr"
          "sabnzbd"
          "sonarr"
          "tautulli"
        ]
        (
          _:
          lib.mkOption {
            type = lib.types.bool;
            default = false;
          }
        );
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          !isWSL
          || (
            lib.hasPrefix "/mnt/" cfg.paths.mediaRoot
            && lib.hasPrefix "/mnt/" cfg.paths.downloadsRoot
            && lib.hasPrefix "/mnt/" cfg.paths.booksRoot
          );
        message = "For WSL hosts, homelab paths should live under /mnt/<drive>/...";
      }
    ];

    warnings = lib.optional (
      cfg.apps.booklore && cfg.apps.calibre
    ) "Both booklore and calibre are enabled. Keep one primary to reduce maintenance.";

    services.tailscale.enable = lib.mkDefault true;

    users.groups.media = { };
    users.users.${user}.extraGroups = [ "media" ];

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.exposePorts allowedPorts;

    # Keep app state off /mnt for better Linux metadata performance under WSL.
    systemd.tmpfiles.rules = [
      "d ${cfg.paths.configRoot} 0750 ${user} users - -"
      "d ${cfg.paths.configRoot}/logs 0750 ${user} users - -"
    ]
    ++ map (name: "d ${cfg.paths.configRoot}/${name} 0750 ${user} users - -") enabledAppNames;

    environment.etc."homelab/README".text = ''
      trf homelab profile

      mediaRoot=${cfg.paths.mediaRoot}
      downloadsRoot=${cfg.paths.downloadsRoot}
      booksRoot=${cfg.paths.booksRoot}
      configRoot=${cfg.paths.configRoot}

      enabledApps=${lib.concatStringsSep "," enabledAppNames}

      note: this is a wiring stub; per-service module enablement will be added incrementally.
    '';
  };
}
