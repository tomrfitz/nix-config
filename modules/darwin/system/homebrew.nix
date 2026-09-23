_: {
  homebrew = {
    enable = true;
    # Every switch updates Homebrew and upgrades everything it manages,
    # including casks that update themselves (greedy) and App Store apps.
    # Casks whose uninstall step quits their app close it on upgrade, and brew
    # does not relaunch it; .pkg casks ask for Touch ID.
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    onActivation.cleanup = "uninstall";
    # Stream the upgrades' own output (downloads, installer steps); without it
    # brew bundle captures that and prints one line per package.
    onActivation.extraFlags = [ "--verbose" ];
    greedyCasks = true;

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
      # Microsoft AutoUpdate patches Office in place; a greedy upgrade would
      # reinstall the whole multi-GB .pkg for every version bump instead.
      {
        name = "microsoft-office";
        greedy = false;
      }

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
      {
        name = "microsoft-auto-update"; # updates itself; see microsoft-office
        greedy = false;
      }
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
