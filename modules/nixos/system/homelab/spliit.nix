# Spliit — open-source expense splitting (Splitwise alternative).
# OCI container (no nixpkgs module) + NixOS PostgreSQL.
# Listens on port 3000 (host network).
# https://github.com/spliit-app/spliit
{
  config,
  lib,
  ...
}:
let
  cfg = config.trf.homelab;
  spcfg = config.trf.homelab.spliit;
  dbName = "spliit";
in
{
  options.trf.homelab.spliit = {
    enable = lib.mkEnableOption "Spliit (expense splitting)";
  };

  config = lib.mkIf (cfg.enable && spcfg.enable) {
    services.postgresql = {
      enable = true;
      enableTCPIP = true;
      ensureDatabases = [ dbName ];
      ensureUsers = [
        {
          name = dbName;
          ensureDBOwnership = true;
        }
      ];
      # Container can't use Unix socket peer auth (UID mismatch), so trust
      # localhost TCP connections to the spliit database.
      authentication = ''
        host ${dbName} ${dbName} 127.0.0.1/32 trust
        host ${dbName} ${dbName} ::1/128 trust
      '';
    };

    virtualisation.oci-containers.containers.spliit = {
      image = "ghcr.io/spliit-app/spliit:v1.19.1";
      environment = {
        POSTGRES_PRISMA_URL = "postgresql://${dbName}@127.0.0.1/${dbName}";
        POSTGRES_URL_NON_POOLING = "postgresql://${dbName}@127.0.0.1/${dbName}";
      };
      # Host network so the container can reach PostgreSQL on localhost.
      extraOptions = [ "--network=host" ];
    };

    systemd.services."podman-spliit" = {
      after = [ "postgresql.service" ];
      requires = [ "postgresql.service" ];
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ 3000 ];
  };
}
