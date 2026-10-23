_: {
  # App Store apps through nix-darwin's own module rather than homebrew.masApps:
  # a nix-built mas runs at activation as the primary user, independent of brew
  # bundle, and also upgrades them (`update` defaults on). Installs end in
  # `|| true`, so a failed one never stops activation. Only the App Store can
  # put these apps on disk; mas can install only what the Apple ID already owns,
  # and it can't see iOS apps (Overcast).
  programs.mas = {
    enable = true;
    packages = {
      "1Password for Safari" = 1569813296;
      "Dark Reader for Safari" = 1438243180;
      "Flighty" = 1358823008;
      "Hand Mirror" = 1502839586;
      "Headjust" = 6759303637;
      "KakaoTalk" = 869223134;
      "RapidClick" = 419891002;
      "Steam Link" = 1246969117;
      "Userscripts" = 1463298887;
      "Velja" = 1607635845;
    };
  };
}
