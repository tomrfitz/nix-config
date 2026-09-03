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
      aria2 # xcodes uses it for parallel downloads
      pandoc
      tldr
      witr
      termdown
      streamlink # launched by Chatterino ("open in streamlink", player = IINA), never from a shell

    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      # Ensure SSH sessions from Ghostty render correctly on Linux hosts.
      ghostty.terminfo
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      xcodes
    ];
}
