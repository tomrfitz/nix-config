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

      # OCR: Zotero's OCR plugin shells out to tesseract and pdftoppm. Only the
      # languages read here (all ~130 are 1.2 GB); osd detects page rotation.
      (tesseract.override {
        enableLanguages = [
          "eng"
          "ita"
          "fra"
          "spa"
          "kor"
          "chi_sim"
          "chi_tra"
          "osd"
        ];
      })
      poppler-utils

    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      # Ensure SSH sessions from Ghostty render correctly on Linux hosts.
      ghostty.terminfo
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      xcodes

      # Hermes Agent, on trial since 2026-09-23 (omp, the other one, is in
      # omp.nix), bare: state lives in ~/.hermes. It can't use the Max API
      # credits yet: it sends Console keys with the sk-ant-usr- prefix as
      # Claude Code OAuth tokens, and with no key at all its anthropic provider
      # borrows Claude Code's own login, which the terms forbid. So leave that
      # provider unselected until the fix lands (TODO.md, Upstream Watchlist).
      # minimal: the CLI, TUI and web UI. upstream's default adds the optional
      # integrations (voice, TTS, messaging, ...), whose torch/onnxruntime
      # stack builds from source here: its nixpkgs' python3.12 set is uncached.
      hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.minimal
    ];
}
