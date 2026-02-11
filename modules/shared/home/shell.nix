{
  config,
  pkgs,
  lib,
  ...
}:
{
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
    settings = lib.importTOML ../../../config/starship.toml;
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
}
