# An always-on Mac driven from another one; see AGENTS.md § Headless Macs
{ lib, user, ... }:
{
  power = {
    sleep.computer = "never";
    sleep.display = 2;
    restartAfterFreeze = true;
  };

  # Only what is used without a screen, in place of homebrew.nix's list: the
  # less a Mac with FileVault off and auto-login holds, the less a compromise
  # of it reaches. An app comes back by being named here. Brew removes only
  # casks it installed, and with cleanup "uninstall" (never "zap" here) it
  # leaves their data: apps installed by hand, such as Rex, and App Store
  # apps stay, the second no longer managed.
  homebrew.casks = lib.mkForce [
    "1password"
    "chatgpt" # also the Codex app; the Codex CLI is nix's (programs.codex)
    "claude"
  ];
  programs.mas.enable = lib.mkForce false;

  # Nobody is there to touch the sensor, and a shell inside the GUI session
  # (Rex) waits on the locked screen's Touch ID prompt for good. Without
  # pam_tid sudo asks for the password in the terminal.
  security.pam.services.sudo_local = {
    touchIdAuth = lib.mkForce false;
    reattach = lib.mkForce false;
  };

  security.sudo.extraConfig = ''
    ${user} ALL=(root) NOPASSWD: /bin/launchctl kickstart system/org.nixos.auto-rebuild
    ${user} ALL=(root) NOPASSWD: /bin/launchctl kickstart -k system/org.nixos.batt
  '';
}
