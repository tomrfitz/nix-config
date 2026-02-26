{
  pkgs,
  lib,
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
    wl-clipboard
    brightnessctl
    playerctl
    libnotify
    mako # notification daemon
  ];

  # ── Sway ────────────────────────────────────────────────────────────
  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = "Mod4"; # Super key
      terminal = "ghostty";
      menu = "wofi --show drun";
      bars = [
        {
          position = "top";
          statusCommand = "${pkgs.i3status}/bin/i3status";
        }
      ];

      keybindings =
        let
          mod = "Mod4";
        in
        lib.mkOptionDefault {
          # Volume (pipewire via wpctl)
          "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
          "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "XF86AudioMicMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";

          # Brightness
          "XF86MonBrightnessUp" = "exec brightnessctl set +5%";
          "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";

          # Media
          "XF86AudioPlay" = "exec playerctl play-pause";
          "XF86AudioNext" = "exec playerctl next";
          "XF86AudioPrev" = "exec playerctl previous";

          # Screenshot
          "${mod}+Shift+s" = "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | wl-copy";
        };

      output."*".scale = "1.5";

      input = {
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
          dwt = "enabled"; # disable while typing
        };
        "type:touch" = {
          map_to_output = "*";
        };
        "type:tablet_tool" = {
          map_to_output = "*";
        };
      };
    };
  };

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
