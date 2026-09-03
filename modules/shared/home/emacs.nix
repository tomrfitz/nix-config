{
  pkgs,
  lib,
  config,
  homebrew-emacs-plus,
  ...
}:
let
  iconDir = "${homebrew-emacs-plus}/community/icons/liquid-glass";

  # macOS: emacs30-macport (Mitsuharu Yamamoto patches — currently on
  # jdtsmith/emacs-mac community fork; see TODO.md upstream watchlist).
  # Cached on cache.nixos.org. Icon overlay via runCommand: no emacs
  # rebuild on nixpkgs bumps, just a cp pass over the closure (~seconds).
  # NixOS: stock emacs30.
  emacsBase = if pkgs.stdenv.isDarwin then pkgs.emacs30-macport else pkgs.emacs30;

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
    if pkgs.stdenv.isDarwin then
      pkgs.runCommand "emacs-macport-with-icon"
        {
          meta = emacsWithPkgs.meta // {
            mainProgram = "emacs";
          };
        }
        ''
          mkdir -p $out
          cp -a ${emacsWithPkgs}/. $out/
          chmod -R u+w $out
          cp ${iconDir}/icon.icns $out/Applications/Emacs.app/Contents/Resources/Emacs.icns
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
  #   macOS — NO launchd daemon. On the macport a launchd-started daemon never
  #           gets window-server (Aqua) access, so it can't create GUI frames
  #           ("Mac native windows are not in use or not initialized"). Instead
  #           the GUI Emacs.app you launch from your session (Dock/Spotlight)
  #           calls (server-start) in init.el and IS the canonical server;
  #           `emacsclient' and Dock re-clicks attach to it as clients.
  services.emacs = {
    enable = !pkgs.stdenv.isDarwin;
    package = emacs;
  };

  # macOS: apps launched via LaunchServices (clicking Emacs.app) don't source
  # hm-session-vars.sh, so they lack TERMINFO — and `emacsclient -t' TTY frames
  # would then fail to resolve TERM=xterm-ghostty (Ghostty installs that entry
  # only under ~/.local/share/terminfo). Publish it into the GUI login session
  # so the server inherits it. `launchctl setenv' returns immediately; no daemon.
  launchd.agents.emacs-gui-env = lib.mkIf pkgs.stdenv.isDarwin {
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
