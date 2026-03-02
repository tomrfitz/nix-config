{ ... }:
{
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
          keyColor = "yellow";
        }
        {
          type = "host";
          key = "HOST";
          keyColor = "yellow";
        }
        {
          type = "kernel";
          key = "KERNEL";
          keyColor = "yellow";
        }
        {
          type = "uptime";
          key = "UPTIME";
          keyColor = "yellow";
        }
        {
          type = "packages";
          key = "PKGS";
          keyColor = "yellow";
          format = "{all}";
        }
        "break"

        # Environment (desktop modules auto-hide when empty)
        {
          type = "shell";
          key = "SHELL";
          keyColor = "blue";
        }
        {
          type = "terminal";
          key = "TERM";
          keyColor = "blue";
        }
        {
          type = "terminalfont";
          key = "FONT";
          keyColor = "blue";
        }
        {
          type = "de";
          key = "DE";
          keyColor = "blue";
        }
        {
          type = "wm";
          key = "WM";
          keyColor = "blue";
        }
        {
          type = "wmtheme";
          key = "THEME";
          keyColor = "blue";
        }
        {
          type = "display";
          key = "DISPLAY";
          keyColor = "blue";
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
