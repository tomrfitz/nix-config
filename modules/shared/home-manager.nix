{
  config,
  pkgs,
  lib,
  ...
}:
{
  home.stateVersion = "24.11";

  # ── Packages (things without a dedicated programs.* module) ────────────
  home.packages = with pkgs; [
    # dev toolchains
    rustup
    go
    nodejs
    python3
    deno

    # build tools
    cmake
    gnumake
    ninja
    bear

    # nix tooling
    nixd
    nil

    # utilities
    coreutils
    findutils
    curl
    wget
    tree
  ];

  # ── Session environment ────────────────────────────────────────────────
  home.sessionVariables = {
    EDITOR = "zed";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    EZA_CONFIG_DIR = "$HOME/.config/eza/";
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

  # ── Zsh ────────────────────────────────────────────────────────────────
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    shellAliases = {
      ls = "eza --group-directories-first --icons --hyperlink --time-style=long-iso";
      sa = "source ~/.zshrc && echo \"ZSH aliases sourced.\"";
      histrg = "cat ~/.zsh_history | grep";
    };

    envExtra = ''
      [ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
    '';

    profileExtra = ''
      if [[ "$TERM_PROGRAM" != "vscode" && "$TERM_PROGRAM" != "zed" ]]; then
        command -v fastfetch &>/dev/null && fastfetch
      fi
    '';

    completionInit = ''
      autoload -Uz compinit
      compdump="$HOME/.zcompdump"
      if [[ ! -f "$compdump" || -n $(find "$compdump" -mtime +1 2>/dev/null) ]]; then
        compinit
      else
        compinit -C
      fi
    '';

    initContent = lib.mkMerge [
      (lib.mkBefore ''
        setopt CORRECT
        typeset -U path
      '')

      ''
        # JJ completions (after compinit)
        if command -v jj &>/dev/null; then
          source <(COMPLETE=zsh jj)
        fi

        # Docker completions
        [ -d "$HOME/.docker/completions" ] && fpath=("$HOME/.docker/completions" ''${fpath[@]})

        # uv completions
        if command -v uv &>/dev/null; then
          eval "$(uv generate-shell-completion zsh)"
          eval "$(uvx --generate-shell-completion zsh)"
        fi

        # Mole shell completion
        if output="$(mole completion zsh 2>/dev/null)"; then eval "$output"; fi

        # Source custom environment file if it exists
        [ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

        function set_win_title() {
          echo -ne "\033]0; $(basename "$PWD") \007"
        }
        starship_precmd_user_func="set_win_title"
      ''
    ];

    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "zsh-fast-syntax-highlighting";
        src = pkgs.zsh-fast-syntax-highlighting;
        file = "share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh";
      }
    ];
  };

  # ── Starship ───────────────────────────────────────────────────────────
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = lib.importTOML ../../starship.toml;
  };

  # ── Git ────────────────────────────────────────────────────────────────
  programs.git = {
    enable = true;

    lfs.enable = true;

    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJAf+U5Lj9RGzpxZJWVBTFpEAIqY2oTQor3URBBzWY2v";
      signByDefault = true;
      format = "ssh";
    };

    ignores = [
      ".DS_Store"
      ".vscode"
    ];

    settings = {
      user = {
        name = "Thomas FitzGerald";
        email = "tomrfitz@gmail.com";
      };
      init.defaultBranch = "main";
      core = {
        excludesfile = "~/.gitignore";
        preloadindex = true;
        fscache = true;
      };
      diff = {
        algorithm = "histogram";
        colorMoved = "default";
      };
      pull.rebase = false;
      push = {
        default = "current";
        followTags = true;
      };
      fetch = {
        prune = true;
        parallel = 0;
      };
      rerere.enabled = true;
      rebase = {
        autoStash = true;
        updateRefs = true;
      };
      merge.conflictStyle = "zdiff3";
    };
  };

  # ── Delta (git pager) ─────────────────────────────────────────────────
  programs.delta = {
    enable = true;
    options = {
      navigate = true;
      line-numbers = true;
      hyperlinks = true;
    };
  };

  # ── Atuin (shell history) ──────────────────────────────────────────────
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      dotfiles.enabled = true;
      enter_accept = true;
      sync.records = true;
    };
  };

  # ── Zoxide (smart cd) ─────────────────────────────────────────────────
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # ── Fzf ────────────────────────────────────────────────────────────────
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # ── Ghostty ────────────────────────────────────────────────────────────
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      theme = "light:Flexoki Light,dark:Flexoki Dark";
      quit-after-last-window-closed = false;
      clipboard-read = "allow";
      clipboard-write = "allow";
      window-padding-balance = true;
      window-theme = "system";
      window-height = 36;
      window-width = 130;
      bold-is-bright = true;
      cursor-style = "bar";
      font-thicken = true;
      font-family = "Atkinson Hyperlegible Mono";
    };
  };

  # ── Other programs with native modules ─────────────────────────────────
  programs.bat.enable = true;
  programs.eza.enable = true;
  programs.fd.enable = true;
  programs.ripgrep.enable = true;
  programs.jq.enable = true;
  programs.btop.enable = true;
  programs.htop.enable = true;
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = false;
  };
  programs.lazygit.enable = true;
  programs.helix.enable = true;
  programs.neovim.enable = true;

  # ── Fastfetch ──────────────────────────────────────────────────────────
  programs.fastfetch.enable = true;

  xdg.configFile."fastfetch/config.jsonc".source = ../../fastfetch.jsonc;

  # ── Jujutsu ────────────────────────────────────────────────────────────
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Thomas FitzGerald";
        email = "tomrfitz@gmail.com";
      };
    };
  };

  programs.home-manager.enable = true;
}
