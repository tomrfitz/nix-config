{
  config,
  pkgs,
  lib,
  sshPublicKey,
  ...
}:
{
  imports = [
    ./packages.nix
    ./shell.nix
    ./fish.nix
    ./git.nix
    ./firefox.nix
    ./zen.nix
    ./fastfetch.nix
    ./editors.nix
    ./ghostty.nix
    ./vesktop.nix
    ./obsidian.nix
    ./stylix.nix
    ./ruff.nix
    ./micro.nix
    ./beets.nix
    ./mpv.nix
    ./opencode.nix
  ];

  home.stateVersion = "24.11";

  xdg.enable = true;

  # ── Session environment ────────────────────────────────────────────────
  home.sessionVariables = {
    EDITOR = "zeditor --wait"; # overridden on darwin (zsh.nix) to use the .app CLI
    NH_FLAKE = "$HOME/nix-config";

    # Prefer 1Password's SSH agent everywhere (family/shared workflow).
    # SSH also explicitly points at the same socket via `IdentityAgent`.
    SSH_AUTH_SOCK =
      if pkgs.stdenv.isDarwin then
        "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
      else
        "${config.home.homeDirectory}/.1password/agent.sock";

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

  # Export SSH_AUTH_SOCK to systemd user environment so GUI apps (Obsidian, etc.)
  # can access the 1Password SSH agent
  systemd.user.sessionVariables = {
    SSH_AUTH_SOCK = config.home.sessionVariables.SSH_AUTH_SOCK;
  };

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

  programs.btop.enable = true;

  programs.nushell.enable = true;

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
      "*" = {
        extraOptions = {
          AddKeysToAgent = "yes";
          IdentityAgent =
            if pkgs.stdenv.isDarwin then
              "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\""
            else
              "~/.1password/agent.sock";
        };
      };
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

  # On NixOS, prefer managing authorized keys via `users.users.<name>.openssh.authorizedKeys`.
  # macOS doesn't have an equivalent declarative system-level module, so keep it in HM.
  home.file.".ssh/authorized_keys" = lib.mkIf pkgs.stdenv.isDarwin {
    text = ''
      ${sshPublicKey}
    '';
  };

  # ── Agent instructions (each tool looks for instructions at a different path) ──
  home.file.".config/AGENTS.md".source = ../../../config/agents.md; # generic / Gemini
  home.file.".config/opencode/AGENTS.md".source = ../../../config/agents.md; # OpenCode
  home.file.".claude/CLAUDE.md".source = ../../../config/agents.md; # Claude Code
  home.file.".claude/settings.json".source = ../../../config/claude-settings.json;

  # ── Dotfiles managed via config/ ────────────────────────────────────────
  home.file.".clang-format".source = ../../../config/clang-format;

  home.file.".editorconfig".source = ../../../config/editorconfig;
  home.file.".hushlogin".text = "";

  # markdownlint-cli2 config (shared by Zed ext, obsidian-markdownlint, CLI)
  home.file.".markdownlint-cli2.jsonc".text = builtins.toJSON {
    config = {
      MD009 = true;
      MD012 = true;
      MD022 = true;
      MD023 = true;
      MD026 = {
        punctuation = ".,;:!";
      };
      MD029 = {
        style = "ordered";
      };
      MD030 = true;
      MD031 = true;
      MD034 = true;
      MD047 = true;
      MD049 = {
        style = "consistent";
      };
      MD050 = {
        style = "consistent";
      };

      # Relaxations for Obsidian compatibility
      MD013 = false;
      MD024 = {
        siblings_only = true;
      };
      MD025 = false;
      MD033 = false;
    };
  };

  # todo-txt-cli config
  home.file.".todo.cfg".text = ''
    export TODO_DIR="$HOME"
    export TODO_FILE="$TODO_DIR/todo.txt"
    export DONE_FILE="$TODO_DIR/done.txt"
    export REPORT_FILE="$TODO_DIR/report.txt"
  '';

  programs.home-manager.enable = true;

  # ── Topgrade ──────────────────────────────────────────────────────────
  programs.topgrade = {
    enable = true;
    settings = {
      misc = {
        pre_sudo = false;
        disable = [
          "nix"
          "home_manager"
        ];
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
