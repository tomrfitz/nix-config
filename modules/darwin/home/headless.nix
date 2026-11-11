# The home side of system/headless.nix; see AGENTS.md § Headless Macs
{ lib, ... }:
{
  # No GUI editor here: a terminal frame on the Emacs daemon.
  home.sessionVariables.EDITOR = lib.mkForce "emacsclient -t";

  # Auto-login leaves the desktop open until the display sleeps. Sleeping it
  # at login locks at once: the lock delay is "immediately", set by hand.
  launchd.agents.lock-at-login = {
    enable = true;
    config = {
      ProgramArguments = [
        "/usr/bin/pmset"
        "displaysleepnow"
      ];
      RunAtLoad = true;
    };
  };
}
