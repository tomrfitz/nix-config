{
  config,
  pkgs,
  lib,
  ...
}:
{
  # ── Packages (things without a dedicated programs.* module) ────────────
  home.packages = with pkgs; [
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
    openjdk
    typst
    nasm

    # build tools
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

    # python tools
    # poetry  # broken on aarch64-darwin (rapidfuzz atomics failure) — revisit later
    ruff
    ty
    beets
    termdown
    virtualenv

    # nix tooling
    nixd
    nil
    nixfmt
    alejandra
    nvd

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
    micro
    kakoune
    witr
    todo-txt-cli
    timewarrior
    taskwarrior-tui
    texlive.combined.scheme-full
    gtypist
    ncspot
    spotifyd
    mailsy
    gemini-cli
    powershell
    cargo-update
    cargo-cache
    zed-editor
    # gossip  # broken on aarch64-darwin (SDL2 CMake version conflict) — revisit later

    # fun
    _2048-in-terminal
    cbonsai
    cowsay
    figlet
    fortune
    pipes
    # cava  # broken on aarch64-darwin (unity-test build failure) — revisit later
    mufetch

    # fonts (migrated from Homebrew casks)
    aporetic
    atkinson-hyperlegible-mono
    fira-code
    nerd-fonts.hack
    iosevka-bin
    nerd-fonts.iosevka-term
    nerd-fonts.jetbrains-mono
    maple-mono.NF
    monaspace
    nerd-fonts.symbols-only
  ];
}
