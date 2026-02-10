{
  config,
  pkgs,
  lib,
  ...
}:
{
  home.homeDirectory = lib.mkForce "/Users/tomrfitz";

  # ── macOS-specific packages ────────────────────────────────────────────
  home.packages = with pkgs; [
    emacs
    mas
    swiftformat
    swiftlint
    bun
    opencode
    turso
    container
  ];

  # ── macOS-specific session variables ───────────────────────────────────
  home.sessionVariables = {
    OBSD = "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian/";
    SCRNSHT = "$HOME/Documents/Screenshots/";
    NVM_DIR = "$HOME/.nvm";
  };

  home.sessionPath = [
    "$HOME/.juliaup/bin"
    "$HOME/.config/emacs/bin"
    "$HOME/vcpkg"
    "$HOME/.cache/.bun/bin"
  ];

  # ── macOS-specific zsh config ──────────────────────────────────────────
  programs.zsh = {
    shellAliases = {
      regossip = "cd ~/gossip && git pull && RUSTFLAGS=\"-C target-cpu=native --cfg tokio_unstable\" cargo build --release --features=lang-cjk && strip ./target/release/gossip && ./target/release/gossip";
      code = "open -b com.microsoft.vscode";
      ytm = "z pear && pnpm start";
    };

    profileExtra = lib.mkAfter ''
      if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      elif command -v brew &>/dev/null; then
        eval "$(brew shellenv)"
      fi

      typeset -U path
      path+=("$HOME/Library/Application Support/JetBrains/Toolbox/scripts")
      path+=("$HOME/Library/Application Support/Coursier/bin")
      export PATH
    '';

    initContent = ''
      # Bun completions
      [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

      # NVM
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

      # Dynamic PATH (yarn)
      path+=("$(yarn global bin 2>/dev/null || echo "")")

      # Journal note function (syncs to Obsidian on macOS)
      jn() {
        local ts fn
        ts="## [$(date +%H:%M:%S)]"
        fn="$(date +%F).md"

        local local_file="$HOME/notes/$fn"
        local obsidian_dir="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian/Journal/Daily"
        local obsidian_file="$obsidian_dir/$fn"

        mkdir -p "$HOME/notes" "$obsidian_dir"

        if [ $# -gt 0 ]; then
          {
            echo -e "$ts"
            echo "$*"
            echo
          } >>"$local_file"
        else
          echo "Start typing your note. Press Ctrl+D when finished:"
          {
            echo -e "$ts"
            cat
            echo
          } >>"$local_file"
        fi

        if rsync -a "$local_file" "$obsidian_file"; then
          echo "Saved to $local_file and synced to Obsidian."
        else
          echo "⚠️  Saved locally, but sync to Obsidian failed."
        fi
      }
    '';
  };

  # ── Git: macOS-specific (1Password SSH signing, gh credential) ──────
  programs.git.settings = {
    gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    credential = {
      "https://github.com" = {
        helper = [
          ""
          "!${pkgs.gh}/bin/gh auth git-credential"
        ];
      };
      "https://gist.github.com" = {
        helper = [
          ""
          "!${pkgs.gh}/bin/gh auth git-credential"
        ];
      };
    };
  };

  # ── SSH: macOS-specific (1Password agent socket) ─────────────────────
  programs.ssh.matchBlocks."*" = {
    extraOptions = {
      AddKeysToAgent = "yes";
      IdentityAgent = "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
    };
  };

  # ── Topgrade: macOS-specific (brew, nix-darwin rebuild) ────────────────
  programs.topgrade.settings = {
    commands = {
      "Nix Flake Update + Darwin Rebuild" =
        "cd ~/nixos-config && nix flake update && sudo darwin-rebuild switch --flake .#tomrfitz";
    };
    brew = {
      greedy_latest = true;
      greedy_auto_updates = true;
      autoremove = true;
      fetch_head = true;
    };
  };

  # ── Ghostty: macOS-specific overrides (installed via brew cask) ────────
  programs.ghostty = {
    package = null;
    settings = {
      quick-terminal-position = "center";
      custom-shader-animation = true;
      window-padding-y = 5;
      window-position-y = 150;
      window-position-x = 175;
      window-step-resize = true;
      keybind = [
        "global:shift+ctrl+backquote=new_window"
        "global:ctrl+backquote=toggle_quick_terminal"
      ];
      macos-titlebar-style = "tabs";
      macos-option-as-alt = true;
      auto-update = "download";
      auto-update-channel = "tip";
    };
  };
}
