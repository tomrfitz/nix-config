{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./packages.nix
    ./shell.nix
    ./git.nix
    ./firefox.nix
    ./zen.nix
    ./fastfetch.nix
    ./editors.nix
    ./ghostty.nix
    # ./vesktop.nix # heavy — re-enable before darwin rebuild
    ./obsidian.nix
    ./stylix.nix
  ];

  home.stateVersion = "24.11";

  # ── Session environment ────────────────────────────────────────────────
  home.sessionVariables = {
    EDITOR = "zeditor";
    NH_FLAKE = "$HOME/nix-config";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    VCPKG_ROOT = "$HOME/vcpkg";
    OLLAMA_GPU_LAYERS = "-1";
    OLLAMA_KEEP_ALIVE = "5m";
    PYTORCH_ENABLE_MPS_FALLBACK = "1";
    PYTORCH_MPS_HIGH_WATERMARK_RATIO = "0.0";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/go/bin"
  ];

  # ── Other programs with native modules ─────────────────────────────────

  programs.alacritty = {
    enable = true;
    settings = {
      general.live_config_reload = true;
      window = {
        decorations = "Buttonless";
        dynamic_padding = true;
        opacity = lib.mkForce 0.2;
        blur = true;
        resize_increments = true;
        dynamic_title = true;
      };
      hints.enabled = [
        {
          command = if pkgs.stdenv.isDarwin then "open" else "xdg-open";
          hyperlinks = true;
          post_processing = true;
          persist = false;
          mouse.enabled = true;
          binding = {
            key = "O";
            mods = "Control|Shift";
          };
          regex = "(ipfs:|ipns:|magnet:|mailto:|gemini://|gopher://|https://|http://|news:|file:|git://|ssh:|ftp://)[^\\u0000-\\u001F\\u007F-\\u009F<>\"\\\\s{-}\\\\^⟨⟩`]+";
        }
      ];
    };
  };

  programs.bat.enable = true;
  programs.eza.enable = true;
  programs.fd.enable = true;
  programs.kitty.enable = true;
  programs.ripgrep.enable = true;
  programs.jq.enable = true;

  programs.btop = {
    enable = true;
    settings = {
      theme_background = true;
      truecolor = true;
      force_tty = false;
      presets = "cpu:1:default,proc:0:default cpu:0:default,mem:0:default,net:0:default cpu:0:block,net:0:tty";
      vim_keys = false;
      rounded_corners = true;
      terminal_sync = true;
      graph_symbol = "braille";
      graph_symbol_cpu = "default";
      graph_symbol_mem = "default";
      graph_symbol_net = "default";
      graph_symbol_proc = "default";
      shown_boxes = "cpu mem net proc";
      update_ms = 2000;
      proc_sorting = "cpu lazy";
      proc_reversed = false;
      proc_tree = false;
      proc_colors = true;
      proc_gradient = true;
      proc_per_core = false;
      proc_mem_bytes = true;
      proc_cpu_graphs = true;
      proc_info_smaps = false;
      proc_left = false;
      proc_filter_kernel = false;
      proc_aggregate = false;
      keep_dead_proc_usage = false;
      cpu_graph_upper = "Auto";
      cpu_graph_lower = "Auto";
      cpu_invert_lower = true;
      cpu_single_graph = false;
      cpu_bottom = false;
      show_uptime = true;
      show_cpu_watts = true;
      check_temp = true;
      cpu_sensor = "Auto";
      show_coretemp = true;
      cpu_core_map = "";
      temp_scale = "celsius";
      base_10_sizes = false;
      show_cpu_freq = true;
      clock_format = "%X";
      background_update = true;
      custom_cpu_name = "";
      disks_filter = "";
      mem_graphs = true;
      mem_below_net = false;
      zfs_arc_cached = true;
      show_swap = true;
      swap_disk = true;
      show_disks = true;
      only_physical = true;
      use_fstab = true;
      zfs_hide_datasets = false;
      disk_free_priv = false;
      show_io_stat = true;
      io_mode = false;
      io_graph_combined = false;
      io_graph_speeds = "";
      net_download = 100;
      net_upload = 100;
      net_auto = true;
      net_sync = true;
      net_iface = "";
      base_10_bitrate = "Auto";
      show_battery = true;
      selected_battery = "Auto";
      show_battery_watts = true;
      log_level = "WARNING";
      save_config_on_exit = true;
    };
  };

  programs.htop.enable = true;
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = false;
  };
  programs.lazygit.enable = true;

  # ── Tmux ──────────────────────────────────────────────────────────────
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    mouse = true;
    historyLimit = 50000;
    escapeTime = 10;
    baseIndex = 1;
    keyMode = "vi";
  };

  # ── SSH ──────────────────────────────────────────────────────────────
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "github.com" = {
        extraOptions = {
          ControlMaster = "auto";
          ControlPath = "~/.ssh/sockets/%r@%h-%p";
          ControlPersist = "3600";
        };
      };
    };
  };

  # Ensure the SSH ControlPath directory exists
  home.file.".ssh/sockets/.keep".text = "";

  # ── Agent instructions (config/agents.md is the single source of truth) ──
  home.file.".config/AGENTS.md".source = ../../../config/agents.md;
  home.file.".claude/CLAUDE.md".source = ../../../config/agents.md;
  home.file.".claude/settings.json".source = ../../../config/claude-settings.json;

  # ── Dotfiles managed via config/ ────────────────────────────────────────
  home.file.".clang-format".source = ../../../config/clang-format;

  home.file.".editorconfig".source = ../../../config/editorconfig;
  home.file.".markdownlint-cli2.jsonc".source = ../../../config/markdownlint-cli2.jsonc;

  programs.home-manager.enable = true;

  # ── Topgrade ──────────────────────────────────────────────────────────
  programs.topgrade = {
    enable = true;
    settings = {
      misc = {
        pre_sudo = false;
        disable = [ "nix" ];
        cleanup = true;
        skip_notify = true;
        no_retry = true;
        no_self_update = true;
      };
      git = {
        max_concurrency = 2;
        repos = [
          "~/Developer/*"
        ];
      };
    };
  };

  # ── Agenix secrets ───────────────────────────────────────────────────
  age.identityPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519_agenix" ];
  age.secrets = {
    test-secret.file = ../../../secrets/test-secret.age;
  };
}
