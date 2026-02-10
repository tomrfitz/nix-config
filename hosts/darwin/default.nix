{
  config,
  pkgs,
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
  environment.systemPackages = with pkgs; [ nix ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # ── Homebrew (GUI apps only) ───────────────────────────────────────────
  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    casks = [
      "ghostty"
      "zed"
      "visual-studio-code"
      "slack"
      "discord"
      "firefox"
      "google-chrome"
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
