{
  pkgs,
  lib,
  ...
}:
let
  # The nix-packaged `zeditor` CLI can't connect to the running Zed.app
  # (different bundle/socket path). Use the HM-linked .app's CLI instead.
  zedCli = "~/Applications/Home\\ Manager\\ Apps/Zed.app/Contents/MacOS/cli";
in
{
  # Override EDITOR to use the .app CLI that can actually talk to the running Zed
  home.sessionVariables.EDITOR = lib.mkForce "${zedCli} --wait";

  programs.zsh = {
    shellAliases = {
      zed = zedCli;
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
