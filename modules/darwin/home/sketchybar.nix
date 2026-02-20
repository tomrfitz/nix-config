{
  pkgs,
  lib,
  ...
}:
{
  # Sketchybar uses a complex Lua-based config in ~/.config/sketchybar
  # Enable and set config.source when ready to use
  programs.sketchybar = {
    enable = false;
  };
}
