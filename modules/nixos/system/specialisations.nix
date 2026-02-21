{
  lib,
  pkgs,
  ...
}:
{
  specialisation = {
    plasma.configuration = {
      services.xserver.enable = lib.mkForce true;
      services.displayManager.gdm.enable = lib.mkForce false;
      services.desktopManager.gnome.enable = lib.mkForce false;

      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
      };
      services.desktopManager.plasma6.enable = true;
    };

    sway.configuration = {
      services.xserver.enable = lib.mkForce false;
      services.displayManager.gdm.enable = lib.mkForce false;
      services.desktopManager.gnome.enable = lib.mkForce false;

      programs.sway.enable = true;
      services.greetd = {
        enable = true;
        settings.default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd sway";
          user = "greeter";
        };
      };

      security.pam.services.swaylock.howdy.enable = true;
    };
  };
}
