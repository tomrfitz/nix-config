{
  config,
  pkgs,
  lib,
  isWSL,
  ...
}:
{
  # ── Zsh ────────────────────────────────────────────────────────────────
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    # Preemptively adopt HM's upcoming default: keep zsh dotfiles in XDG.
    dotDir = "${config.xdg.configHome}/zsh";

    shellAliases = {
      ls = "eza --group-directories-first --icons --hyperlink --time-style=long-iso";
      sa = "source \"${"ZDOTDIR:-$HOME"}/.zshrc\" && echo \"ZSH aliases sourced.\"";
      # 1Password CLI helpers
      oprun = "op run --";
      oprunenv = "op run --environment";

      # zmv helpers
      zcp = "zmv -C";
      zln = "zmv -L";
    }
    // lib.optionalAttrs isWSL {
      # On WSL, ssh-add must route through Windows OpenSSH to reach 1Password's agent.
      # Interactive ssh stays as Linux's — Git uses core.sshCommand for its own SSH.
      ssh-add = "/mnt/c/Windows/System32/OpenSSH/ssh-add.exe";
    };

    envExtra = "";

    completionInit = ''
      autoload -Uz compinit
      compdump="''${ZDOTDIR:-$HOME}/.zcompdump"

      # Third-party completion functions must be on `fpath` before `compinit`.
      if [ -d "$HOME/.docker/completions" ]; then
        fpath=("$HOME/.docker/completions" ''${fpath[@]})
      fi

      if [[ ! -f "$compdump" || -n $(find "$compdump" -mtime +1 2>/dev/null) ]]; then
        compinit -d "$compdump"
      else
        compinit -C -d "$compdump"
      fi
    '';

    initContent = lib.mkMerge [
      (lib.mkBefore ''
        setopt CORRECT
        setopt AUTO_CD
        setopt GLOB_DOTS
        setopt INTERACTIVE_COMMENTS
        typeset -U path
      '')

      ''
        # Show fastfetch for interactive top-level shells (e.g., Ghostty tabs).
        if [[ -o interactive && "$SHLVL" -eq 1 ]]; then
          command -v fastfetch &>/dev/null && fastfetch
        fi

        _zsh_completion_cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions"
        mkdir -p "$_zsh_completion_cache_dir"

        # Cache generated completions and refresh when the backing binary changes.
        _source_cached_completion() {
          local name="$1"
          local generator="$2"
          local binary="$3"
          local cache_file="$_zsh_completion_cache_dir/''${name}.zsh"
          local tmp_file="''${cache_file}.tmp"
          local needs_refresh=0

          if [[ ! -s "$cache_file" ]]; then
            needs_refresh=1
          elif [[ -n "$binary" && "$cache_file" -ot "$binary" ]]; then
            needs_refresh=1
          fi

          if (( needs_refresh )); then
            if eval "$generator" >| "$tmp_file" 2>/dev/null; then
              mv "$tmp_file" "$cache_file"
            else
              rm -f "$tmp_file"
            fi
          fi

          [[ -r "$cache_file" ]] && source "$cache_file"
        }

        # JJ completions (after compinit)
        if command -v jj &>/dev/null; then
          _source_cached_completion "jj" "COMPLETE=zsh jj" "$(command -v jj)"
        fi

        # uv completions
        if command -v uv &>/dev/null; then
          _source_cached_completion "uv" "uv generate-shell-completion zsh" "$(command -v uv)"
        fi
        if command -v uvx &>/dev/null; then
          _source_cached_completion "uvx" "uvx --generate-shell-completion zsh" "$(command -v uvx)"
        fi

        # Mole shell completion
        if command -v mole &>/dev/null; then
          _source_cached_completion "mole" "mole completion zsh" "$(command -v mole)"
        fi

        # Load env vars from a 1Password Environment into the current shell.
        # Requires 1Password CLI beta with `op environment read`.
        oploadenv() {
          if [ $# -ne 1 ]; then
            echo "usage: oploadenv <OP_ENVIRONMENT_ID>" >&2
            return 2
          fi
          if ! op environment read --help >/dev/null 2>&1; then
            echo "op environment read is not available in this op build" >&2
            echo "Hint: requires 1Password CLI >= 2.33.0-beta.02" >&2
            return 1
          fi

          set -a
          source <(op environment read "$1")
          set +a
        }

        # ── nixify (bootstrap direnv for a flake project) ──
        nixify() {
          if [[ ! -f flake.nix ]]; then
            echo "No flake.nix in current directory" >&2
            return 1
          fi
          echo "use flake" > .envrc
          direnv allow
        }

        # ── Edit command buffer (Ctrl+X Ctrl+E) ──
        autoload -Uz edit-command-line
        zle -N edit-command-line
        bindkey '^X^E' edit-command-line

        # ── Copy command buffer to clipboard (Ctrl+X c) ──
        function copy-buffer-to-clipboard() {
          if command -v pbcopy &>/dev/null; then
            echo -n "$BUFFER" | pbcopy
          elif command -v wl-copy &>/dev/null; then
            echo -n "$BUFFER" | wl-copy
          fi
          zle -M "Copied to clipboard"
        }
        zle -N copy-buffer-to-clipboard
        bindkey '^Xc' copy-buffer-to-clipboard

        # ── zmv (batch rename/move) ──
        autoload -Uz zmv

        # ── Suffix aliases (type a filename to open it) ──
        alias -s md=bat
        alias -s log=bat
        alias -s txt=bat
        alias -s json='bat --language=json'
        alias -s nix='$EDITOR'

        # ── Global aliases (usable anywhere in a command) ──
        alias -g NE='2>/dev/null'
        alias -g NUL='>/dev/null 2>&1'
        alias -g J='| jq'
        alias -g L='| less'
        alias -g H='| head'
        alias -g T='| tail'
        alias -g S='| sort'
        alias -g U='| sort -u'
        alias -g WC='| wc -l'

        function set_win_title() {
          print -Pn "\033]0; %~ \007"
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
    enableNushellIntegration = true;
    settings = {
      command_timeout = 500;
      scan_timeout = 30;
      add_newline = true;
      continuation_prompt = "[.. ](dimmed white)";
      format = "($nix_shell$container$fill$git_metrics\n)$cmd_duration$status${env_var.SSH_CONNECTION}$username$hostname${env_var.VIMSHELL}$jobs$sudo$character";
      right_format = "$directory$git_branch$git_status$python$nodejs$rust$battery$time";

      fill.symbol = " ";

      character = {
        format = "$symbol ";
        success_symbol = "[\\$](bold cyan)";
        error_symbol = "[\\$](bold red)";
        vimcmd_symbol = "[:\\$](dimmed green)";
        vimcmd_replace_one_symbol = "[r\\$](dimmed yellow)";
        vimcmd_replace_symbol = "[R\\$](dimmed yellow)";
        vimcmd_visual_symbol = "[v\\$](dimmed cyan)";
      };

      status = {
        disabled = false;
        format = "[x$status]($style) ";
        style = "bold red";
      };

      env_var.SSH_CONNECTION = {
        format = "[ssh>](bold cyan)";
        style = "bold cyan";
      };

      env_var.VIMSHELL = {
        format = "[$env_value]($style)";
        style = "cyan";
      };

      sudo = {
        format = "[$symbol]($style) ";
        style = "bold purple";
        symbol = "#";
        disabled = false;
      };

      username = {
        style_user = "dimmed cyan";
        style_root = "red bold";
        format = "[$user@]($style)";
        disabled = false;
        show_always = true;
        aliases = {
          tomrfitz = "trf";
        };
      };

      directory = {
        home_symbol = "~";
        truncation_length = 8;
        truncate_to_repo = false;
        truncation_symbol = ".../";
        read_only = " [ro]";
        use_os_path_sep = true;
        style = "blue";
        format = "[$path]($style)[$read_only]($read_only_style)";
      };

      cmd_duration.format = "[$duration ](dimmed white)";

      jobs = {
        format = "[&$number]($style) ";
        style = "dimmed white";
      };

      hostname = {
        ssh_only = false;
        trim_at = ".";
        format = "[$hostname]($style) ";
        style = "dimmed cyan";
        aliases = {
          trfmbp = "mbp";
          trfnix = "nix";
          trfwsl = "wsl";
          trflab = "lab";
        };
      };

      time = {
        disabled = false;
        format = "[ $time]($style)";
        time_format = "%R";
        utc_time_offset = "local";
        style = "dimmed white";
      };

      battery = {
        format = "[ $percentage $symbol]($style)";
        full_symbol = "=";
        charging_symbol = "[^](bold green)";
        discharging_symbol = "v";
        unknown_symbol = "?";
        empty_symbol = "!";
        display = [
          {
            threshold = 20;
            style = "bold red";
          }
          {
            threshold = 40;
            style = "dimmed orange";
          }
          {
            threshold = 75;
            style = "dimmed yellow";
          }
          {
            threshold = 100;
            style = "dimmed green";
          }
        ];
      };

      git_branch = {
        format = " [$branch(:$remote_branch)]($style)";
        style = "blue";
        truncation_symbol = "...";
        truncation_length = 11;
        ignore_branches = [
          "main"
          "master"
        ];
        only_attached = true;
      };

      git_metrics = {
        format = "([+$added]($added_style))([-$deleted]($deleted_style))";
        added_style = "dimmed green";
        deleted_style = "dimmed red";
        ignore_submodules = true;
        disabled = false;
      };

      git_status = {
        style = "bold blue";
        format = "([$ahead_behind$staged$modified$untracked$renamed$deleted$conflicted$stashed]($style))";
        conflicted = "[!](magenta)";
        ahead = "[up [\${count}](bold white)](green)";
        behind = "[dn [\${count}](bold white)](red)";
        diverged = "[up [\${ahead_count}](bold white) dn [\${behind_count}](bold white)](magenta)";
        untracked = "[?](yellow)";
        stashed = "[s](dimmed white)";
        modified = "[*](orange)";
        staged = "[+\${count}](cyan)";
        renamed = "[>](blue)";
        deleted = "[-](red)";
      };

      # Language modules — just "lang version" with color, no decorative symbols
      deno = {
        format = " [deno $version]($style)";
        version_format = "\${raw}";
        style = "green bold";
      };

      lua = {
        format = " [lua \${version}]($style)";
        version_format = "\${raw}";
        style = "bold yellow";
      };

      nodejs = {
        format = " [node ($version)]($style)";
        version_format = "\${raw}";
        style = "bold green";
        detect_files = [
          "package-lock.json"
          "yarn.lock"
        ];
        detect_folders = [ "node_modules" ];
        detect_extensions = [ ];
      };

      python = {
        format = " [py \${version}]($style)";
        version_format = "\${raw}";
        style = "bold yellow";
      };

      ruby = {
        format = " [rb \${version}]($style)";
        version_format = "\${raw}";
        style = "bold red";
      };

      rust = {
        format = " [rs $version]($style)";
        version_format = "\${raw}";
        style = "bold orange";
      };

      package = {
        format = " [pkg $version]($style)";
        version_format = "\${raw}";
        style = "bold yellow";
      };

      swift = {
        format = " [sw \${version}]($style)";
        version_format = "\${raw}";
        style = "bold red";
      };

      aws = {
        disabled = true;
        format = " [aws $profile $region]($style)";
        style = "bold blue";
      };

      buf.format = " [buf $version]($style)";

      c.format = " [c ($version(-$name))]($style)";

      cpp.format = " [c++ ($version(-$name))]($style)";

      conda.format = " [conda $environment]($style)";

      pixi.format = " [pixi $version ($environment)]($style)";

      dart.format = " [dart ($version)]($style)";

      docker_context.format = " [docker $context]($style)";

      elixir.format = " [elixir $version OTP $otp_version]($style)";

      elm.format = " [elm ($version)]($style)";

      golang.format = " [go ($version)]($style)";

      haskell = {
        format = " [hs ($version)]($style)";
      };

      java.format = " [java (\${version})]($style)";

      julia.format = " [jl ($version)]($style)";

      memory_usage.format = " [mem \${ram}( \${swap})]($style)";

      nim.format = " [nim ($version)]($style)";

      nix_shell = {
        style = "bold blue";
        format = "[nix($state)]($style) [$name](dimmed white)";
        impure_msg = "[:impure](bold dimmed red)";
        pure_msg = "[:pure](bold dimmed green)";
        unknown_msg = "";
      };

      spack.format = " [spack $environment]($style)";
    };
  };

  # ── Atuin (shell history) ──────────────────────────────────────────────
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
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
    enableFishIntegration = true;
  };

  # ── Fzf ────────────────────────────────────────────────────────────────
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };

  # ── Direnv (auto-load project environments) ─────────────────────────
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
