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
    ./paneru.nix
    ./sketchybar.nix
    ./auto-rebuild.nix
  ];

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

  # ── Karabiner-Elements ──────────────────────────────────────────────
  # Karabiner rewrites its config in-place (unlinking symlinks), so we
  # copy instead of symlinking to avoid home-manager backup conflicts.
  home.activation.karabiner = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    install -Dm600 ${../../../config/karabiner.json} "$HOME/.config/karabiner/karabiner.json"
  '';

  # ── Emacs-plus build config ──────────────────────────────────────────
  xdg.configFile."emacs-plus/build.yml".text = ''
    icon: liquid-glass
  '';

}
