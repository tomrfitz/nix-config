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
        window_focus_west = "alt - h";
        window_focus_east = "alt - l";
        window_focus_north = "alt - k";
        window_focus_south = "alt - j";

        # Swap
        window_swap_west = "alt + shift - h";
        window_swap_east = "alt + shift - l";
        window_swap_north = "alt + shift - k";
        window_swap_south = "alt + shift - j";

        # Jump to first/last
        window_focus_first = "cmd + shift - h";
        window_focus_last = "cmd + shift - l";
        window_swap_first = "cmd + alt - h";
        window_swap_last = "cmd + alt - l";

        # Layout
        window_center = "alt - c";
        window_resize = "alt - r";
        window_shrink = "alt + shift - r";
        window_fullwidth = "alt - f";
        window_manage = "alt + shift - f";
        window_equalize = "alt - e";

        # Stacking (consume/expel)
        window_stack = "alt - ]";
        window_unstack = "alt + shift - ]";

        # Multi-monitor
        window_nextdisplay = "alt + shift - n";

        quit = "ctrl + alt - q";
      };

      # ── Window rules ────────────────────────────────────────────────────
      windows = {
        zen-pip = {
          title = "Picture-in-Picture";
          bundle_id = "app.zen-browser.zen";
          floating = true;
        };
        onepassword = {
          title = ".*";
          bundle_id = "com.1password.1password";
          floating = true;
        };
      };
    };
  };
}
