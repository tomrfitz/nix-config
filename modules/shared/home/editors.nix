{
  lib,
  ...
}:
{
  # ── Helix ──────────────────────────────────────────────────────────────
  programs.helix = {
    enable = true;
    settings = {
      # Stylix overrides this with its generated Base16 theme
      theme = lib.mkDefault "flexoki-dark";
    };
    themes = {
      flexoki-dark = lib.importTOML ../../../config/helix-flexoki-dark.toml;
      flexoki-light = lib.importTOML ../../../config/helix-flexoki-light.toml;
    };
  };
}
