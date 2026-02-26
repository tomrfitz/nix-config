# Bookshelf — Readarr fork with baked-in Hardcover metadata.
# OCI container (no nixpkgs module). Replaces retired Readarr.
# https://github.com/pennydreadful/bookshelf
{
  config,
  lib,
  ...
}:
let
  cfg = config.trf.homelab;
  bscfg = config.trf.homelab.bookshelf;
in
{
  options.trf.homelab.bookshelf = {
    enable = lib.mkEnableOption "Bookshelf (Readarr fork with Hardcover metadata)";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8787;
      description = "Web UI port for Bookshelf.";
    };
  };

  config = lib.mkIf (cfg.enable && bscfg.enable) {
    virtualisation.oci-containers.containers.bookshelf = {
      image = "ghcr.io/pennydreadful/bookshelf:hardcover";
      ports = [ "${toString bscfg.port}:8787" ];
      volumes = [
        "${cfg.paths.configRoot}/bookshelf:/config"
        "${cfg.paths.booksRoot}:/books"
        "${cfg.paths.usenetRoot}:/downloads/usenet"
        "${cfg.paths.torrentsRoot}:/downloads/torrents"
      ];
      environment = {
        PUID = "1000";
        PGID = "1000";
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.paths.configRoot}/bookshelf 0750 1000 users - -"
    ];

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ bscfg.port ];
  };
}
