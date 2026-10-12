# oh-my-pi (omp), a pi fork on trial on the Mac since 2026-09-23. It runs on
# the Max API credits with the key from 1Password (anthropic-api-key.nix): a
# provider key in models.yml outranks omp's stored logins, and a failed key
# command does not fall through to them. Never `/login anthropic` here: omp's
# Claude Pro/Max login forges Claude Code's billing header.
#
# omp reads models.yml but never writes it; the rest of its state (config.yml
# with the model roles and memory settings, agent.db with the logins) stays its
# own in ~/.omp/agent. It reads user-level instructions from AGENTS.md here
# (~/.config/AGENTS.md is not one of its paths) and the shared skills from
# ~/.agents/skills (default.nix).
{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
  home.packages = [ pkgs.omp ];

  home.file = {
    ".omp/agent/AGENTS.md".source = ../../../config/agents.md;
    ".omp/agent/models.yml".source = (pkgs.formats.yaml { }).generate "omp-models.yml" {
      providers.anthropic.apiKey = "!${config.home.profileDirectory}/bin/anthropic-api-key";
    };
  };
}
