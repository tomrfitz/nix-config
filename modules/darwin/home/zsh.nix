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
      # ── macOS-only aliases ──
      alias -g C='| pbcopy'
    '';
  };
}
