# An always-on Mac driven from another one; see AGENTS.md § Headless Macs
{ user, ... }:
{
  power = {
    sleep.computer = "never";
    sleep.display = 2;
    restartAfterFreeze = true;
  };

  security.sudo.extraConfig = ''
    ${user} ALL=(root) NOPASSWD: /bin/launchctl kickstart system/org.nixos.auto-rebuild
    ${user} ALL=(root) NOPASSWD: /bin/launchctl kickstart -k system/org.nixos.batt
  '';
}
