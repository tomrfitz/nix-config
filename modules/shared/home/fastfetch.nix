{
  pkgs,
  lib,
  ...
}:
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
      }
      // lib.optionalAttrs (hostName == "trfwsl") {
        type = "kitty-direct";
        source = "${../../../config/fastfetch-nixos-wsl.svg}";
        width = 24;
        height = 12;
      };
      display.separator = "  ";
      modules = [
        # Title
        {
          type = "title";
          format = "{user-name-colored}@{host-name-colored}";
        }
        "break"

        # System
        {
          type = "os";
          key = "󰍹 OS";
        }
        {
          type = "host";
          key = "󰌢 Host";
        }
        {
          type = "kernel";
          key = "󰒋 Kernel";
        }
        {
          type = "uptime";
          key = "󰅐 Uptime";
        }
        {
          type = "packages";
          key = "󰏖 Packages";
          format = "{all}";
        }
        "break"

        # Environment (desktop modules auto-hide when empty)
        {
          type = "shell";
          key = "󰞷 Shell";
        }
        {
          type = "terminal";
          key = "󰆍 Terminal";
        }
        {
          type = "terminalfont";
          key = "󰛖 Font";
        }
        {
          type = "de";
          key = "󰧨 DE";
        }
        {
          type = "wm";
          key = "󱂬 WM";
        }
        {
          type = "wmtheme";
          key = "󰉼 Theme";
        }
        {
          type = "display";
          key = "󰹑 Display";
        }
        "break"

        # Hardware
        {
          type = "cpu";
          key = "󰻠 CPU";
        }
        {
          type = "gpu";
          key = "󰢮 GPU";
        }
        {
          type = "memory";
          key = "󰍛 Memory";
        }
        {
          type = "disk";
          key = "󰋊 Disk (/)";
          folders = "/";
        }
        {
          type = "battery";
          key = "󰁹 Battery";
        }
        {
          type = "localip";
          key = "󰩟 IP";
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
