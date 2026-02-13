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
      "neved4/tap" # pear
    ];

    brews = [
      "mole"
    ];

    casks = [
      # browsers
      "arc"
      "firefox@developer-edition"
      "firefox@nightly"
      "floorp"
      "google-chrome"
      "google-chrome@canary"
      "helium-browser"
      "orion"
      "safari-technology-preview"
      "thebrowsercompany-dia"
      "vivaldi"
      "vivaldi@snapshot"
      "zen"
      "zen@twilight"

      # dev tools
      "docker-desktop"
      "ghostty"
      "jetbrains-toolbox"
      "xcodes-app"
      "emacs-plus-app"

      # communication
      "discord"
      "element"
      "microsoft-teams"
      "signal"
      "slack"
      "vesktop"
      "wechat"
      "zoom"

      # productivity
      "chatgpt"
      "chatgpt-atlas"
      "claude"
      "claude-code"
      "codex"
      "copilot-cli"
      "microsoft-office"
      "notesnook"
      # obsidian — installed via nix (cross-platform) in shared/home/packages.nix

      # media
      "audacity"
      "handbrake-app"
      "iina"
      "musicbrainz-picard"
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
      "jordanbaird-ice"
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
      "db-browser-for-sqlite"
      "lapce"
      "nvalt"

      # creative / design
      "figma"
      "fontforge-app"
      "fontlab"
      "icon-composer"
      "inkscape"
      "monodraw"

      # gaming
      "league-of-legends"
      "minecraft"
      "openemu"
      "osu"
      "prismlauncher"
      "steam"

      # science / education
      "anki"
      "calibre"
      "libreoffice"
      "praat"
      "racket"
      "zotero"

      # system / network
      "chatterino"
      "crystalfetch"
      "folding-at-home"
      "google-drive"
      "microsoft-auto-update"
      "multipatch"
      "pear"
      "qbittorrent"
      "rustdesk"
      "sabnzbd"
      "sf-symbols"
      "tabtab"
      "teamspeak-client"
      "thunderbird"

      # crypto
      "bluewallet"

      # misc
      "antigravity"
      "handy"

      # fonts (not in nixpkgs — Apple proprietary or missing)
      "font-iosevka-aile"
      "font-iosevka-etoile"
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
