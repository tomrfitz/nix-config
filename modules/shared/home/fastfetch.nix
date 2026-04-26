_: {
  # ── Fastfetch ──────────────────────────────────────────────────────────
  programs.fastfetch = {
    enable = true;
    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
      logo = {
        padding = {
          top = 2;
          left = 1;
          right = 2;
        };
      };
      display.separator = ": ";
      modules = [
        # Title
        {
          type = "title";
          format = "{user-name}@{host-name}";
        }
        "break"

        # System
        {
          type = "os";
          key = "OS";
          keyColor = "blue";
        }
        {
          type = "host";
          key = "HOST";
          keyColor = "blue";
        }
        {
          type = "kernel";
          key = "KERNEL";
          keyColor = "blue";
        }
        {
          type = "uptime";
          key = "UPTIME";
          keyColor = "blue";
        }
        {
          type = "packages";
          key = "PKGS";
          keyColor = "blue";
          format = "{all}";
        }
        "break"

        # Environment (desktop modules auto-hide when empty)
        {
          type = "shell";
          key = "SHELL";
          keyColor = "cyan";
        }
        {
          type = "terminal";
          key = "TERM";
          keyColor = "cyan";
        }
        {
          type = "terminalfont";
          key = "FONT";
          keyColor = "cyan";
        }
        {
          type = "de";
          key = "DE";
          keyColor = "cyan";
        }
        {
          type = "wm";
          key = "WM";
          keyColor = "cyan";
        }
        {
          type = "wmtheme";
          key = "THEME";
          keyColor = "cyan";
        }
        {
          type = "display";
          key = "DISPLAY";
          keyColor = "cyan";
        }
        "break"

        # Hardware
        {
          type = "cpu";
          key = "CPU";
          keyColor = "green";
        }
        {
          type = "gpu";
          key = "GPU";
          keyColor = "green";
        }
        {
          type = "memory";
          key = "MEM";
          keyColor = "green";
        }
        {
          type = "disk";
          key = "DISK(/)";
          keyColor = "green";
          folders = "/";
        }
        {
          type = "battery";
          key = "BAT";
          keyColor = "green";
        }
        {
          type = "localip";
          key = "IP";
          keyColor = "green";
        }
        "break"

        # Colors
        {
          type = "colors";
          symbol = "circle";
        }
      ];
    };
  };
}
