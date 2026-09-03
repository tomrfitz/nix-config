{
  pkgs,
  lib,
  ...
}:
{
  # ── Packages (things without a dedicated programs.* module) ────────────
  home.packages =
    with pkgs;
    [
      (callPackage ../../../pkgs/sgram-tui { })

      yazi

      mcrcon

      # code formatters (available globally so editors find them)
      shellcheck
      shfmt
      markdownlint-cli2
      sql-formatter
      dprint

      # LSP multiplexer (lets eglot run multiple servers per buffer, e.g. ty + ruff)
      rassumfrassum

      # nix tooling
      nix-init
      claude-code
      llm-agents.pi
      dix
      nh
      nixd
      nixfmt
      just

      # utilities
      _1password-cli
      coreutils
      findutils
      curl
      wget
      tree
      gnused
      gnutar
      gnugrep
      gawk
      pandoc
      tldr
      witr
      streamlink # launched by Chatterino ("open in streamlink", player = IINA), never from a shell

    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      # Ensure SSH sessions from Ghostty render correctly on Linux hosts.
      ghostty.terminfo
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      xcodes
    ];
}
