{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./ssh.nix
  ];

  home.homeDirectory = lib.mkForce "/home/tomrfitz";

  home.packages = with pkgs; [
    # 1password installed via programs._1password-gui in system config
    # emacs # heavy — re-enable later
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
      terminal = "foot";
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

  # Notification daemon
  services.mako = {
    enable = true;
    settings.default-timeout = 5000;
  };
}
