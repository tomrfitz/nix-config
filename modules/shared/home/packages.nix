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
      (callPackage ../../../pkgs/mdbase-tasknotes { })
      (callPackage ../../../pkgs/sgram-tui { })

      rana
      yazi

      mcrcon

      # code formatters (available globally so editors find them)
      shellcheck
      shfmt
      markdownlint-cli2
      sql-formatter

      # LSP multiplexer (lets eglot run multiple servers per buffer, e.g. ty + ruff)
      rassumfrassum

      # nix tooling
      nurl
      nix-init
      statix
      claude-code
      llm-agents.hermes-agent
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
      aria2
      duf
      dust
      git-absorb
      git-filter-repo
      iperf3
      inetutils
      pandoc
      pass
      pdfgrep
      speedtest-cli
      streamlink
      tldr
      ansifilter
      termshot
      witr
      gtypist
      mailsy
      termdown

      # gossip # broken on aarch64-darwin (SDL2 CMake version conflict) — revisit later

      # fun
      _2048-in-terminal
      cbonsai
      cowsay
      figlet
      fortune
      pipes
      mufetch

    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      # Ensure SSH sessions from Ghostty render correctly on Linux hosts.
      ghostty.terminfo

      # Emacs (macOS uses emacs-plus via homebrew for native app integration)
      emacs
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      xcodes
    ];
}
