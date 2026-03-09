{
  config,
  pkgs,
  lib,
  sshPublicKey,
  isDarwin,
  isWSL,
  ...
}:
let
  onePasswordSshAgentSock =
    if isDarwin then
      "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    else
      "${config.home.homeDirectory}/.1password/agent.sock";
  onePasswordIdentityAgent =
    if isDarwin then "\"${onePasswordSshAgentSock}\"" else onePasswordSshAgentSock;
in
{
  imports = [
    ./packages.nix
    ./shell.nix
    ./git.nix
    ./fastfetch.nix
    ./editors.nix
    ./fonts.nix
    ./ruff.nix
    ./opencode.nix
  ];

  home.stateVersion = "24.11";

  xdg.enable = true;

  # ── Session environment ────────────────────────────────────────────────
  home.sessionVariables = {
    EDITOR = "zeditor --wait"; # overridden on darwin (zsh.nix) to use the .app CLI
    NH_FLAKE = "github:tomrfitz/nix-config/main";

    OLLAMA_GPU_LAYERS = "-1";
    OLLAMA_KEEP_ALIVE = "5m";
  }
  // lib.optionalAttrs (isDarwin || isWSL) {
    # 1Password SSH agent. On macOS it's the native app socket; on WSL the
    # socat+npiperelay bridge. Set unconditionally — these are always local.
    SSH_AUTH_SOCK = onePasswordSshAgentSock;
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.config/emacs/bin" # doom CLI
  ];

  # Export SSH_AUTH_SOCK to systemd user environment so GUI apps (Obsidian, etc.)
  # can access the 1Password SSH agent
  systemd.user.sessionVariables = lib.mkIf (!isDarwin) {
    SSH_AUTH_SOCK = onePasswordSshAgentSock;
  };

  # On WSL, bridge the 1Password Windows SSH agent to a Unix socket via
  # npiperelay + socat. Requires npiperelay.exe on the Windows side
  # (installed to C:\Users\<user>\.local\bin\npiperelay.exe).
  systemd.user.services."1password-ssh-agent-bridge" = lib.mkIf isWSL {
    Unit = {
      Description = "Bridge 1Password Windows SSH agent to Unix socket";
    };
    Install.WantedBy = [ "default.target" ];
    Service =
      let
        npiperelay = "/mnt/c/Users/Thomas FitzGerald/.local/bin/npiperelay.exe";
        # Symlink npiperelay to a path without spaces so socat EXEC: can handle it
        npiprelayLink = pkgs.runCommand "npiperelay-link" { } ''
          mkdir -p $out/bin
          ln -s "${npiperelay}" $out/bin/npiperelay.exe
        '';
        bridge = pkgs.writeShellScript "1password-ssh-bridge" ''
          ${pkgs.coreutils}/bin/rm -f "${onePasswordSshAgentSock}"
          ${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname "${onePasswordSshAgentSock}")"
          exec ${pkgs.socat}/bin/socat \
            UNIX-LISTEN:${onePasswordSshAgentSock},fork \
            EXEC:"${npiprelayLink}/bin/npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork
        '';
      in
      {
        Type = "simple";
        ExecStart = "${bridge}";
        Restart = "on-failure";
        RestartSec = 3;
      };
  };

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
      "*" = {
        extraOptions = {
          AddKeysToAgent = "yes";
        }
        // lib.optionalAttrs (isDarwin || isWSL) {
          # On macOS/WSL, always use the 1Password agent directly. On plain NixOS,
          # omit this so SSH falls back to SSH_AUTH_SOCK — which preserves forwarded
          # agents from SSH sessions while defaulting to 1Password locally (via zsh envExtra).
          IdentityAgent = onePasswordIdentityAgent;
        };
      };
      "github.com" = {
        extraOptions = {
          ControlMaster = "auto";
          ControlPath = "~/.ssh/sockets/%r@%h-%p";
          ControlPersist = "3600";
        };
      };
      "trfnix trfwsl trflab" = {
        forwardAgent = true;
      };
    };
  };

  # Ensure the SSH ControlPath directory exists
  home.file.".ssh/sockets/.keep".text = "";

  # On NixOS, prefer managing authorized keys via `users.users.<name>.openssh.authorizedKeys`.
  # macOS doesn't have an equivalent declarative system-level module, so keep it in HM.
  home.file.".ssh/authorized_keys" = lib.mkIf isDarwin {
    text = ''
      ${sshPublicKey}
    '';
  };

  # ── Doom Emacs config ────────────────────────────────────────────────
  # Doom itself lives in ~/.config/emacs (cloned manually or via doom install).
  # These deploy the user config that Doom reads from $DOOMDIR (~/.config/doom/).
  xdg.configFile."doom/init.el".source = ../../../config/doom/init.el;
  xdg.configFile."doom/config.el".source = ../../../config/doom/config.el;
  xdg.configFile."doom/packages.el".source = ../../../config/doom/packages.el;

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
