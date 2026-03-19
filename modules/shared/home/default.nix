{ ... }:
{
  imports = [
    ./packages.nix
    ./shell.nix
    ./git.nix
    ./fastfetch.nix
    ./editors.nix
    ./fonts.nix
    ./notes.nix
    ./ruff.nix
    ./opencode.nix
    ./xdg-dirs.nix
    ./1password-ssh.nix
  ];

  home.stateVersion = "24.11";

  xdg.enable = true;

  # ── Session environment ────────────────────────────────────────────────
  home.sessionVariables = {
    EDITOR = "zeditor --wait"; # overridden on darwin (zsh.nix) to use the .app CLI
    NH_FLAKE = "github:tomrfitz/nix-config/main";

    OLLAMA_GPU_LAYERS = "-1";
    OLLAMA_KEEP_ALIVE = "5m";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  # ── Other programs with native modules ─────────────────────────────────

  programs.bat.enable = true;
  programs.eza.enable = true;
  programs.fd.enable = true;
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
  programs.mergiraf = {
    enable = true;
    enableGitIntegration = true;
    enableJujutsuIntegration = true;
  };

  # ── Tmux ──────────────────────────────────────────────────────────────
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    mouse = true;
    historyLimit = 50000;
    escapeTime = 10;
    baseIndex = 1;
    focusEvents = true;
    keyMode = "vi";
    extraConfig = ''
      set -g renumber-windows on
      set -g set-clipboard on

      # Splits/windows preserve working directory
      bind \\ split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      # Vim pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded"

      # ── Flexoki dark status bar ──
      set -g status-style "bg=#282726,fg=#878580"
      set -g status-left "#{?client_prefix,#[bg=#D0A215 fg=#100F0F bold],#[bg=#3AA99F fg=#100F0F bold]} #S #[default] "
      set -g status-right "#[fg=#878580]%H:%M"
      set -g window-status-format "#[fg=#6F6E69] #I #W "
      set -g window-status-current-format "#[fg=#CECDC3,bold] #I #W "
      set -g window-status-separator ""
      set -g pane-border-style "fg=#343331"
      set -g pane-active-border-style "fg=#3AA99F"
      set -g message-style "bg=#343331,fg=#CECDC3"
    '';
  };

  # ── SSH ──────────────────────────────────────────────────────────────
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*".extraOptions = {
        AddKeysToAgent = "yes";
      };
      "github.com".extraOptions = {
        ControlMaster = "auto";
        ControlPath = "~/.ssh/sockets/%r@%h-%p";
        ControlPersist = "3600";
      };
      "trfnix trfwsl trflab" = {
        forwardAgent = true;
      };
    };
  };

  # Ensure the SSH ControlPath directory exists
  home.file.".ssh/sockets/.keep".text = "";

  # ── Agent instructions (each tool looks for instructions at a different path) ──
  xdg.configFile."AGENTS.md".source = ../../../config/agents.md; # generic / Gemini
  xdg.configFile."opencode/AGENTS.md".source = ../../../config/agents.md; # OpenCode
  home.file.".claude/CLAUDE.md".source = ../../../config/agents.md; # Claude Code
  home.file.".claude/settings.json".source = ../../../config/claude-settings.json;

  # ── Templates ──────────────────────────────────────────────────────────
  xdg.configFile."nix/flake-template.nix".source = ../../../config/flake-template.nix;

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
          "pip3"
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
}
