{
  pkgs,
  lib,
  ...
}:
{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    package = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin null;
    settings = {
      theme = "light:Flexoki Light,dark:Flexoki Dark";
      font-size = 12;
      quit-after-last-window-closed = false;
      copy-on-select = "clipboard";
      clipboard-read = "allow";
      right-click-action = "copy-or-paste";
      window-padding-balance = true;
      window-padding-x = 8;
      window-padding-y = 8;
      window-save-state = "always";
      window-theme = "system";
      bold-is-bright = true;
      cursor-style = "bar";
      font-thicken = true;
      font-family = "Atkinson Hyperlegible Mono";
      quick-terminal-position = "center";
      # Keep remote SSH sessions usable when hosts don't yet have Ghostty terminfo.
      shell-integration-features = "ssh-env,ssh-terminfo";
      keybind = [
        "global:shift+ctrl+backquote=new_window"
        "global:ctrl+backquote=toggle_quick_terminal"
      ];
      focus-follows-mouse = true;
      # REVISIT(upstream): restore `macos-titlebar-style = "tabs"` once a stable
      #   Ghostty ships the macOS 27 tab-titlebar fix (merged on tip in #13069;
      #   1.3.1 squishes the tab strip). ref: https://github.com/ghostty-org/ghostty/issues/13070; checked: 2026-09-22
      macos-option-as-alt = true;
      auto-update = "off";
    };
  };
}
