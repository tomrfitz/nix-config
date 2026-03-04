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
    fuzzel # app launcher
    xwayland-satellite
    swaylock-effects # lock screen (drop-in swaylock with blur/clock)
    wl-clipboard
    swaybg # wallpaper
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
      # ── Launch ──────────────────────────────────────────────────────
      "Super+Return".action.spawn = "ghostty";
      "Super+Space".action.spawn = "fuzzel";
      "Super+Q".action.close-window = { };
      "Super+F".action.fullscreen-window = { };

      # ── Focus (vim-style) ───────────────────────────────────────────
      "Super+H".action.focus-column-left = { };
      "Super+J".action.focus-window-down = { };
      "Super+K".action.focus-window-up = { };
      "Super+L".action.focus-column-right = { };

      # ── Move ────────────────────────────────────────────────────────
      "Super+Shift+H".action.move-column-left = { };
      "Super+Shift+J".action.move-window-down = { };
      "Super+Shift+K".action.move-window-up = { };
      "Super+Shift+L".action.move-column-right = { };

      # ── Column management ───────────────────────────────────────────
      "Super+Comma".action.consume-window-into-column = { };
      "Super+Period".action.expel-window-from-column = { };
      "Super+R".action.switch-preset-column-width = { };
      "Super+W".action.maximize-column = { };
      "Super+Shift+F".action.toggle-window-floating = { };

      # ── Resize ──────────────────────────────────────────────────────
      "Super+Minus".action.set-column-width = "-10%";
      "Super+Equal".action.set-column-width = "+10%";
      "Super+Shift+Minus".action.set-window-height = "-10%";
      "Super+Shift+Equal".action.set-window-height = "+10%";
      "Super+Shift+R".action.reset-window-height = { };

      # ── Workspace nav ───────────────────────────────────────────────
      "Super+Tab".action.focus-workspace-previous = { };
      "Super+U".action.focus-workspace-up = { };
      "Super+I".action.focus-workspace-down = { };
      "Super+Shift+U".action.move-window-to-workspace-up = { };
      "Super+Shift+I".action.move-window-to-workspace-down = { };

      # Workspace by index
      "Super+1".action.focus-workspace = 1;
      "Super+2".action.focus-workspace = 2;
      "Super+3".action.focus-workspace = 3;
      "Super+4".action.focus-workspace = 4;
      "Super+5".action.focus-workspace = 5;
      "Super+6".action.focus-workspace = 6;
      "Super+7".action.focus-workspace = 7;
      "Super+8".action.focus-workspace = 8;
      "Super+9".action.focus-workspace = 9;
      "Super+Shift+1".action.move-window-to-workspace = 1;
      "Super+Shift+2".action.move-window-to-workspace = 2;
      "Super+Shift+3".action.move-window-to-workspace = 3;
      "Super+Shift+4".action.move-window-to-workspace = 4;
      "Super+Shift+5".action.move-window-to-workspace = 5;
      "Super+Shift+6".action.move-window-to-workspace = 6;
      "Super+Shift+7".action.move-window-to-workspace = 7;
      "Super+Shift+8".action.move-window-to-workspace = 8;
      "Super+Shift+9".action.move-window-to-workspace = 9;

      # ── Column position ─────────────────────────────────────────────
      "Super+Home".action.focus-column-first = { };
      "Super+End".action.focus-column-last = { };
      "Super+Shift+Home".action.move-column-to-first = { };
      "Super+Shift+End".action.move-column-to-last = { };

      # ── System ──────────────────────────────────────────────────────
      "Super+Shift+E".action.quit = {
        skip-confirmation = true;
      };
      "Super+Shift+P".action.power-off-monitors = { };
      "Super+O".action.toggle-overview = { };

      # ── Lock ────────────────────────────────────────────────────────
      "Super+Alt+L".action.spawn = [
        "swaylock"
        "--screenshots"
        "--clock"
        "--effect-blur"
        "7x5"
        "--fade-in"
        "0.2"
      ];

      # ── Screenshots (niri built-in) ─────────────────────────────────
      "Super+Shift+S".action.screenshot = { };
      "Print".action.screenshot-screen = { };
      "Super+Print".action.screenshot-window = { };

      # ── Media keys (allow-when-locked) ──────────────────────────────
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
    };

    spawn-at-startup = [
      { argv = [ "xwayland-satellite" ]; }
      {
        argv = [
          "swaybg"
          "-i"
          "${../../../config/wallpaper.jpg}"
          "-m"
          "fill"
        ];
      }
    ];
  };

  # Polkit agent provided by nixosModules.niri (KDE polkit)

  # ── Waybar ──────────────────────────────────────────────────────────
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
