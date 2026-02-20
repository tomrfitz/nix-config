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
      obsidian
      (callPackage ../../../pkgs/mdbase-tasknotes { })

      yazi
      tailscale
      python3Packages.markitdown

      docker
      dockerfmt

      # dev toolchains
      rustup
      go
      nodejs
      python3
      deno
      dart
      elixir
      lua
      php
      zig
      vlang
      c3c
      c3-lsp
      openjdk
      typst
      nasm
      bun
      turso

      # C/C++ compiler and tools
      clang

      # build tools
      nixpkgs-review
      cmake
      gnumake
      ninja
      bear
      automake
      autoconf-archive
      ccache
      clang-tools
      cppcheck
      doxygen
      boost
      rapidjson
      raylib
      libffi
      gst_all_1.gstreamer
      qt6Packages.qtbase
      wxGTK32

      # go tools
      delve
      gopls
      gotests
      impl
      go-tools # staticcheck

      # node tools
      markdownlint-cli2
      nodePackages.prettier
      nodePackages.yarn

      # python tools
      uv
      ty
      termdown
      virtualenv

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
      shellcheck
      shfmt
      silver-searcher
      speedtest-cli
      stow
      streamlink
      texinfo
      tldr
      ansifilter
      fontforge
      termshot
      lf
      lsd
      kakoune
      witr
      todo-txt-cli
      timewarrior
      taskwarrior-tui
      texlive.combined.scheme-full
      gtypist
      mailsy
      gemini-cli
      powershell
      cargo-update
      cargo-cache
      # gossip # broken on aarch64-darwin (SDL2 CMake version conflict) — revisit later

      # apps (migrated from Homebrew casks)
      discord
      slack
      thunderbird
      notesnook
      audacity
      sqlitebrowser
      lapce

      prismlauncher
      anki
      chatterino2
      qbittorrent

      # fun
      pear-desktop
      zotero
      _2048-in-terminal
      cbonsai
      cowsay
      figlet
      fortune
      pipes
      mufetch

      # fonts (migrated from Homebrew casks)
      aporetic
      atkinson-hyperlegible-mono
      atkinson-hyperlegible
      atkinson-hyperlegible-next
      fira-code
      nerd-fonts.hack
      iosevka-bin
      (iosevka-bin.override { variant = "Aile"; })
      (iosevka-bin.override { variant = "Etoile"; })
      nerd-fonts.iosevka-term
      nerd-fonts.jetbrains-mono
      maple-mono.NF
      monaspace
      nerd-fonts.symbols-only
      noto-fonts-color-emoji
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      swiftlint
      swiftformat
      xcodes
    ]
    ++ lib.optionals (!pkgs.stdenv.isDarwin) [
      picard # brew cask "musicbrainz-picard" on darwin (qtwayland dep)
      rustdesk # brew cask on darwin (badPlatforms)
      element-desktop # brew cask on darwin (actool/Xcode build dep)
      praat # linux-only
    ];
}
