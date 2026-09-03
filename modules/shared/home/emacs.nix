{
  pkgs,
  lib,
  config,
  ...
}:
let
  # Liquid-glass icon from the emacs-plus tap (its only use here), pinned to
  # the commit that added it; the file has not changed since.
  icon = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/92bd70be4e25800e2b8ca93619e71627dcf58ae9/community/icons/liquid-glass/icon.icns";
    hash = "sha256-N+3n5lHuRsWpFP0RuYDJLD72kuQcsmduJRjQnk19Xek=";
  };

  # nixpkgs' emacs (31.x, cached) on both platforms. The darwin macport
  # (Mitsuharu's patches, 30.2.50 with no 31 in sight) was dropped 2026-09-03:
  # the 30/31 split constrained init.el, and the NS build covers the config
  # (appearance hook, modifiers, pixel-scroll-precision-mode). Icon overlay via
  # runCommand on darwin: no emacs rebuild on nixpkgs bumps, just a cp pass.
  emacsBase = pkgs.emacs;

  # Derive the package set from `use-package` declarations in init.el.
  # Single source of truth: add a `(use-package foo :ensure t ...)` block
  # in init.el and the parser picks it up on next rebuild.
  # `alwaysEnsure = false` (the post-API-break default) honors per-block
  # `:ensure` annotations — critical so the `:ensure nil` on `org` keeps the
  # built-in version instead of shadowing it with the MELPA package.
  # emacsWithPackagesFromUsePackage is a top-level helper added by emacs-overlay
  # (see overlays/default.nix in nix-community/emacs-overlay).
  emacsWithPkgs = pkgs.emacsWithPackagesFromUsePackage {
    package = emacsBase;
    config = ../../../config/emacs/init.el;
    alwaysEnsure = false;

    override = _self: super: {
      # REVISIT(upstream): the pi-coding-agent MELPA package became a deprecated
      #   alias for `piem` (2026-09) but declares none of piem's Package-Requires,
      #   so it cannot byte-compile in isolation (md-ts-mode is a MELPA package
      #   on every Emacs we run, 31.1 included). Give it piem's deps; drop once
      #   MELPA has a `piem` recipe (then `use-package piem`) or the shim's
      #   header is fixed.
      #   ref: https://github.com/dnouri/piem; checked: 2026-09-03
      pi-coding-agent = super.pi-coding-agent.overrideAttrs (old: {
        packageRequires =
          (old.packageRequires or [ ])
          ++ (with super; [
            transient
            magit-section
            md-ts-mode
            markdown-table-wrap
          ]);
      });
    };

    extraEmacsPackages = epkgs: [
      # Pre-provision tree-sitter grammars so pi-coding-agent (and any other
      # treesit user) doesn't prompt to build them on first run.
      epkgs.treesit-grammars.with-all-grammars
    ];
  };

  # Icon overlay on macOS — wraps the packaged build. cp -a preserves the
  # emacsWithPackages wrapper script and the .app bundle; we only overwrite
  # Emacs.icns.
  emacs =
    if pkgs.stdenv.hostPlatform.isDarwin then
      pkgs.runCommand "emacs-with-icon"
        {
          meta = emacsWithPkgs.meta // {
            mainProgram = "emacs";
          };
        }
        ''
          mkdir -p $out
          cp -a ${emacsWithPkgs}/. $out/
          chmod -R u+w $out
          cp ${icon} $out/Applications/Emacs.app/Contents/Resources/Emacs.icns
        ''
    else
      emacsWithPkgs;
in
{
  # Deploy vanilla Emacs config to XDG location (~/.config/emacs/)
  # Emacs 29+ natively supports XDG — no ~/.emacs.d/ needed
  xdg.configFile."emacs" = {
    source = ../../../config/emacs;
    recursive = true;
  };

  home.packages = [
    emacs
    # Self-contained wrapper: bakes dict-dir into ASPELL_CONF, so spell
    # checking works in GUI Emacs on macOS (no NIX_PROFILES in the
    # LaunchServices environment) and under the Linux daemon.
    (pkgs.aspellWithDicts (d: [
      d.en
      d.it
    ]))
  ];

  # Emacs as a server.
  #   NixOS — a systemd user daemon (`emacs --daemon`).
  #   macOS — no launchd daemon: the GUI Emacs.app you launch from your session
  #           (Dock/Spotlight) calls (server-start) in init.el and IS the
  #           canonical server; `emacsclient' and Dock re-clicks attach to it.
  #           (Chosen when the macport could not open GUI frames from launchd;
  #           the NS build could run `services.emacs` as a user agent instead —
  #           revisit if the GUI-app-as-server arrangement ever annoys.)
  services.emacs = {
    enable = !pkgs.stdenv.hostPlatform.isDarwin;
    package = emacs;
  };

  # macOS: apps launched via LaunchServices (clicking Emacs.app) don't source
  # hm-session-vars.sh, so they lack TERMINFO — and `emacsclient -t' TTY frames
  # would then fail to resolve TERM=xterm-ghostty (Ghostty installs that entry
  # only under ~/.local/share/terminfo). Publish it into the GUI login session
  # so the server inherits it. `launchctl setenv' returns immediately; no daemon.
  launchd.agents.emacs-gui-env = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    enable = true;
    config = {
      ProgramArguments = [
        "/bin/launchctl"
        "setenv"
        "TERMINFO"
        "${config.xdg.dataHome}/terminfo"
      ];
      RunAtLoad = true;
    };
  };
}
