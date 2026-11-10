{ pkgs, ... }:
let
  # 10–99; 100 lifts the limit
  settings.limit = 40;
  bin = "/opt/homebrew/opt/batt/bin/batt";
in
{
  homebrew.brews = [ "batt" ];

  # Replaces `sudo brew services start batt`; see AGENTS.md § Charge limiters
  launchd.daemons.batt = {
    script = ''
      /bin/wait4path ${bin}
      /usr/bin/install -m 644 ${pkgs.writeText "batt.json" (builtins.toJSON settings)} /etc/batt.json
      exec ${bin} daemon --always-allow-non-root-access
    '';
    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
      ProcessType = "Interactive";
      StandardOutPath = "/var/log/batt.log";
      StandardErrorPath = "/var/log/batt.log";
    };
  };
}
