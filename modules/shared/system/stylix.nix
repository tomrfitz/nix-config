{ pkgs, ... }:
{
  stylix = {
    enable = true;
    autoEnable = true;
    image = ../../../config/wallpaper.jpg;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/flexoki-dark.yaml";
    polarity = "dark";

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
