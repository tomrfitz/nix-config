{
  lib,
  user,
  ...
}:
{
  home.homeDirectory = lib.mkForce "/home/${user}";
}
