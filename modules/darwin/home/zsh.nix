{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.zsh = {
    shellAliases = {
      regossip = "mkdir -p ~/gossip && cd ~/gossip && git pull && RUSTFLAGS=\"-C target-cpu=native --cfg tokio_unstable\" cargo build --release --features=lang-cjk && strip ./target/release/gossip && ./target/release/gossip";
      code = "open -b com.microsoft.vscode";
      zed = "~/Applications/Home\\ Manager\\ Apps/Zed.app/Contents/MacOS/cli";
      ytm = "z pear && pnpm start";
    };

    profileExtra = lib.mkAfter ''
      if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      elif command -v brew &>/dev/null; then
        eval "$(brew shellenv)"
      fi

    '';

    initContent = ''
      # Bun completions
      [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

      # NVM
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

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
}
