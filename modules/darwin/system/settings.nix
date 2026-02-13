{ user, ... }:
{
  system.defaults = {
    # ── Global (NSGlobalDomain) ──────────────────────────────────────────
    NSGlobalDomain = {
      AppleInterfaceStyleSwitchesAutomatically = true;
      AppleICUForce24HourTime = true;
      AppleMeasurementUnits = "Centimeters";
      AppleMetricUnits = 1;
      AppleTemperatureUnit = "Celsius";
      AppleWindowTabbingMode = "always";
      NSAutomaticCapitalizationEnabled = true;
      NSAutomaticPeriodSubstitutionEnabled = true;
      NSTableViewDefaultSizeMode = 2;
      "com.apple.sound.beep.feedback" = 1;
      "com.apple.springing.delay" = 0.5;
      "com.apple.springing.enabled" = true;
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
      showAppExposeGestureEnabled = true;
      showhidden = true;

      persistent-apps = [
        { app = "/System/Applications/Apps.app"; }
        { app = "/System/Applications/System Settings.app"; }
        { app = "/Users/${user}/Applications/Home Manager Apps/Zotero.app"; }
        { app = "/Users/${user}/Applications/Home Manager Apps/Obsidian.app"; }
        { app = "/Users/${user}/Applications/Home Manager Apps/YouTube Music.app"; }
        { app = "/System/Applications/Messages.app"; }
        { app = "/System/Applications/Mail.app"; }
        { app = "/Applications/Twilight.app"; }
        { app = "/Applications/Ghostty.app"; }
        { app = "/Users/${user}/Applications/Home Manager Apps/Zed.app"; }
      ];

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
      FXRemoveOldTrashItems = true;
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

    # ── Universal access ──────────────────────────────────────────────────
    universalaccess = {
      closeViewScrollWheelToggle = true; # Ctrl+scroll to zoom
    };

    # ── Custom preferences (no typed nix-darwin options) ─────────────────
    CustomUserPreferences = {
      # Extra NSGlobalDomain keys without typed nix-darwin options
      NSGlobalDomain = {
        AppleLanguages = [
          "en-US"
          "it-US"
          "ko-US"
          "fr-US"
          "es-US"
          "zh-Hans-US"
        ];
        AppleLocale = "en_US@calendar=iso8601";
        AppleFirstWeekday = {
          gregorian = 2;
        }; # Monday
        AppleICUDateFormatStrings = {
          "1" = "yyyy-MM-dd";
          "2" = "yyyy-MM-dd 'Week' W";
          "3" = "yyyy-MM-dd 'Week' W, EEEE";
          "4" = "yyyy-MM-dd'T'HH:mm:ss";
        };
      };
      "com.apple.dock" = {
        "recent-count" = 5;
      };
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
      };
      "com.apple.controlcenter" = {
        # 1 = In Full Screen Only
        AutoHideMenuBarOption = 1;
      };
      "com.apple.WindowManager" = {
        EnableTiledWindowMargins = false; # No gaps between tiled windows
        HideDesktop = true; # Hide desktop when clicking wallpaper
        AppWindowGroupingBehavior = true; # Group windows by app
      };
      "com.apple.Safari" = {
        AutoFillFromAddressBook = false;
        AutoFillPasswords = false;
        AutoFillFromiCloudKeychain = false;
        AutoFillMiscellaneousForms = false;
        EnableNarrowTabs = true; # Compact tab bar
        SearchProviderShortName = "Google";
        ShowSidebarInNewWindows = false;
      };
      "com.apple.finder" = {
        ShowSidebar = true;
      };
      "com.apple.spaces" = {
        "spans-displays" = false; # Independent spaces per display
      };
    };
  };
}
