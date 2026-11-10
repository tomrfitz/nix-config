{
  hostName,
  lib,
  ...
}:
{
  # Override EDITOR — brew cask installs a `zed` CLI shim at /usr/local/bin/zed
  # fortis has no Zed: a frame on the Emacs daemon, which waits for C-x #.
  home.sessionVariables.EDITOR = lib.mkForce (
    if hostName == "fortis" then "emacsclient -c" else "zed --wait"
  );

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
