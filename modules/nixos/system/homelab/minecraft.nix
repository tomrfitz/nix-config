{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.trf.homelab;
  rconRef = "op://d2kparnm4436vrbora6wnty6pm/MCRCON/password";
in
{
  config = lib.mkIf (cfg.enable && config.services.minecraft-server.enable) {
    # Resolve RCON password from 1Password at service start, after the
    # module's preStart writes the declarative server.properties.
    systemd.services.minecraft-server = {
      serviceConfig.LoadCredential = "op-sa-token:/etc/op/service-account-token";
      preStart = lib.mkAfter ''
        RCON_PASS="$(OP_SERVICE_ACCOUNT_TOKEN="$(cat "$CREDENTIALS_DIRECTORY/op-sa-token")" \
          ${pkgs._1password-cli}/bin/op read "${rconRef}")"
        ${pkgs.gnused}/bin/sed -i "s|^rcon\.password=.*|rcon.password=$RCON_PASS|" /var/lib/minecraft/server.properties
      '';
    };

    services.minecraft-server = {
      eula = true;
      declarative = true;
      package = pkgs.minecraftServers.vanilla;
      openFirewall = cfg.openFirewall;

      jvmOpts = lib.concatStringsSep " " [
        "-Xms2G"
        "-Xmx2G"
        "-XX:+UseG1GC"
        "-XX:+ParallelRefProcEnabled"
        "-XX:MaxGCPauseMillis=200"
        "-XX:+UnlockExperimentalVMOptions"
        "-XX:+DisableExplicitGC"
        "-XX:+AlwaysPreTouch"
        "-XX:G1NewSizePercent=30"
        "-XX:G1MaxNewSizePercent=40"
        "-XX:G1HeapRegionSize=8M"
        "-XX:G1ReservePercent=20"
        "-XX:G1HeapWastePercent=5"
        "-XX:G1MixedGCCountTarget=4"
        "-XX:InitiatingHeapOccupancyPercent=15"
        "-XX:G1MixedGCLiveThresholdPercent=90"
        "-XX:G1RSetUpdatingPauseTimePercent=5"
        "-XX:SurvivorRatio=32"
        "-XX:+PerfDisableSharedMem"
        "-XX:MaxTenuringThreshold=1"
      ];

      whitelist = {
        username1 = "0bd4a5ac-b3ce-4570-aee2-2af6e2e5cd20";
      };

      serverProperties = {
        enable-rcon = true;
        "rcon.password" = "PLACEHOLDER_RCON";
        "rcon.port" = 25575;
        gamemode = "survival";
        difficulty = "normal";
        max-players = 5;
        white-list = true;
        simulation-distance = 8;
        motd = "trfwsl";
      };
    };
  };
}
