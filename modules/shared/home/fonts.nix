{ ... }:
{
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [ "Atkinson Hyperlegible Next" ];
      serif = [ "Iosevka Etoile" ];
      monospace = [ "Atkinson Hyperlegible Mono" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
