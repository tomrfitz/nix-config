{
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
      };

      # Trackpad: a four-finger horizontal swipe scrolls the column strip. The
      # vertical swipe (switches virtual workspaces) is off — it kept firing on
      # ordinary drags. Padding (0), direction (Natural) and the active-window
      # border (off) are upstream defaults, so they are not restated here.
      swipe.gesture = {
        fingers_count = 4;
        vertical = false;
      };

      bindings = {
        # Focus (vim hjkl)
        window_focus_west = "ctrl + alt - h";
        window_focus_east = "ctrl + alt - l";
        window_focus_north = "ctrl + alt - k";
        window_focus_south = "ctrl + alt - j";

        # Swap
        window_swap_west = "ctrl + alt + shift - h";
        window_swap_east = "ctrl + alt + shift - l";
        window_swap_north = "ctrl + alt + shift - k";
        window_swap_south = "ctrl + alt + shift - j";

        # Jump to first/last
        window_focus_first = "ctrl + alt + cmd - h";
        window_focus_last = "ctrl + alt + cmd - l";
        window_swap_first = "ctrl + alt + cmd + shift - h";
        window_swap_last = "ctrl + alt + cmd + shift - l";

        # Layout
        window_center = "ctrl + alt - c";
        window_resize = "ctrl + alt - r";
        window_shrink = "ctrl + alt + shift - r";
        window_fullwidth = "ctrl + alt - f";
        window_manage = "ctrl + alt + shift - f";
        window_equalize = "ctrl + alt - e";

        # Stacking (consume/expel)
        window_stack = "ctrl + alt - ]";
        window_unstack = "ctrl + alt + shift - ]";

        # Multi-monitor
        window_nextdisplay = "ctrl + alt + shift - n"; # move and follow
        window_nextdisplaysend = "ctrl + alt + cmd - n"; # move but stay

        # Virtual workspaces (experimental — virtualmove_north is a no-op at
        # the topmost strip; focus restore on return isn't deterministic)
        window_virtual_north = "ctrl + alt + cmd - k";
        window_virtual_south = "ctrl + alt + cmd - j";
        window_virtualmove_north = "ctrl + alt + cmd + shift - k";
        window_virtualmove_south = "ctrl + alt + cmd + shift - j";

        quit = "ctrl + alt - q";
      };

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
        finder = {
          title = ".*";
          bundle_id = "com.apple.finder";
          floating = true;
        };
        # Emacs child frames (corfu/eldoc popups) — title is empty or
        # starts with " *" (internal buffer names)
        emacs-childframe = {
          title = "^( \\*.*|)$";
          bundle_id = "org.gnu.Emacs";
          floating = true;
        };
      };
    };
  };
}
