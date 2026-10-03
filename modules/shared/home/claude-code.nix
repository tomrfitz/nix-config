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
  link = path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/${path}";
in
{
  programs.claude-code = {
    enable = true;
    package = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin null;
    context = ../../../config/agents.md;
    # Servers declared in programs.mcp (zotero.nix) reach Claude Code through
    # the generated `hm` plugin, as mcp__plugin_hm_<server>__<tool>.
    enableMcpIntegration = true;
  };

  home.file = {
    # settings.json links out of the store into the working tree, not through
    # `settings`: Claude Code writes it at runtime (/effort, /model, permission
    # answers), which a read-only store file refuses with EACCES. Its edits land
    # in the repo as a diff to keep or revert.
    "${cfg.configDir}/settings.json".source = link "config/claude-settings.json";
    # Run by `statusLine` in settings.json.
    "${cfg.configDir}/statusline.sh".source = link "config/claude-statusline.sh";
    # Skills for every project, linked like pi-resources rather than through
    # `programs.claude-code.skills`: edits apply without a rebuild, and a new
    # skill needs no intent-to-add to be visible to the flake.
    "${cfg.configDir}/skills/handoff".source = link "config/skills/handoff";
    "${cfg.configDir}/skills/recall".source = link "config/skills/recall";
    "${cfg.configDir}/skills/zotero".source = link "config/skills/zotero";
  };
}
