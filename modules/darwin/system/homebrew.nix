{ ... }:
{
  homebrew = {
    enable = true;
    onActivation.autoUpdate = false;
    onActivation.upgrade = false;
    onActivation.cleanup = "uninstall";

    taps = [
      "d12frosted/emacs-plus" # emacs-plus
      "nikitabobko/tap" # aerospace
      "krtirtho/apps" # spotube
    ];

    brews = [
      "mole"
    ];

    casks = [
      # browsers
      "arc"
      "firefox@nightly"
      "google-chrome@canary"
      "helium-browser"
      "orion"
      "safari-technology-preview"
      "thebrowsercompany-dia"
      "vivaldi"
      "vivaldi@snapshot"
      "zen@twilight"

      # dev tools
      "docker-desktop"
      "ghostty"
      "jetbrains-toolbox"
      "xcodes-app"
      "emacs-plus-app"

      # communication
      "element"
      "microsoft-teams"
      "signal"
      "wechat"
      "zoom"

      # productivity
      "chatgpt"
      "chatgpt-atlas"
      "claude"
      "codex"
      "copilot-cli"
      "microsoft-office"

      # media
      "musicbrainz-picard"
      "handbrake-app"
      "iina"
      "plex"
      "plex-htpc"
      "pocket-casts"
      "spotify"
      "spotube"
      "vlc"

      # utilities
      "1password"
      "activitywatch"
      "aerospace"
      "applite"
      "batfi"
      "betterdisplay"
      "daisydisk"
      "grandperspective"
      "imageoptim"
      "thaw"
      "keepingyouawake"
      "keyboardcleantool"
      "keyclu"
      "linearmouse"
      "lookaway"
      "loop"
      "maccy"
      "macs-fan-control"
      "mist"
      "mullvad-vpn"
      "tailscale-app"
      "netnewswire"
      "ollama-app"
      "onyx@beta"
      "oversight"
      "pearcleaner"
      "pika"
      "shottr"
      "stats"
      "syntax-highlight"
      "transnomino"
      "utm"

      # terminals
      "iterm2"

      # editors / writing
      "zed"

      # creative / design
      "figma"
      "fontforge-app"
      "fontlab"
      "icon-composer"
      "monodraw"

      # gaming
      "league-of-legends"
      "minecraft"
      "openemu"
      "osu"
      "steam"

      # science / education
      "calibre"
      "libreoffice"

      # system / network
      "rustdesk"
      "crystalfetch"
      "folding-at-home"
      "google-drive"
      "microsoft-auto-update"
      "multipatch"
      # "pear" — moved to nix (pear-desktop in shared/home/packages.nix)
      "sabnzbd"
      "sf-symbols"
      "tabtab"
      "teamspeak-client"

      # crypto
      "bluewallet"

      # misc
      "handy"
      "codex-app"

      # fonts (not in nixpkgs — Apple proprietary)
      "font-sf-mono"
      "font-sf-pro"
    ];

    masApps = {
      "1Password for Safari" = 1569813296;
      "Dark Reader for Safari" = 1438243180;
      "Dropover" = 1355679052;
      "Flighty" = 1358823008;
      "Hand Mirror" = 1502839586;
      "Infuse" = 1136220934;
      "KakaoTalk" = 869223134;
      "One Thing" = 1604176982;
      "RapidClick" = 419891002;
      "Steam Link" = 1246969117;
      "TestFlight" = 899247664;
      "Tot" = 1491071483;
      "Userscripts" = 1463298887;
      "Velja" = 1607635845;
      # "iA Writer" = 775737590; # requires purchase
    };
  };
}
