{
  pkgs,
  lib,
  ...
}:
{
  home.homeDirectory = lib.mkForce "/home/tomrfitz";

  home.packages = with pkgs; [
    _1password-gui
    emacs
  ];
}
