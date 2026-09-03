{
  config,
  pkgs,
  lib,
  ...
}:
let
  # Build noctalia IPC command list. Args must be single-word tokens (no spaces).
  noctalia =
    cmd:
    [
      "noctalia"
      "msg"
    ]
    ++ (lib.splitString " " cmd);
  inherit (import ../../shared/home/browser-policies.nix) sharedPolicies;
in
{
  home.packages = with pkgs; [
    # 1password installed via programs._1password-gui in system config
    foot # lightweight Wayland terminal
    xwayland-satellite # niri ≥ 25.08 spawns it on demand and exports DISPLAY itself
    wl-clipboard
    brightnessctl
    playerctl
    libnotify
  ];

  # Base browser on the Linux desktop (Zen is primary); the extension/policy
  # manifest is shared with zen.nix.
  programs.firefox = {
    enable = true;
    policies = sharedPolicies;
    # New HM default (stateVersion ≥ 26.05); opt in now rather than carry the
    # legacy ~/.mozilla path.
    configPath = "${config.xdg.configHome}/mozilla/firefox";
  };

  # ── Cursor ───────────────────────────────────────────────────────────
  home.pointerCursor = {
    enable = true;
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
        matches = [ { namespace = "^noctalia-wallpaper$"; } ];
        place-within-backdrop = true;
      }
    ];

    binds = {
      # ── Launch ──────────────────────────────────────────────────────
      "Super+Return".action.spawn = "ghostty";
      "Super+Space".action.spawn = noctalia "panel-toggle launcher";
      "Super+Q".action.close-window = { };
      "Super+F".action.fullscreen-window = { };

      # ── Lock ───────────────────────────────────────────────────────
      "Super+Ctrl+L".action.spawn = noctalia "session lock";

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
      # noctalia starts via its HM systemd unit (programs.noctalia.systemd)
      {
        argv = [
          "1password"
          "--silent"
        ];
      }
    ];
  };

  # Polkit agent provided by nixosModules.niri (KDE polkit)

  # ── Noctalia (desktop shell + theming engine) ────────────────────────
  # v5: config.toml holds the declarative defaults; runtime tweaks persist
  # separately in $XDG_STATE_HOME/noctalia/settings.toml and win on merge.
  # v4→v5 regressions (no v5 equivalent yet): tailscale bar plugin (v5
  # plugin system unreleased), vesktop template (not in the builtin
  # catalog), fixed/mono UI font, per-urgency notification durations.
  programs.noctalia = {
    enable = true;
    # The unit is PartOf graphical-session.target and restarts noctalia
    # whenever config.toml changes on rebuild (replaces spawn-at-startup).
    systemd.enable = true;

    settings = {
      shell = {
        font_family = "Atkinson Hyperlegible Next";
        setup_wizard_enabled = false;
      };

      theme = {
        source = "wallpaper"; # wallpaper-derived Material You colors
        mode = "auto"; # dark/light from [location] sun times
        templates.builtin_ids = [
          "gtk3"
          "gtk4"
          "qt" # writes both qt5ct and qt6ct color files
          "foot"
          "ghostty"
          "emacs" # → ~/.config/emacs/themes/noctalia-theme.el
        ];
      };

      nightlight = {
        enabled = true;
        temperature_night = 3000;
        temperature_day = 6500;
      };

      # IP geolocation feeds weather, night light, and theme auto mode —
      # replaces the v4 GeoIP-via-IPC workaround for
      # https://github.com/noctalia-dev/noctalia-shell/issues/1069
      location.auto_locate = true;

      weather = {
        enabled = true;
        unit = "celsius";
      };

      audio = {
        enable_overdrive = true;
        enable_sounds = false;
      };

      bar.main = {
        position = "top";
        widget_spacing = 6;
        start = [
          "launcher"
          "clock"
          # builtin single-stat sysmon seeds (v4 SystemMonitor widget)
          "cpu"
          "temp"
          "ram"
          "active_window"
          "media"
        ];
        center = [ "workspaces" ];
        end = [
          "tray"
          "notifications"
          "battery"
          "volume"
          "brightness"
          "network"
          "control-center"
        ];
      };

      widget = {
        clock.format = "{:%H:%M %a, %b %d}";
        workspaces = {
          display = "id";
          hide_when_empty = false;
        };
      };

      notification.position = "top_right";
      osd.position = "top_right";

      wallpaper = {
        enabled = true;
        fill_mode = "crop";
        default.path = "${../../../config/wallpaper.jpg}";
      };

      idle = {
        pre_action_fade_seconds = 5.0;
        behavior = {
          lock = {
            enabled = true;
            timeout = 660;
            action = "lock";
          };
          screen-off = {
            enabled = true;
            timeout = 600;
            action = "screen_off";
          };
          # no suspend behavior — functionally headless (v4 suspendTimeout = 0)
        };
      };
    };
  };
}
