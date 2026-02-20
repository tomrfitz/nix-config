{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./zsh.nix
    ./git.nix
    ./topgrade.nix
    ./aerospace.nix
    ./sketchybar.nix
  ];

  home.homeDirectory = lib.mkForce "/Users/tomrfitz";

  # ── Copy .app bundles so Spotlight can index them ────────────────────
  targets.darwin.linkApps.enable = false;
  targets.darwin.copyApps.enable = true;

  # ── macOS-specific packages ────────────────────────────────────────────
  home.packages = with pkgs; [
    mas
    container
    iina
  ];

  # ── macOS-specific session variables ───────────────────────────────────
  home.sessionVariables = {
    SCRNSHT = "$HOME/Documents/Screenshots/";
    NVM_DIR = "$HOME/.nvm";
  };

  # ── Emacs-plus build config ──────────────────────────────────────────
  xdg.configFile."emacs-plus/build.yml".text = ''
    icon: liquid-glass
  '';

  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/.juliaup/bin"
    "$HOME/.config/emacs/bin"
    "$HOME/vcpkg"
    "$HOME/.cache/.bun/bin"
    "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
    "$HOME/Library/Application Support/Coursier/bin"
  ];
}
