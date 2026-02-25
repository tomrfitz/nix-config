{
  pkgs,
  lib,
  user,
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

  home.homeDirectory = lib.mkForce "/Users/${user}";

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
  };

  # ── Emacs-plus build config ──────────────────────────────────────────
  xdg.configFile."emacs-plus/build.yml".text = ''
    icon: liquid-glass
  '';

  home.sessionPath = [
    "$HOME/.config/emacs/bin"
  ];
}
