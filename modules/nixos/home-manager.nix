{
  config,
  pkgs,
  lib,
  ghostty,
  ...
}:
{
  home.homeDirectory = lib.mkForce "/home/tomrfitz";

  # ── Ghostty: use official flake package on NixOS ─────────────────────
  programs.ghostty = {
    package = ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
}
