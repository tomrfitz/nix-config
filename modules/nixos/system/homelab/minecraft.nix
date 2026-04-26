{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.trf.homelab;
in
{
  config = lib.mkIf (cfg.enable && config.services.minecraft-server.enable) {
    sops.secrets."minecraft/rcon-password" = {
      owner = "minecraft";
      restartUnits = [ "minecraft-server.service" ];
    };

    # Resolve RCON password from sops at service start, after the
    # module's preStart writes the declarative server.properties.
    systemd.services.minecraft-server.preStart = lib.mkAfter ''
      RCON_PASS="$(cat ${config.sops.secrets."minecraft/rcon-password".path})"
      ${pkgs.gnused}/bin/sed -i "s|^rcon\.password=.*|rcon.password=$RCON_PASS|" /var/lib/minecraft/server.properties
    '';

    services.minecraft-server = {
      eula = true;
      declarative = true;
      package = pkgs.minecraftServers.vanilla;
      inherit (cfg) openFirewall;

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
