{
  config,
  lib,
  ...
}:
{
  # Override EDITOR — brew cask installs a `zed` CLI shim at /usr/local/bin/zed.
  # Only where Zed is configured (desktop.nix); a headless Mac sets its own.
  home.sessionVariables.EDITOR = lib.mkIf config.programs.zed-editor.enable (
    lib.mkForce "zed --wait"
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
