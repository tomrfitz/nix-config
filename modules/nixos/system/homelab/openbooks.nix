# OpenBooks — IRC ebook search/download tool.
# No upstream NixOS module; runs as a systemd service wrapping the package.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.trf.homelab;
  obcfg = config.trf.homelab.openbooks;
in
{
  options.trf.homelab.openbooks = {
    enable = lib.mkEnableOption "OpenBooks IRC ebook downloader";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8071;
      description = "Web UI port for OpenBooks.";
    };
  };

  config = lib.mkIf (cfg.enable && obcfg.enable) {
    systemd.services.openbooks = {
      description = "OpenBooks IRC ebook search/download";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.openbooks} server --port ${toString obcfg.port} --dir ${cfg.paths.booksRoot}/incoming";
        DynamicUser = true;
        ReadWritePaths = [ cfg.paths.booksRoot ];
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ obcfg.port ];
  };
}
