{
  lib,
  ...
}:
{
  # Override EDITOR — brew cask installs a `zed` CLI shim at /usr/local/bin/zed
  home.sessionVariables.EDITOR = lib.mkForce "zed --wait";

  programs.zsh = {

    profileExtra = lib.mkAfter ''
      if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      elif command -v brew &>/dev/null; then
        eval "$(brew shellenv)"
      fi

    '';

    initContent = ''
      # ── macOS-only global aliases ──
      alias -g C='| pbcopy'

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
