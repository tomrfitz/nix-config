{
  lib,
  ...
}:
{
  specialisation = {
    gnome.configuration = {
      services.xserver.enable = lib.mkForce true;
      services.displayManager.gdm.enable = lib.mkForce true;
      services.desktopManager.gnome.enable = lib.mkForce true;
    };
  };
}
