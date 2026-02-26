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
      texinfo
      tldr
      ansifilter
      termshot
      lf
      lsd
      witr
      todo-txt-cli
      timewarrior
      taskwarrior-tui
      gtypist
      mailsy
      gemini-cli
      termdown
      codex
      antigravity

      # gossip # broken on aarch64-darwin (SDL2 CMake version conflict) — revisit later

      # apps
      discord
      slack
      thunderbird
      notesnook
      audacity
      sqlitebrowser
      prismlauncher
      # REVISIT(upstream): remove override once anki check phase has QtWebChannel in test deps;
      # ref: https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/an/anki/package.nix; checked: 2026-02-25
      (anki.overrideAttrs { doInstallCheck = false; })
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
      xcodes
    ]
    ++ lib.optionals (!pkgs.stdenv.isDarwin) [
      picard # brew cask "musicbrainz-picard" on darwin (qtwayland dep)
      rustdesk # brew cask on darwin (badPlatforms)
      element-desktop # brew cask on darwin (actool/Xcode build dep)
      praat # linux-only
    ];
}
