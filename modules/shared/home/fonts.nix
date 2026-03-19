{ ... }:
{
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [
        "Atkinson Hyperlegible Next"
        "Pretendard"
        "Noto Sans CJK SC"
      ];
      serif = [
        "Iosevka Etoile"
        "Noto Sans CJK SC"
      ];
      monospace = [
        "Atkinson Hyperlegible Mono"
        "Noto Sans Mono CJK SC"
      ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
