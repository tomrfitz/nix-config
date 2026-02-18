{
  pkgs,
  lib,
  ...
}:
{
  home.homeDirectory = lib.mkForce "/home/tomrfitz";

  home.packages = with pkgs; [
    _1password-gui
    # emacs # heavy — re-enable before darwin rebuild
    foot # lightweight Wayland terminal
    wofi # app launcher
    wl-clipboard
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
    };
  };
}
