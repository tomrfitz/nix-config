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
      bold-color = "bright";
      cursor-style = "bar";
      font-thicken = true;
      font-family = "Sarasa Fixed SC";
      quick-terminal-position = "center";
      # Wrap ssh in `ghostty +ssh`: forward the environment, and install
      # Ghostty's xterm-ghostty entry on a host's first connect (cached; see
      # `ghostty +ssh-cache`), falling back to xterm-256color if that fails.
      shell-integration-features = "ssh-env,ssh-terminfo";
      keybind = [
        "global:shift+ctrl+backquote=new_window"
        "global:ctrl+backquote=toggle_quick_terminal"
        # Windows and splits, not native tabs: paneru tiles a tab group as one
        # column and never scrolls it into view on Cmd-Tab or Dock focus.
        "super+t=new_window"
      ];
      focus-follows-mouse = true;
      # Needs Ghostty ≥ 1.4.0 on macOS 27: 1.3.1 squishes the tab strip.
      macos-titlebar-style = "tabs";
      macos-option-as-alt = true;
      auto-update = "off";
    };
  };
}
