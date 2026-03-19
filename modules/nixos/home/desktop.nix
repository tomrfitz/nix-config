{
  pkgs,
  lib,
  config,
  ...
}:
let
  # Build noctalia IPC command list. Args must be single-word tokens (no spaces).
  noctalia =
    cmd:
    [
      "noctalia-shell"
      "ipc"
      "call"
    ]
    ++ (lib.splitString " " cmd);

  # Noctalia settings deployed as a mutable copy (not HM symlink) so that
  # the GeoIP service can update location.name at runtime. HM activation
  # re-copies the base config on each rebuild; the GeoIP service patches
  # location.name on top after noctalia starts.
  noctaliaSettings = {
    colorSchemes = {
      useWallpaperColors = true;
      darkMode = true;
      schedulingMode = "location";
    };
    templates = {
      activeTemplates = [
        "gtk3"
        "gtk4"
        "qt6ct"
        "foot"
        "ghostty"
        "emacs"
        "vesktop"
      ];
      enableUserTheming = false;
    };
    ui = {
      fontDefault = "Atkinson Hyperlegible Next";
      fontFixed = "Atkinson Hyperlegible Mono";
    };
    nightLight = {
      enabled = true;
      autoSchedule = true;
      nightTemp = "3000";
      dayTemp = "6500";
    };
    location = {
      weatherEnabled = true;
      useFahrenheit = false;
      use12hourFormat = false;
    };
    appLauncher = {
      enableClipboardHistory = true;
      terminalCommand = "ghostty -e";
      enableWindowsSearch = true;
      enableSessionSearch = true;
    };
    bar = {
      position = "top";
      density = "compact";
      widgetSpacing = 6;
      displayMode = "always_visible";
      widgets = {
        left = [
          { id = "Launcher"; }
          { id = "Clock"; }
          { id = "SystemMonitor"; }
          { id = "ActiveWindow"; }
          { id = "MediaMini"; }
        ];
        center = [
          { id = "Workspace"; }
        ];
        right = [
          { id = "Tray"; }
          { id = "NotificationHistory"; }
          { id = "Battery"; }
          { id = "Volume"; }
          { id = "Brightness"; }
          { id = "Network"; }
          { id = "ControlCenter"; }
        ];
      };
    };
    widgetSettings.bar = {
      Workspace = {
        labelMode = "index";
        hideUnoccupied = false;
        enableScrollWheel = true;
      };
      SystemMonitor = {
        compactMode = true;
        useMonospaceFont = true;
        showCpuUsage = true;
        showCpuTemp = true;
        showMemoryUsage = true;
        showMemoryAsPercent = false;
        showDiskUsage = false;
        showNetworkStats = false;
      };
      Clock.formatHorizontal = "HH:mm ddd, MMM dd";
    };
    notifications = {
      enabled = true;
      location = "top_right";
      lowUrgencyDuration = 3;
      normalUrgencyDuration = 8;
      criticalUrgencyDuration = 15;
      sounds.enabled = false;
    };
    osd = {
      enabled = true;
      location = "top_right";
      autoHideMs = 2000;
    };
    wallpaper = {
      enabled = true;
      fillMode = "crop";
    };
    idle = {
      enabled = true;
      screenOffTimeout = 600;
      lockTimeout = 660;
      suspendTimeout = 0; # never suspend — functionally headless
      fadeDuration = 5;
    };
    general = {
      lockOnSuspend = true;
      enableLockScreenCountdown = true;
      lockScreenCountdownDuration = 10000;
      autoStartAuth = true;
      allowPasswordWithFprintd = true;
      showChangelogOnStartup = false;
    };
    audio.volumeOverdrive = true;
  };

  noctaliaSettingsFile = (pkgs.formats.json { }).generate "noctalia-settings.json" noctaliaSettings;

  # GeoIP → Noctalia IPC: detect city from IP, push via IPC (triggers geocode
  # + weather refresh; Noctalia's save timer persists to mutable settings.json).
  # ref: https://github.com/noctalia-dev/noctalia-shell/issues/1069
  noctalia-geoip = pkgs.writeShellScript "noctalia-geoip" ''
    for attempt in 1 2 3; do
      city=$(${pkgs.curl}/bin/curl -sf --max-time 5 "http://ip-api.com/line/?fields=city") && break
      sleep 10
    done
    [ -n "$city" ] && noctalia-shell ipc call location set "$city"
  '';
in
{
  home.packages = with pkgs; [
    # 1password installed via programs._1password-gui in system config
    foot # lightweight Wayland terminal
    xwayland-satellite
    wl-clipboard
    brightnessctl
    playerctl
    libnotify
  ];

  # ── Cursor ───────────────────────────────────────────────────────────
  home.pointerCursor = {
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
    gtk.enable = true;
  };

  # ── Portal (freedesktop dark preference for apps) ────────────────────
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  # ── Niri ────────────────────────────────────────────────────────────
  # nixosModules.niri provides: polkit agent, xdg-desktop-portal-gnome,
  # GNOME keyring, dconf, opengl, default fonts, swaylock PAM, binary cache
  programs.niri.settings = {
    prefer-no-csd = true;
    environment."NIXOS_OZONE_WL" = "1";

    # Required for Noctalia notification actions and window activation
    debug.honor-xdg-activation-with-invalid-serial = { };

    input = {
      keyboard.xkb = { };
      touchpad = {
        tap = true;
        natural-scroll = true;
        dwt = true;
      };
    };

    # Stationary wallpaper: Noctalia draws wallpaper as a layer surface,
    # niri's background becomes transparent so it shows through.
    overview.workspace-shadow.enable = false;
    layout = {
      background-color = "transparent";
      gaps = 5;
      struts = {
        left = 4;
        right = 4;
        top = 4;
        bottom = 4;
      };
      preset-column-widths = [
        { proportion = 0.33333; }
        { proportion = 0.5; }
        { proportion = 0.66667; }
        { proportion = 0.75; }
        { proportion = 1.0; }
      ];
      default-column-width.proportion = 0.5;
    };

    # No named workspaces — embrace niri's scrolling model.
    # Dynamic workspaces are created/destroyed as needed.

    window-rules = [
      # Global corner radius
      {
        geometry-corner-radius =
          let
            r = 4.0;
          in
          {
            top-left = r;
            top-right = r;
            bottom-left = r;
            bottom-right = r;
          };
        clip-to-geometry = true;
      }
      # Firefox PiP → floating
      {
        matches = [
          {
            app-id = "^firefox$";
            title = "^Picture-in-Picture$";
          }
        ];
        open-floating = true;
      }
      # 1Password — hide from screencasts/screenshots
      {
        matches = [ { app-id = "^1Password$"; } ];
        block-out-from = "screen-capture";
      }
    ];

    layer-rules = [
      {
        matches = [ { namespace = "^noctalia-wallpaper.*"; } ];
        place-within-backdrop = true;
      }
    ];

    binds = {
      # ── Launch ──────────────────────────────────────────────────────
      "Super+Return".action.spawn = "ghostty";
      "Super+Space".action.spawn = noctalia "launcher toggle";
      "Super+Q".action.close-window = { };
      "Super+F".action.fullscreen-window = { };

      # ── Lock ───────────────────────────────────────────────────────
      "Super+Ctrl+L".action.spawn = noctalia "lockScreen lock";

      # ── Focus (vim-style) ───────────────────────────────────────────
      "Super+H".action.focus-column-left = { };
      "Super+J".action.focus-window-down = { };
      "Super+K".action.focus-window-up = { };
      "Super+L".action.focus-column-right = { };

      # ── Move ────────────────────────────────────────────────────────
      "Super+Shift+H".action.move-column-left = { };
      "Super+Shift+J".action.move-window-down = { };
      "Super+Shift+K".action.move-window-up = { };
      "Super+Shift+L".action.move-column-right = { };

      # ── Column management ───────────────────────────────────────────
      "Super+BracketLeft".action.consume-or-expel-window-left = { };
      "Super+BracketRight".action.consume-or-expel-window-right = { };
      "Super+R".action.switch-preset-column-width = { };
      "Super+C".action.center-column = { };
      "Super+T".action.toggle-column-tabbed-display = { };
      "Super+W".action.maximize-column = { };
      "Super+Ctrl+F".action.expand-column-to-available-width = { };

      # ── Floating ────────────────────────────────────────────────────
      "Super+Shift+F".action.toggle-window-floating = { };
      "Super+V".action.switch-focus-between-floating-and-tiling = { };

      # ── Resize ──────────────────────────────────────────────────────
      "Super+Minus".action.set-column-width = "-10%";
      "Super+Equal".action.set-column-width = "+10%";
      "Super+Shift+Minus".action.set-window-height = "-10%";
      "Super+Shift+Equal".action.set-window-height = "+10%";
      "Super+Shift+R".action.reset-window-height = { };

      # ── Workspace nav ───────────────────────────────────────────────
      "Super+Tab".action.focus-workspace-previous = { };
      "Super+U".action.focus-workspace-up = { };
      "Super+I".action.focus-workspace-down = { };
      "Super+Shift+U".action.move-window-to-workspace-up = { };
      "Super+Shift+I".action.move-window-to-workspace-down = { };

      # Workspace by index
      "Super+1".action.focus-workspace = 1;
      "Super+2".action.focus-workspace = 2;
      "Super+3".action.focus-workspace = 3;
      "Super+4".action.focus-workspace = 4;
      "Super+5".action.focus-workspace = 5;
      "Super+6".action.focus-workspace = 6;
      "Super+7".action.focus-workspace = 7;
      "Super+8".action.focus-workspace = 8;
      "Super+9".action.focus-workspace = 9;
      "Super+Shift+1".action.move-window-to-workspace = 1;
      "Super+Shift+2".action.move-window-to-workspace = 2;
      "Super+Shift+3".action.move-window-to-workspace = 3;
      "Super+Shift+4".action.move-window-to-workspace = 4;
      "Super+Shift+5".action.move-window-to-workspace = 5;
      "Super+Shift+6".action.move-window-to-workspace = 6;
      "Super+Shift+7".action.move-window-to-workspace = 7;
      "Super+Shift+8".action.move-window-to-workspace = 8;
      "Super+Shift+9".action.move-window-to-workspace = 9;

      # ── Column position ─────────────────────────────────────────────
      "Super+Home".action.focus-column-first = { };
      "Super+End".action.focus-column-last = { };
      "Super+Shift+Home".action.move-column-to-first = { };
      "Super+Shift+End".action.move-column-to-last = { };

      # ── System ──────────────────────────────────────────────────────
      "Super+Shift+E".action.quit = {
        skip-confirmation = true;
      };
      "Super+Shift+P".action.power-off-monitors = { };
      "Super+O".action.toggle-overview = { };
      "Super+Escape" = {
        allow-inhibiting = false;
        action.toggle-keyboard-shortcuts-inhibit = { };
      };

      # ── Screenshots (niri built-in) ─────────────────────────────────
      "Super+Shift+S".action.screenshot = { };
      "Print".action.screenshot-screen = { };
      "Super+Print".action.screenshot-window = { };

      # ── Media keys (allow-when-locked) ──────────────────────────────
      "XF86AudioRaiseVolume" = {
        allow-when-locked = true;
        action.spawn = [
          "wpctl"
          "set-volume"
          "@DEFAULT_AUDIO_SINK@"
          "5%+"
        ];
      };
      "XF86AudioLowerVolume" = {
        allow-when-locked = true;
        action.spawn = [
          "wpctl"
          "set-volume"
          "@DEFAULT_AUDIO_SINK@"
          "5%-"
        ];
      };
      "XF86AudioMute" = {
        allow-when-locked = true;
        action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      };
      "XF86AudioMicMute" = {
        allow-when-locked = true;
        action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
      };
      "XF86MonBrightnessUp" = {
        allow-when-locked = true;
        action.spawn = [
          "brightnessctl"
          "set"
          "+5%"
        ];
      };
      "XF86MonBrightnessDown" = {
        allow-when-locked = true;
        action.spawn = [
          "brightnessctl"
          "set"
          "5%-"
        ];
      };
      "XF86AudioPlay" = {
        allow-when-locked = true;
        action.spawn-sh = "playerctl play-pause";
      };
      "XF86AudioNext" = {
        allow-when-locked = true;
        action.spawn-sh = "playerctl next";
      };
      "XF86AudioPrev" = {
        allow-when-locked = true;
        action.spawn-sh = "playerctl previous";
      };
    };

    spawn-at-startup = [
      { argv = [ "xwayland-satellite" ]; }
      {
        argv = [
          "1password"
          "--silent"
        ];
      }
    ];
  };

  # ── Auto-detect location via GeoIP → Noctalia IPC ────────────────────
  # ref: https://github.com/noctalia-dev/noctalia-shell/issues/1069
  systemd.user.services.noctalia-location = {
    Unit = {
      Description = "Set Noctalia location from GeoIP";
      After = [ "noctalia-shell.service" ];
    };
    Install.WantedBy = [ "noctalia-shell.service" ];
    Service = {
      Type = "oneshot";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 3"; # wait for IPC socket
      ExecStart = noctalia-geoip;
    };
  };

  # ── Wallpaper ─────────────────────────────────────────────────────────
  # Noctalia reads wallpaper paths from this cache file.
  # The image itself is deployed to the store; Noctalia picks up colors from it.
  home.file.".cache/noctalia/wallpapers.json".text = builtins.toJSON {
    defaultWallpaper = "${../../../config/wallpaper.jpg}";
  };

  # Polkit agent provided by nixosModules.niri (KDE polkit)

  # ── Noctalia (desktop shell + theming engine) ────────────────────────
  # Settings managed as mutable copy (see noctaliaSettings in let block)
  # so the GeoIP service can patch location.name at runtime.
  home.activation.noctalia-settings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    install -Dm644 ${noctaliaSettingsFile} "$HOME/.config/noctalia/settings.json"
  '';

  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;
    plugins = {
      sources = [
        {
          enabled = true;
          name = "Noctalia Plugins";
          url = "https://github.com/noctalia-dev/noctalia-plugins";
        }
      ];
      states = {
        tailscale = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
      };
      version = 2;
    };
  };
}
