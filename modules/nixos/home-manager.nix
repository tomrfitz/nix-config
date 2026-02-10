{ config, pkgs, lib, ... }:

{
  home.homeDirectory = lib.mkForce "/home/tomrfitz";

  # NixOS-specific session path additions
  home.sessionPath = [ ];

  # NixOS-specific zsh configuration
  programs.zsh.profileExtra = ''
    if [[ "$TERM_PROGRAM" != "vscode" && "$TERM_PROGRAM" != "zed" ]]; then
      command -v fastfetch &>/dev/null && fastfetch
    fi
  '';

  # Ghostty on NixOS (installed via nix, not brew)
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      theme = "light:Flexoki Light,dark:Flexoki Dark";
      quit-after-last-window-closed = false;
      clipboard-read = "allow";
      clipboard-write = "allow";
      window-padding-balance = true;
      window-theme = "system";
      window-height = 36;
      window-width = 130;
      bold-is-bright = true;
      cursor-style = "bar";
      font-thicken = true;
      font-family = "Atkinson Hyperlegible Mono";
    };
  };
}
