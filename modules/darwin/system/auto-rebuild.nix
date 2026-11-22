{
  pkgs,
  lib,
  hostName,
  ...
}:
let
  # nh refuses `nh darwin` as root unless told otherwise, and derives the target
  # from macOS's LocalHostName, which the OS silently renames on a network clash
  # (seen: trfmbp-2, the M1's old name) — so pass both explicitly (verified
  # against nh 4.3.2). --no-rom (--no-nom before nh 4.5): the progress display's
  # redraws filled 66 MB of log on lenis in two weeks.
  run = pkgs.writeShellScript "auto-rebuild" ''
    echo "==> auto-rebuild $(date -Iseconds)"
    exec ${lib.getExe pkgs.nh} darwin switch --refresh --no-rom \
      --bypass-root-check --hostname ${lib.escapeShellArg hostName}
  '';
in
{
  # Daily rebuild from remote main as a root daemon (a user agent cannot run
  # unattended — sudo here is Touch ID-only).
  #
  # The plist names /etc/auto-rebuild, never a store path: when the plist
  # changes, activation unloads the daemon, which kills the very switch running
  # that activation before it loads the new one, and the daemon stays gone (lenis,
  # 2026-11-13, after a bump moved nh). Changing serviceConfig still does this
  # once: switch interactively after editing it.
  environment.etc."auto-rebuild".source = run;

  launchd.daemons.auto-rebuild = {
    serviceConfig = {
      ProgramArguments = [ "/etc/auto-rebuild" ];
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
      # Not /tmp: macOS empties it at boot, which hid whether this had ever run.
      StandardOutPath = "/var/log/auto-rebuild.log";
      StandardErrorPath = "/var/log/auto-rebuild.log";
    };
  };
}
