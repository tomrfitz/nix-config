# Traditional bar + notification stack (waybar + mako)
# Kept as a module for fallback — import in desktop.nix if noctalia is removed.
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    mako # notification daemon
  ];

  programs.waybar = {
    enable = true;
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 30;
      spacing = 8;
      modules-left = [ "niri/workspaces" ];
      modules-center = [ "clock" ];
      modules-right = [
        "cpu"
        "memory"
        "pulseaudio"
        "network"
        "battery"
        "tray"
      ];
      battery = {
        format-charging = "BAT ↑{capacity}% {power:.1f}W";
        format-discharging = "BAT ↓{capacity}% {power:.1f}W";
        format-full = "BAT full";
        format-plugged = "BAT AC";
        tooltip-format = "{timeTo}\n{power:.2f}W";
        interval = 5;
        states = {
          warning = 30;
          critical = 15;
        };
      };
      clock = {
        format = "{:%a %b %d  %H:%M}";
        tooltip-format = "{:%Y-%m-%d %H:%M:%S}";
      };
      cpu.format = "CPU {usage}%";
      memory.format = "RAM {}%";
      network = {
        format-wifi = "WIFI {essid} ({signalStrength}%)";
        format-ethernet = "ETH {ipaddr}/{cidr}";
        format-disconnected = "NET down";
        tooltip-format = "{ifname} via {gwaddr}";
      };
      pulseaudio = {
        format = "VOL {volume}%";
        format-muted = "VOL mute";
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      };
      tray.spacing = 10;
    };
    # Stylix handles base theming (colors, fonts); custom overrides below
    style = ''
      @define-color tx-muted #878580;
      @define-color bg-2 #1c1b1a;
      @define-color ui #282726;
      @define-color cyan #3aa99f;
      @define-color yellow #d0a215;
      @define-color red #d14d41;

      window#waybar {
        background: alpha(@base00, 0.92);
        border-bottom: 1px solid alpha(@ui, 0.95);
      }

      #workspaces,
      #clock,
      #cpu,
      #memory,
      #pulseaudio,
      #network,
      #battery,
      #tray {
        padding: 0 8px;
        background: alpha(@bg-2, 0.85);
        border-radius: 8px;
        margin: 4px 0;
      }

      #battery.warning { color: @yellow; }
      #battery.critical { color: @red; }
      #network { color: @cyan; }
      #tray { color: @tx-muted; }

      .modules-left #workspaces button {
        border-bottom: 3px solid transparent;
      }
      .modules-left #workspaces button.active {
        border-bottom: 3px solid @base05;
      }
      .modules-left #workspaces button.urgent {
        border-bottom: 3px solid @base08;
        background-color: @base08;
        color: @base00;
      }
    '';
  };

  services.mako = {
    enable = true;
    settings.default-timeout = 5000;
  };
}
