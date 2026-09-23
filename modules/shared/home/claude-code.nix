# Claude Code — home-manager owns the config on every host; who owns the binary
# depends on the platform. On macOS it is Anthropic's native installer
# (~/.local/bin/claude, self-updating; scripts/bootstrap.sh runs it): the
# desktop app bundles its own self-updating copy and reads the same ~/.claude,
# so a nix-pinned CLI would only trail both against shared state. Linux keeps
# nixpkgs, which patches the prebuilt binary for NixOS and wraps it with
# DISABLE_AUTOUPDATER.
{ lib, pkgs, ... }:
{
  programs.claude-code = {
    enable = true;
    package = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin null;
    settings = lib.importJSON ../../../config/claude-settings.json;
    context = ../../../config/agents.md;
  };
}
