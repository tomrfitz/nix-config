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

      # Journal note function (writes directly to Obsidian vault)
      jn() {
        local ts fn
        ts="## [$(date +%H:%M:%S)]"
        fn="$(date +%F).md"

        local obsidian_dir="''${OBSD}Journal/Daily"
        local obsidian_file="$obsidian_dir/$fn"

        mkdir -p "$obsidian_dir"

        if [ $# -gt 0 ]; then
          {
            echo -e "$ts"
            echo "$*"
            echo
          } >>"$obsidian_file"
        else
          echo "Start typing your note. Press Ctrl+D when finished:"
          {
            echo -e "$ts"
            cat
            echo
          } >>"$obsidian_file"
        fi

        echo "Saved to $obsidian_file"
      }
    '';
  };
}
