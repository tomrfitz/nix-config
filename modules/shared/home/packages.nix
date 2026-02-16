{
  config,
  pkgs,
  lib,
  ...
}:
{
  # ── Packages (things without a dedicated programs.* module) ────────────
  home.packages =
    with pkgs;
    [
      opencode
      obsidian
      (callPackage ../../../pkgs/mdbase-tasknotes { })

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
      xcodes

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
      ruff
      ty
      beets
      termdown
      virtualenv

      # nix tooling
      nixd
      nixfmt
      nvd
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
      swiftlint
      swiftformat
      texinfo
      tldr
      ansifilter
      fontforge
      termshot
      lf
      lsd
      micro
      kakoune
      witr
      todo-txt-cli
      timewarrior
      taskwarrior-tui
      texlive.combined.scheme-full
      gtypist
      ncspot
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
      inkscape
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
    ++ lib.optionals (!pkgs.stdenv.isDarwin) [
      picard # brew cask "musicbrainz-picard" on darwin (qtwayland dep)
      rustdesk # brew cask on darwin (badPlatforms)
      element-desktop # brew cask on darwin (actool/Xcode build dep)
      praat # linux-only
    ];
}
