{ pkgs, lib, ... }:
{
  stylix = {
    enable = true;
    autoEnable = true;
    image = ../../../config/wallpaper.jpg;
    base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/flexoki-dark.yaml";
    polarity = lib.mkDefault "dark";

    cursor = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };

    fonts.sizes = {
      applications = 12;
      desktop = 12;
      popups = 12;
      terminal = 12;
    };

    fonts = {
      sansSerif = {
        package = pkgs.atkinson-hyperlegible-next;
        name = "Atkinson Hyperlegible Next";
      };
      serif = {
        package = pkgs.iosevka-bin.override { variant = "Etoile"; };
        name = "Iosevka Etoile";
      };
      monospace = {
        package = pkgs.atkinson-hyperlegible-mono;
        name = "Atkinson Hyperlegible Mono";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };
  };
}
