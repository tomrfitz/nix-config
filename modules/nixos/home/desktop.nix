{
  pkgs,
  lib,
  ...
}:
let
  namedWorkspaces = [
    "A"
    "B"
    "C"
    "D"
    "E"
    "G"
    "I"
    "M"
    "N"
    "O"
    "P"
    "Q"
    "R"
    "S"
    "T"
    "U"
    "V"
    "W"
    "X"
    "Y"
    "Z"
  ];

  numericWorkspaceBinds = lib.concatMapStrings (n: ''
    Super+${n} { focus-workspace ${n}; }
    Super+Shift+${n} { move-column-to-workspace ${n}; }
  '') (map toString (lib.range 1 9));

  namedWorkspaceDecls = lib.concatMapStrings (name: ''
    workspace "${name}"
  '') namedWorkspaces;

  namedWorkspaceBinds = lib.concatMapStrings (name: ''
    Super+${name} { focus-workspace "${name}"; }
    Super+Shift+${name} { move-column-to-workspace "${name}"; }
  '') namedWorkspaces;
in
{
  imports = [
    ./darkman.nix
  ];

  home.packages = with pkgs; [
    # 1password installed via programs._1password-gui in system config
    emacs
    foot # lightweight Wayland terminal
    wofi # app launcher
    xwayland-satellite
    swaylock
    wl-clipboard
    brightnessctl
    playerctl
    libnotify
    mako # notification daemon
  ];

  # ── Niri ────────────────────────────────────────────────────────────
  xdg.configFile."niri/config.kdl".text = ''
    input {
      touchpad {
        tap
        natural-scroll
        dwt
      }
    }

    layout {
      gaps 5
      struts {
        left 4
        right 4
        top 4
        bottom 4
      }
    }

    ${namedWorkspaceDecls}

    binds {
      Super+Return { spawn "ghostty"; }
      Super+Space { spawn-sh "wofi --show drun"; }
      Super+F { fullscreen-window; }

      Super+H { focus-column-left; }
      Super+J { focus-window-down; }
      Super+K { focus-window-up; }
      Super+L { focus-column-right; }

      Super+Shift+H { move-column-left; }
      Super+Shift+J { move-window-down; }
      Super+Shift+K { move-window-up; }
      Super+Shift+L { move-column-right; }

      Super+Minus { set-column-width "-10%"; }
      Super+Equal { set-column-width "+10%"; }

      ${numericWorkspaceBinds}
      ${namedWorkspaceBinds}

      Super+Tab { focus-workspace-previous; }
      Super+Shift+Tab { move-workspace-to-monitor-right; }
      Super+Alt+L { spawn "swaylock"; }

      XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"; }
      XF86AudioLowerVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"; }
      XF86AudioMute allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
      XF86AudioMicMute allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }

      XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "set" "+5%"; }
      XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "set" "5%-"; }

      XF86AudioPlay allow-when-locked=true { spawn-sh "playerctl play-pause"; }
      XF86AudioNext allow-when-locked=true { spawn-sh "playerctl next"; }
      XF86AudioPrev allow-when-locked=true { spawn-sh "playerctl previous"; }

      Super+Shift+S { spawn-sh "${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy"; }
    }
  '';

  # Polkit authentication agent (required for 1Password system auth, etc.)
  systemd.user.services.polkit-gnome-agent = {
    Unit = {
      Description = "polkit-gnome-authentication-agent-1";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # Notification daemon
  services.mako = {
    enable = true;
    settings.default-timeout = 5000;
  };

  # Blue light filter (screen temperature) for Wayland
  # Uses geoclue2 for automatic location detection (like macOS Night Shift)
  services.gammastep = {
    enable = true;
    provider = "geoclue2";
    temperature = {
      day = 6500;
      night = 3000;
    };
  };
}
