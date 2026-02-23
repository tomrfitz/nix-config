{
  pkgs,
  lib,
  ...
}:
{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    package = lib.mkIf pkgs.stdenv.isDarwin null;
    settings = {
      # On macOS, Ghostty uses native system-responsive theming (Stylix disabled).
      # On NixOS, Stylix manages the theme via HM specialisations.
      theme = lib.mkIf pkgs.stdenv.isDarwin "light:Flexoki Light,dark:Flexoki Dark";
      quit-after-last-window-closed = false;
      copy-on-select = "clipboard";
      clipboard-read = "allow";
      clipboard-write = "allow";
      right-click-action = "copy-or-paste";
      gtk-titlebar-style = "tabs";
      link-url = "true";
      link-previews = "true";
      window-padding-balance = true;
      window-theme = "system";
      window-height = 36;
      window-width = 130;
      bold-is-bright = true;
      cursor-style = "bar";
      font-thicken = true;
      font-family = "Atkinson Hyperlegible Mono";
      quick-terminal-position = "center";
      custom-shader-animation = true;
      window-padding-y = 5;
      window-position-y = 150;
      window-position-x = 175;
      window-step-resize = true;
      keybind = [
        "global:shift+ctrl+backquote=new_window"
        "global:ctrl+backquote=toggle_quick_terminal"
      ];
      macos-titlebar-style = "tabs";
      macos-option-as-alt = true;
      auto-update = "off";
      auto-update-channel = "stable";
    };
  };
}
