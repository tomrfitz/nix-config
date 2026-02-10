{
  config,
  pkgs,
  agenix,
  ...
}:
let
  user = "tomrfitz";
in
{
  system.stateVersion = 5;
  system.primaryUser = user;

  users.users.${user} = {
    name = user;
    home = "/Users/${user}";
    shell = pkgs.zsh;
  };

  # ── Nix ────────────────────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    nix
    agenix.packages.aarch64-darwin.default
  ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # ── Homebrew (GUI apps & fonts not in nixpkgs) ────────────────────────
  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    onActivation.cleanup = "zap";

    taps = [
      "nikitabobko/tap" # aerospace
      "krtirtho/apps" # spotube
      "neved4/tap" # pear
    ];

    casks = [
      # browsers
      "arc"
      "firefox"
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
      "visual-studio-code"
      "xcodes-app"
      "zed"

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
      "obsidian"
      "notesnook"

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
      "1password-cli"
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
      "alacritty"
      "iterm2"
      "kitty"

      # editors / writing
      "codexbar"
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
      "mactex"
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
      "powershell"
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
  };

  # ── macOS system defaults ──────────────────────────────────────────────
  system.defaults = {
    # ── Global (NSGlobalDomain) ──────────────────────────────────────────
    NSGlobalDomain = {
      AppleInterfaceStyleSwitchesAutomatically = true;
      AppleICUForce24HourTime = true;
      AppleMeasurementUnits = "Centimeters";
      AppleMetricUnits = 1;
      AppleTemperatureUnit = "Celsius";
      NSAutomaticCapitalizationEnabled = true;
      NSAutomaticPeriodSubstitutionEnabled = true;
      NSTableViewDefaultSizeMode = 2;
      "com.apple.sound.beep.feedback" = 1;
      "com.apple.trackpad.forceClick" = true;
    };

    # ── Dock ─────────────────────────────────────────────────────────────
    dock = {
      autohide = true;
      autohide-time-modifier = 0.15;
      expose-group-apps = true;
      magnification = true;
      largesize = 89;
      tilesize = 49;
      mru-spaces = false;
      orientation = "bottom";
      show-recents = true;

      # Hot corners
      # 5 = Start Screen Saver, 12 = Notification Center, 14 = Quick Note
      wvous-bl-corner = 5;
      wvous-br-corner = 14;
      wvous-tr-corner = 12;
    };

    # ── Finder ───────────────────────────────────────────────────────────
    finder = {
      _FXShowPosixPathInTitle = true;
      FXPreferredViewStyle = "clmv";
      ShowExternalHardDrivesOnDesktop = true;
      ShowHardDrivesOnDesktop = false;
      ShowMountedServersOnDesktop = true;
      ShowRemovableMediaOnDesktop = true;
      NewWindowTarget = "Home";
    };

    # ── Trackpad ─────────────────────────────────────────────────────────
    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
      TrackpadRightClick = true;
      ActuateDetents = true;
      FirstClickThreshold = 1;
      SecondClickThreshold = 1;
      TrackpadFourFingerHorizSwipeGesture = 2;
      TrackpadFourFingerPinchGesture = 2;
      TrackpadFourFingerVertSwipeGesture = 2;
      TrackpadMomentumScroll = true;
      TrackpadPinch = true;
      TrackpadRotate = true;
      TrackpadTwoFingerDoubleTapGesture = true;
      TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;
      TrackpadThreeFingerHorizSwipeGesture = 0;
      TrackpadThreeFingerVertSwipeGesture = 0;
    };

    # ── Screenshot ───────────────────────────────────────────────────────
    screencapture = {
      location = "/Users/${user}/Documents/Screenshots/";
      target = "file";
      show-thumbnail = false;
    };

    # ── Menu bar clock ───────────────────────────────────────────────────
    menuExtraClock = {
      FlashDateSeparators = true;
      IsAnalog = true;
      ShowAMPM = true;
      ShowDate = 0;
      ShowDayOfWeek = true;
      ShowSeconds = true;
    };

    # ── .DS_Store on network drives ──────────────────────────────────────
    CustomUserPreferences = {
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
      };
      "com.apple.controlcenter" = {
        # 1 = In Full Screen Only
        AutoHideMenuBarOption = 1;
      };
    };
  };
}
