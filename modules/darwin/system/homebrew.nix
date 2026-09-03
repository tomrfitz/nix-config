_: {
  homebrew = {
    enable = true;
    onActivation.autoUpdate = false;
    onActivation.upgrade = false;
    onActivation.cleanup = "uninstall";

    brews = [
      "mole"
    ];

    casks = [
      # browsers
      "helium-browser"
      "orion" # Kagi's browser — paying member, keeping an eye on it
      "zen@twilight"

      # dev tools
      "ghostty"
      "xcodes-app"
      # communication
      "element"
      "signal"
      "wechat"
      "zoom"

      # productivity
      "claude"
      "microsoft-office"

      # media
      "musicbrainz-picard"
      "plex"
      "plex-htpc" # sometimes the better ultrawide player

      # utilities
      "1password"
      "activitywatch"
      "karabiner-elements"
      "batfi"
      "betterdisplay"
      "daisydisk"
      "thaw"
      "keepingyouawake"
      "keyclu"
      "linearmouse"
      "lookaway"
      "loop"
      "maccy"
      "macs-fan-control"
      "mullvad-vpn"
      "tailscale-app"
      "netnewswire"
      "ollama-app"
      "onyx" # the @beta cask requires macOS 27
      "oversight"
      "pearcleaner"
      "pika"
      "shottr"
      "stats"
      "syntax-highlight"

      # editors / writing
      "zed"

      # gaming
      "steam"

      # science / education
      "calibre"
      "zotero"

      # system / network
      "rustdesk"
      "folding-at-home"
      "google-drive"
      "microsoft-auto-update"
      # "pear" — moved to nix (pear-desktop in shared/home/desktop.nix)
      "sf-symbols"
      "tabtab"

      # misc
      "handy"

      # fonts (not in nixpkgs — Apple proprietary)
      "font-sf-mono"
      "font-sf-pro"
    ];

    masApps = {
      "1Password for Safari" = 1569813296;
      "Dark Reader for Safari" = 1438243180;
      "Flighty" = 1358823008;
      "Hand Mirror" = 1502839586;
      "KakaoTalk" = 869223134;
      "One Thing" = 1604176982;
      "RapidClick" = 419891002;
      "Steam Link" = 1246969117;
      "Tot" = 1491071483;
      "Userscripts" = 1463298887;
      "Velja" = 1607635845;
      # "iA Writer" = 775737590; # requires purchase
    };
  };
}
