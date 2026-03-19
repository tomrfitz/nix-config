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
        swipe_gesture_fingers = 4;
        swipe_gesture_direction = "Natural";
        animation_speed = 4000;
        padding_top = 0;
        padding_bottom = 0;

        padding_left = 0;
        padding_right = 0;
        auto_center = false;
        border_active_window = false;
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
        window_nextdisplay = "ctrl + alt + shift - n";

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
