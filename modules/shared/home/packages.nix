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
      # opencode # heavy — re-enable before darwin rebuild
      # obsidian # heavy — re-enable before darwin rebuild
      # (callPackage ../../../pkgs/mdbase-tasknotes { })

      # docker # heavy — re-enable before darwin rebuild
      # dockerfmt

      # dev toolchains
      # rustup # heavy — re-enable before darwin rebuild
      go
      nodejs
      python3
      # deno # heavy — re-enable before darwin rebuild
      # dart # heavy — re-enable before darwin rebuild
      # elixir # heavy — re-enable before darwin rebuild
      lua
      # php # heavy — re-enable before darwin rebuild
      # zig # heavy — re-enable before darwin rebuild
      # vlang # heavy — re-enable before darwin rebuild
      # c3c # heavy — re-enable before darwin rebuild
      # c3-lsp # heavy — re-enable before darwin rebuild
      # openjdk # heavy — re-enable before darwin rebuild
      # typst # heavy — re-enable before darwin rebuild
      nasm
      bun
      # turso

      # build tools
      nixpkgs-review
      cmake
      gnumake
      ninja
      # bear
      # automake
      # autoconf-archive
      ccache
      # clang-tools # heavy — re-enable before darwin rebuild
      # cppcheck
      # doxygen
      # boost # heavy — re-enable before darwin rebuild
      # rapidjson
      # raylib # heavy — re-enable before darwin rebuild
      # libffi
      # gst_all_1.gstreamer # heavy — re-enable before darwin rebuild
      # qt6Packages.qtbase # heavy — re-enable before darwin rebuild
      # wxGTK32 # heavy — re-enable before darwin rebuild

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
      # beets # heavy — re-enable before darwin rebuild
      termdown
      virtualenv

      # nix tooling
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
      # streamlink
      texinfo
      tldr
      ansifilter
      # fontforge # heavy — re-enable before darwin rebuild
      termshot
      lf
      lsd
      micro
      kakoune
      witr
      todo-txt-cli
      timewarrior
      taskwarrior-tui
      # texlive.combined.scheme-full # very heavy — re-enable before darwin rebuild
      gtypist
      # ncspot
      # mailsy
      # gemini-cli
      # powershell # heavy — re-enable before darwin rebuild
      cargo-update
      cargo-cache
      # gossip # broken on aarch64-darwin (SDL2 CMake version conflict) — revisit later

      # apps (migrated from Homebrew casks)
      # discord # heavy — re-enable before darwin rebuild
      # slack # heavy — re-enable before darwin rebuild
      # thunderbird # heavy — re-enable before darwin rebuild
      # notesnook # heavy — re-enable before darwin rebuild
      # audacity # heavy — re-enable before darwin rebuild
      # sqlitebrowser # heavy — re-enable before darwin rebuild
      # lapce # heavy — re-enable before darwin rebuild
      # inkscape # heavy — re-enable before darwin rebuild
      # prismlauncher # heavy — re-enable before darwin rebuild
      # anki # heavy — re-enable before darwin rebuild
      # chatterino2 # heavy — re-enable before darwin rebuild
      # qbittorrent # heavy — re-enable before darwin rebuild

      # fun
      # pear-desktop # heavy — re-enable before darwin rebuild
      # zotero # heavy — re-enable before darwin rebuild
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
      # picard # heavy — re-enable before darwin rebuild
      # rustdesk # heavy — re-enable before darwin rebuild
      # element-desktop # heavy — re-enable before darwin rebuild
      # praat # heavy — re-enable before darwin rebuild
    ];
}
