{ pkgs, ... }:
{
  stylix.targets = {
    # Vencord handles its own Flexoki theme via custom CSS
    vesktop.enable = false;

    # On macOS these apps have native system-responsive theming that follows
    # macOS appearance (dark/light). Stylix would overwrite that with a static
    # theme. On NixOS, Stylix manages them and HM specialisations handle switching.
    ghostty.enable = !pkgs.stdenv.isDarwin;
    zed.enable = !pkgs.stdenv.isDarwin;

    # Browsers follow the freedesktop portal dark preference automatically;
    # Stylix CSS injection requires profile names and isn't worth the complexity.
    firefox.enable = false;
    floorp.enable = false;
    zen-browser.enable = false;
  };
}
