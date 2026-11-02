{
  config,
  lib,
  user,
  ...
}:
let
  hyper = key: "ctrl + alt + cmd - ${key}";
  hyperShift = key: "ctrl + alt + cmd + shift - ${key}";
in
{
  # paneru's module logs to /tmp, which macOS empties at boot — so the one
  # time the log mattered (the 2026-09-03 input freeze that ended in a forced
  # restart) it was gone. Keep it under ~/Library/Logs instead.
  launchd.user.agents.paneru.serviceConfig = {
    StandardOutPath = lib.mkForce "${config.users.users.${user}.home}/Library/Logs/paneru.log";
    StandardErrorPath = lib.mkForce "${config.users.users.${user}.home}/Library/Logs/paneru.err.log";
  };

  services.paneru = {
    enable = true;
    settings = {
      options = {
        focus_follows_mouse = false;
        mouse_follows_focus = false;
        preset_column_widths = [
          0.33
          0.5
          0.67
          0.75
          1.0
        ];
        animation_speed = 4000;
        auto_center = false;
        # Workspaces come and go as in niri: moving south past the last one
        # opens a new one, and an emptied one closes
        create_virtual_workspace_automatically = true;
        reap_empty_workspaces = true;
      };

      # Trackpad: a four-finger horizontal swipe scrolls the column strip. The
      # vertical swipe (switches virtual workspaces) is off — it kept firing on
      # ordinary drags. Padding (0), direction (Natural) and the active-window
      # border (off) are upstream defaults, so they are not restated here.
      swipe.gesture = {
        fingers_count = 4;
        vertical = false;
      };

      # Hyper (Left Control, config/karabiner.json) acts and Hyper+Shift moves,
      # the way Super and Super+Shift do in niri on trfnix
      # (modules/nixos/home/desktop.nix); keys follow niri's wherever paneru
      # has the same command. Emacs binds nothing on C-M-s-, so none of this
      # shadows it. C and E stay Karabiner's Emacs keys, so centring is on X.
      bindings = {
        window_focus_west = hyper "h";
        window_focus_south = hyper "j";
        window_focus_north = hyper "k";
        window_focus_east = hyper "l";
        window_swap_west = hyperShift "h";
        window_swap_south = hyperShift "j";
        window_swap_north = hyperShift "k";
        window_swap_east = hyperShift "l";

        # niri's Home/End; the laptop has them only behind fn, so the arrows too
        window_focus_first = map hyper [
          "home"
          "leftarrow"
        ];
        window_focus_last = map hyper [
          "end"
          "rightarrow"
        ];
        window_swap_first = map hyperShift [
          "home"
          "leftarrow"
        ];
        window_swap_last = map hyperShift [
          "end"
          "rightarrow"
        ];

        # Together these give niri's Super+V, which toggles floating/tiling focus
        window_focus_unmanaged = hyper "v";
        window_focus_managed = hyper "tab";

        # Widths cycle through preset_column_widths; heights apply in a stack
        window_resize = map hyper [
          "r"
          "equal"
        ];
        window_shrink = hyper "minus";
        window_vertical_resize = hyperShift "equal";
        window_vertical_shrink = hyperShift "minus";
        window_equalize = hyperShift "r";
        window_balance = hyper "b";
        window_fullwidth = hyper "w";
        window_manage = hyperShift "f";
        window_center = hyper "x";
        window_snap = hyper "s";
        window_tabbeddisplay = hyper "t";
        window_stack = hyper "leftbracket";
        window_unstack = hyper "rightbracket";

        window_nextdisplay = hyper "n";
        window_nextdisplaysend = hyperShift "n";

        # Virtual workspaces (experimental — virtualmove_north is a no-op at
        # the topmost strip; focus restore on return isn't deterministic)
        window_virtual_north = hyper "u";
        window_virtual_south = hyper "i";
        window_virtualmove_north = hyperShift "u";
        window_virtualmove_south = hyperShift "i";

        quit = hyperShift "e";
      }
      // lib.mergeAttrsList (
        map (n: {
          "window_virtualnum_${n}" = hyper n;
          "window_virtualmovenum_${n}" = hyperShift n;
        }) (map toString (lib.range 1 9))
      );

      # ── Window rules ────────────────────────────────────────────────────
      windows = {
        zen-pip = {
          title = "Picture-in-Picture";
          bundle_id = "app.zen-browser.zen";
          floating = true;
          grid = "50:50:39:1:10:8"; # top-right ish
        };
        onepassword = {
          title = ".*";
          bundle_id = "com.1password.1password";
          floating = true;
        };
        # Ghostty's quick terminal: the one Ghostty window that is a panel
        # (subrole AXFloatingWindow; ordinary windows are AXStandardWindow).
        # Its title is the cwd, so only the subrole tells it apart.
        ghostty-quick-terminal = {
          title = ".*";
          bundle_id = "com.mitchellh.ghostty";
          subrole = "AXFloatingWindow";
          floating = true;
        };
        finder = {
          title = ".*";
          bundle_id = "com.apple.finder";
          floating = true;
        };
        # The call window is the one that must float, but no matcher tells it
        # from the main window: both are titled "FaceTime", role AXWindow,
        # subrole AXStandardWindow (seen 2026-10-26). So the whole app floats.
        facetime = {
          title = ".*";
          bundle_id = "com.apple.FaceTime";
          floating = true;
        };
        # Emacs child frames, which paneru otherwise tiles as columns beside
        # the main frame: posframe titles its frames "posframe" (the
        # vertico-posframe minibuffer) and corfu names its "EmacsCorfuGUI"
        # (completion and popupinfo).
        emacs-childframe = {
          title = "^(posframe|EmacsCorfuGUI)$";
          bundle_id = "org.gnu.Emacs";
          floating = true;
        };
        # The Hyper+C capture popup (init.el `tf/popup-org-capture'): floating,
        # top centre, two thirds wide and a third high. Unanchored at the end:
        # Emacs appends "  —  (cols × rows)" to the title while it is resized.
        emacs-capture = {
          title = "^org-capture";
          bundle_id = "org.gnu.Emacs";
          floating = true;
          grid = "6:3:1:0:4:1";
        };
      };
    };
  };
}
