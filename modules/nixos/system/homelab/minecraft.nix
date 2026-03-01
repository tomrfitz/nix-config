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
        username1 = "0bd4a5acb3ce4570aee22af6e2e5cd20";
      };

      serverProperties = {
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
