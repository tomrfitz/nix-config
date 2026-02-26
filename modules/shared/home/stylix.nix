{ ... }:
{
  stylix.targets = {
    # Vencord handles its own Flexoki theme via custom CSS
    vesktop.enable = false;

    # Both apps respond to the system dark/light preference natively
    # (macOS appearance + freedesktop portal). Stylix's base16 themes
    # are less granular than the bundled Flexoki themes.
    ghostty.enable = false;
    zed.enable = false;

    # Browsers follow the freedesktop portal dark preference automatically;
    # Stylix CSS injection requires profile names and isn't worth the complexity.
    firefox.enable = false;
    floorp.enable = false;
    zen-browser.enable = false;

    # Let each desktop environment manage Qt integration natively.
    # This avoids brittle cross-DE behavior (e.g. Plasma session issues).
    qt.enable = false;
  };
}
