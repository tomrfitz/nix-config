{
  pkgs,
  lib,
  hostName,
  ...
}:
{
  # Daily rebuild from remote main as a root daemon (a user agent cannot run
  # unattended — sudo here is Touch ID-only). nh refuses `nh darwin` as root
  # unless told otherwise, and derives the target from macOS's LocalHostName,
  # which the OS silently renames on a network clash (seen: trfmbp-2) — so
  # pass both explicitly. Verified against nh 4.3.2 (locked) and master.
  launchd.daemons.auto-rebuild = {
    serviceConfig = {
      ProgramArguments = [
        (lib.getExe pkgs.nh)
        "darwin"
        "switch"
        "--refresh"
        "--bypass-root-check"
        "--hostname"
        hostName
      ];
      EnvironmentVariables = {
        NH_FLAKE = "github:tomrfitz/nix-config/main";
        PATH = "/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/bin:/bin";
        # nh's root-mode cache-dir fix (#739) ships only after v4.4.2; keep the
        # cache somewhere root can write meanwhile.
        XDG_CACHE_HOME = "/var/root/.cache";
      };
      StartCalendarInterval = [
        {
          Hour = 6;
          Minute = 30;
        }
      ];
      StandardOutPath = "/tmp/auto-rebuild.log";
      StandardErrorPath = "/tmp/auto-rebuild.log";
    };
  };
}
