{
  pkgs,
  config,
  ...
}:
{
  # XDG user directories — Linux only (macOS manages these natively)
  xdg.userDirs = {
    enable = !pkgs.stdenv.isDarwin;
    createDirectories = true;

    desktop = "${config.home.homeDirectory}/Desktop";
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    music = "${config.home.homeDirectory}/Music";
    pictures = "${config.home.homeDirectory}/Pictures";
    publicShare = "${config.home.homeDirectory}/Public";
    templates = "${config.home.homeDirectory}/Templates";
    videos = "${config.home.homeDirectory}/Videos";

    extraConfig = {
      DEVELOPER = "${config.home.homeDirectory}/Developer";
    };
  };
}
