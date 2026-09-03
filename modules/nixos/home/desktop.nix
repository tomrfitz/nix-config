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

  # ── Niri ────────────────────────────────────────────────────────────
  # nixpkgs' programs.niri (modules/nixos/system/desktop.nix) supplies the
  # session, user units, gnome + gtk portals with niri's portal config,
  # gnome-keyring, swaylock PAM, dconf and polkit (the agent is our
  # polkit-agent unit, same file). This module renders config.kdl
  # (checkConfig runs `niri validate` at build time) and adds niri (the same
  # store path as the system install) and xwayland-satellite to
  # home.packages. Generic KDL encoding: str/num/bool → single argument,
  # { } → leaf node, _props → properties, _children → ordered or repeated
  # nodes.
  wayland.windowManager.niri = {
    enable = true;
    # The NixOS module already installs niri's units via systemd.packages
    # (plus its restartIfChanged/PATH drop-in); don't add a second source.
    systemd.enable = false;
    # Portals and their config are system-side (xdg.portal.config.niri →
    # /etc/xdg/xdg-desktop-portal/niri-portals.conf); a user-level
    # portals.conf would shadow it, so nothing portal-related lives in HM.
    portalPackage = null;

    settings = {
      prefer-no-csd = { };
      environment.NIXOS_OZONE_WL = "1";

      # Required for Noctalia notification actions and window activation
      debug.honor-xdg-activation-with-invalid-serial = { };

      input.touchpad = {
        tap = { };
        natural-scroll = { };
        dwt = { };
      };

      # Stationary wallpaper: Noctalia draws wallpaper as a layer surface,
      # niri's background becomes transparent so it shows through.
      overview.workspace-shadow.off = { };
      layout = {
        background-color = "transparent";
        gaps = 5;
        struts = {
          left = 4;
          right = 4;
          top = 4;
          bottom = 4;
        };
        preset-column-widths._children = [
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

      # Repeated top-level nodes; rules apply in order of appearance.
      _children = [
        # Global corner radius
        {
          window-rule = {
            geometry-corner-radius = 4;
            clip-to-geometry = true;
          };
        }
        # Firefox PiP → floating
        {
          window-rule = {
            match._props = {
              app-id = "^firefox$";
              title = "^Picture-in-Picture$";
            };
            open-floating = true;
          };
        }
        # 1Password — hide from screencasts/screenshots
        {
          window-rule = {
            match._props.app-id = "^1Password$";
            block-out-from = "screen-capture";
          };
        }
        {
          layer-rule = {
            match._props.namespace = "^noctalia-wallpaper$";
            place-within-backdrop = true;
          };
        }
      ];

      binds = {
        # ── Launch ──────────────────────────────────────────────────────
        "Super+Return".spawn = [ "ghostty" ];
        "Super+Space".spawn = noctalia "panel-toggle launcher";
        "Super+Q".close-window = { };
        "Super+F".fullscreen-window = { };

        # ── Lock ───────────────────────────────────────────────────────
        "Super+Ctrl+L".spawn = noctalia "session lock";

        # ── Focus (vim-style) ───────────────────────────────────────────
        "Super+H".focus-column-left = { };
        "Super+J".focus-window-down = { };
        "Super+K".focus-window-up = { };
        "Super+L".focus-column-right = { };

        # ── Move ────────────────────────────────────────────────────────
        "Super+Shift+H".move-column-left = { };
        "Super+Shift+J".move-window-down = { };
        "Super+Shift+K".move-window-up = { };
        "Super+Shift+L".move-column-right = { };

        # ── Column management ───────────────────────────────────────────
        "Super+BracketLeft".consume-or-expel-window-left = { };
        "Super+BracketRight".consume-or-expel-window-right = { };
        "Super+R".switch-preset-column-width = { };
        "Super+C".center-column = { };
        "Super+T".toggle-column-tabbed-display = { };
        "Super+W".maximize-column = { };
        "Super+Ctrl+F".expand-column-to-available-width = { };

        # ── Floating ────────────────────────────────────────────────────
        "Super+Shift+F".toggle-window-floating = { };
        "Super+V".switch-focus-between-floating-and-tiling = { };

        # ── Resize ──────────────────────────────────────────────────────
        "Super+Minus".set-column-width = "-10%";
        "Super+Equal".set-column-width = "+10%";
        "Super+Shift+Minus".set-window-height = "-10%";
        "Super+Shift+Equal".set-window-height = "+10%";
        "Super+Shift+R".reset-window-height = { };

        # ── Workspace nav ───────────────────────────────────────────────
        "Super+Tab".focus-workspace-previous = { };
        "Super+U".focus-workspace-up = { };
        "Super+I".focus-workspace-down = { };
        "Super+Shift+U".move-window-to-workspace-up = { };
        "Super+Shift+I".move-window-to-workspace-down = { };

        # Workspace by index
        "Super+1".focus-workspace = 1;
        "Super+2".focus-workspace = 2;
        "Super+3".focus-workspace = 3;
        "Super+4".focus-workspace = 4;
        "Super+5".focus-workspace = 5;
        "Super+6".focus-workspace = 6;
        "Super+7".focus-workspace = 7;
        "Super+8".focus-workspace = 8;
        "Super+9".focus-workspace = 9;
        "Super+Shift+1".move-window-to-workspace = 1;
        "Super+Shift+2".move-window-to-workspace = 2;
        "Super+Shift+3".move-window-to-workspace = 3;
        "Super+Shift+4".move-window-to-workspace = 4;
        "Super+Shift+5".move-window-to-workspace = 5;
        "Super+Shift+6".move-window-to-workspace = 6;
        "Super+Shift+7".move-window-to-workspace = 7;
        "Super+Shift+8".move-window-to-workspace = 8;
        "Super+Shift+9".move-window-to-workspace = 9;

        # ── Column position ─────────────────────────────────────────────
        "Super+Home".focus-column-first = { };
        "Super+End".focus-column-last = { };
        "Super+Shift+Home".move-column-to-first = { };
        "Super+Shift+End".move-column-to-last = { };

        # ── System ──────────────────────────────────────────────────────
        "Super+Shift+E".quit._props.skip-confirmation = true;
        "Super+Shift+P".power-off-monitors = { };
        "Super+O".toggle-overview = { };
        "Super+Escape" = {
          _props.allow-inhibiting = false;
          toggle-keyboard-shortcuts-inhibit = { };
        };

        # ── Screenshots (niri built-in) ─────────────────────────────────
        "Super+Shift+S".screenshot = { };
        "Print".screenshot-screen = { };
        "Super+Print".screenshot-window = { };

        # ── Media keys (allow-when-locked) ──────────────────────────────
        "XF86AudioRaiseVolume" = {
          _props.allow-when-locked = true;
          spawn = [
            "wpctl"
            "set-volume"
            "@DEFAULT_AUDIO_SINK@"
            "5%+"
          ];
        };
        "XF86AudioLowerVolume" = {
          _props.allow-when-locked = true;
          spawn = [
            "wpctl"
            "set-volume"
            "@DEFAULT_AUDIO_SINK@"
            "5%-"
          ];
        };
        "XF86AudioMute" = {
          _props.allow-when-locked = true;
          spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };
        "XF86AudioMicMute" = {
          _props.allow-when-locked = true;
          spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        };
        "XF86MonBrightnessUp" = {
          _props.allow-when-locked = true;
          spawn = [
            "brightnessctl"
            "set"
            "+5%"
          ];
        };
        "XF86MonBrightnessDown" = {
          _props.allow-when-locked = true;
          spawn = [
            "brightnessctl"
            "set"
            "5%-"
          ];
        };
        "XF86AudioPlay" = {
          _props.allow-when-locked = true;
          spawn-sh = "playerctl play-pause";
        };
        "XF86AudioNext" = {
          _props.allow-when-locked = true;
          spawn-sh = "playerctl next";
        };
        "XF86AudioPrev" = {
          _props.allow-when-locked = true;
          spawn-sh = "playerctl previous";
        };
      };

      # noctalia starts via its HM systemd unit (programs.noctalia.systemd)
      spawn-at-startup = [
        "1password"
        "--silent"
      ];
    };
  };

  # ── Noctalia (desktop shell + theming engine) ────────────────────────
  # nixpkgs' package through home-manager's programs.noctalia (the flake
  # input only tracked HEAD; its module was option-for-option the same).
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
        launch_apps_as_systemd_services = true; # recommended alongside systemd.enable
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
          label_source = "id";
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
