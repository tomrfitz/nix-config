# Claude Code — home-manager owns the config on every host; who owns the binary
# depends on the platform. On macOS it is Anthropic's native installer
# (~/.local/bin/claude, self-updating; scripts/bootstrap.sh runs it): the
# desktop app bundles its own self-updating copy and reads the same ~/.claude,
# so a nix-pinned CLI would only trail both against shared state. Linux keeps
# nixpkgs, which patches the prebuilt binary for NixOS and wraps it with
# DISABLE_AUTOUPDATER.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.claude-code;
in
{
  programs.claude-code = {
    enable = true;
    package = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin null;
    context = ../../../config/agents.md;
  };

  # settings.json links out of the store into the working tree, not through
  # `settings`: Claude Code writes it at runtime (/effort, /model, permission
  # answers), which a read-only store file refuses with EACCES. Its edits land
  # in the repo as a diff to keep or revert.
  home.file."${cfg.configDir}/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/config/claude-settings.json";
}
