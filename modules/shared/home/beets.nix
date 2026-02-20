{
  pkgs,
  lib,
  ...
}:
{
  programs.beets = {
    enable = true;
    settings = {
      plugins = "musicbrainz spotify";
    };
  };
}
