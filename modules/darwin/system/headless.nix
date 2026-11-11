# An always-on Mac driven from another one; see AGENTS.md § Headless Macs
{ lib, user, ... }:
{
  power = {
    sleep.computer = "never";
    sleep.display = 2;
    restartAfterFreeze = true;
  };

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
