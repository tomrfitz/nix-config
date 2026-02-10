{
  config,
  pkgs,
  lib,
  ...
}:
{
  home.homeDirectory = lib.mkForce "/home/tomrfitz";
}
