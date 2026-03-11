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
      comma
      yazi
      tailscale
      python3Packages.markitdown

      mcrcon

      # code formatters (available globally so editors find them)
      shellcheck
      shfmt

      # nix tooling
      claude-code
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
