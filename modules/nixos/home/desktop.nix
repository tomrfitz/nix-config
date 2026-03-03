{
  pkgs,
  ...
}:
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
    grim
    slurp
    brightnessctl
    playerctl
    libnotify
    mako # notification daemon
  ];

  # ── Niri ────────────────────────────────────────────────────────────
  # nixosModules.niri provides: polkit agent, xdg-desktop-portal-gnome,
  # GNOME keyring, dconf, opengl, default fonts, swaylock PAM, binary cache
  programs.niri.settings = {
    environment."NIXOS_OZONE_WL" = "1";
    input = {
      keyboard.xkb = { };
      touchpad = {
        tap = true;
        natural-scroll = true;
        dwt = true;
      };
    };

    layout = {
      gaps = 5;
      struts = {
        left = 4;
        right = 4;
        top = 4;
        bottom = 4;
      };
      preset-column-widths = [
        { proportion = 0.5; }
        { proportion = 0.667; }
        { proportion = 1.0; }
      ];
      default-column-width.proportion = 0.5;
    };

    # No named workspaces — embrace niri's scrolling model.
    # Dynamic workspaces are created/destroyed as needed.

    binds = {
      # Launch
      "Super+Return".action.spawn = "ghostty";
      "Super+Space".action.spawn = [
        "wofi"
        "--show"
        "drun"
      ];
      "Super+Q".action.close-window = { };
      "Super+F".action.fullscreen-window = { };

      # Focus (vim-style)
      "Super+H".action.focus-column-left = { };
      "Super+J".action.focus-window-down = { };
      "Super+K".action.focus-window-up = { };
      "Super+L".action.focus-column-right = { };

      # Move
      "Super+Shift+H".action.move-column-left = { };
      "Super+Shift+J".action.move-window-down = { };
      "Super+Shift+K".action.move-window-up = { };
      "Super+Shift+L".action.move-column-right = { };

      # Resize
      "Super+Minus".action.set-column-width = "-10%";
      "Super+Equal".action.set-column-width = "+10%";

      # Workspace nav
      "Super+Tab".action.focus-workspace-previous = { };

      # Lock
      "Super+Alt+L".action.spawn = "swaylock";

      # Media keys (allow-when-locked)
      "XF86AudioRaiseVolume" = {
        allow-when-locked = true;
        action.spawn = [
          "wpctl"
          "set-volume"
          "@DEFAULT_AUDIO_SINK@"
          "5%+"
        ];
      };
      "XF86AudioLowerVolume" = {
        allow-when-locked = true;
        action.spawn = [
          "wpctl"
          "set-volume"
          "@DEFAULT_AUDIO_SINK@"
          "5%-"
        ];
      };
      "XF86AudioMute" = {
        allow-when-locked = true;
        action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      };
      "XF86AudioMicMute" = {
        allow-when-locked = true;
        action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
      };
      "XF86MonBrightnessUp" = {
        allow-when-locked = true;
        action.spawn = [
          "brightnessctl"
          "set"
          "+5%"
        ];
      };
      "XF86MonBrightnessDown" = {
        allow-when-locked = true;
        action.spawn = [
          "brightnessctl"
          "set"
          "5%-"
        ];
      };
      "XF86AudioPlay" = {
        allow-when-locked = true;
        action.spawn-sh = "playerctl play-pause";
      };
      "XF86AudioNext" = {
        allow-when-locked = true;
        action.spawn-sh = "playerctl next";
      };
      "XF86AudioPrev" = {
        allow-when-locked = true;
        action.spawn-sh = "playerctl previous";
      };

      # Screenshot (region → clipboard)
      "Super+Shift+S".action.spawn-sh = ''grim -g "$(slurp)" - | wl-copy'';
    };

    spawn-at-startup = [
      { argv = [ "xwayland-satellite" ]; }
    ];
  };

  # Polkit agent provided by nixosModules.niri (KDE polkit)

  # Notification daemon
  services.mako = {
    enable = true;
    settings.default-timeout = 5000;
  };

  # Basic status bar for Niri; easy to style/expand later.
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        spacing = 8;

        modules-left = [
          "clock"
        ];
        modules-center = [
          "cpu"
          "memory"
        ];
        modules-right = [
          "pulseaudio"
          "network"
          "battery"
          "tray"
        ];

        clock = {
          format = "{:%a %b %d  %H:%M}";
          tooltip-format = "{:%Y-%m-%d %H:%M:%S}";
        };

        cpu.format = "CPU {usage}%";
        memory.format = "RAM {}%";

        pulseaudio = {
          format = "VOL {volume}%";
          format-muted = "VOL mute";
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };

        network = {
          format-wifi = "WIFI {essid} ({signalStrength}%)";
          format-ethernet = "ETH {ipaddr}/{cidr}";
          format-disconnected = "NET down";
          tooltip-format = "{ifname} via {gwaddr}";
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "BAT {capacity}%";
          format-charging = "BAT {capacity}%+";
          format-plugged = "BAT AC";
          format-full = "BAT full";
          tooltip-format = "{timeTo}";
        };

        tray.spacing = 10;
      };
    };
    style = ''
      * {
        font-family: "Atkinson Hyperlegible", "Symbols Nerd Font";
        font-size: 12px;
      }

      @define-color tx #cecdc3;
      @define-color tx-muted #878580;
      @define-color bg #100f0f;
      @define-color bg-2 #1c1b1a;
      @define-color ui #282726;
      @define-color cyan #3aa99f;
      @define-color yellow #d0a215;
      @define-color red #d14d41;

      window#waybar {
        background: alpha(@bg, 0.92);
        color: @tx;
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

      #battery.warning {
        color: @yellow;
      }

      #battery.critical {
        color: @red;
      }

      #network {
        color: @cyan;
      }

      #tray {
        color: @tx-muted;
      }
    '';
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
