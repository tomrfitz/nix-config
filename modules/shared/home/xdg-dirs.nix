{ pkgs, ... }:
{
  # XDG user directories — Linux only (macOS manages these natively).
  # All paths use home-manager defaults, which match the freedesktop spec
  # (xdg-user-dirs 0.20+, including the new Projects directory).
  xdg.userDirs = {
    enable = !pkgs.stdenv.hostPlatform.isDarwin;
    createDirectories = true;
    # Export XDG_*_DIR into the shell env so tools that consult env vars
    # (rather than reading user-dirs.dirs directly) see the paths.
    setSessionVariables = true;
  };
}
