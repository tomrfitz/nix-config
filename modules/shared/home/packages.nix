{
  pkgs,
  lib,
  hermes-agent,
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

      # Agent harnesses on trial (2026-09-23), bare: no config; state lives in
      # ~/.omp and ~/.hermes. Run them on other providers: omp's Claude login
      # impersonates Claude Code (never `/login anthropic` there), and Hermes
      # reaches the subscription only through an experimental plugin (TODO.md).
      omp
      # minimal: the CLI, TUI and web UI. upstream's default adds the optional
      # integrations (voice, TTS, messaging, ...), whose torch/onnxruntime
      # stack builds from source here: its nixpkgs' python3.12 set is uncached.
      hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.minimal
    ];
}
