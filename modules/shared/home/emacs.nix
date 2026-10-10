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
  # (modifiers, pixel-scroll-precision-mode; system dark/light is polled by
  # auto-dark — upstream NS has no appearance hook, that's an emacs-plus
  # patch we'd have to apply here at the cost of a local Emacs build). Icon
  # overlay via runCommand on darwin: no emacs rebuild on nixpkgs bumps, just
  # a cp pass.
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

    extraEmacsPackages = epkgs: [
      # Pre-provision tree-sitter grammars so pilish (and any other treesit
      # user) doesn't prompt to build them on first run.
      epkgs.treesit-grammars.with-all-grammars
    ];
  };

  # Icon overlay on macOS — a copy of the packaged build with our Emacs.icns.
  # The Dock shows the icon of the bundle the *running* binary sits in, and
  # emacsWithPackages' Emacs.app only wraps: its script execs the binary in
  # nixpkgs' own bundle, which has the stock icon. So the binary (3.6 MB; its
  # lisp and libexec paths are absolute) is copied into this bundle, with the
  # native-lisp link Emacs resolves next to it, and the wrapper script becomes
  # the bundle's executable, pointed at the copy. Still no Emacs rebuild.
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
          app=$out/Applications/Emacs.app/Contents
          base=${emacsBase}/Applications/Emacs.app/Contents
          cp ${icon} $app/Resources/Emacs.icns
          cp $base/MacOS/Emacs $app/MacOS/Emacs-unwrapped
          ln -s "$(readlink -f $base/native-lisp)" $app/native-lisp
          mv $app/MacOS/.Emacs-wrapped $app/MacOS/Emacs
          substituteInPlace $app/MacOS/Emacs \
            --replace-fail "$base/MacOS/Emacs" "$app/MacOS/Emacs-unwrapped" \
            --replace-fail "${emacsWithPkgs}/Applications/Emacs.app/Contents/MacOS/" "$app/MacOS/"
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
    # `dot' for org-babel's Graphviz blocks.
    pkgs.graphviz
    # agent-shell's Claude Code backend (init.el). nixpkgs points it at its own
    # claude-code; on macOS it gets Anthropic's installed CLI instead, the copy
    # the rest of the Mac runs (claude-code.nix).
    (
      if pkgs.stdenv.hostPlatform.isDarwin then
        pkgs.claude-agent-acp.override {
          claude-code = pkgs.writeShellApplication {
            name = "claude";
            text = ''exec "$HOME/.local/bin/claude" "$@"'';
          };
        }
      else
        pkgs.claude-agent-acp
    )
  ];

  # Emacs as a daemon on both platforms: a systemd user service on NixOS, a
  # launchd agent (`emacs --fg-daemon`, org.nix-community.home.emacs) on
  # macOS, so Emacs is always up and frames come and go like a menu-bar
  # app's windows (Hyper+E / Hyper+C in config/karabiner.json; Cmd-Q closes
  # the frames, see init.el). The macport could not open GUI frames from
  # launchd, so macOS ran the GUI app as the server until the NS build
  # replaced it; a hand-launched Emacs.app still becomes the server when the
  # daemon is down.
  # A switch changes nothing in a running daemon: restart it with
  # `launchctl kickstart -k gui/$(id -u)/org.nix-community.home.emacs` (NixOS:
  # `systemctl --user restart emacs`). M-x kill-emacs stops it until the next
  # login or kickstart. To see what a server is running, ask it
  # (`emacsclient -e`); `ps` shows the bare Emacs path even for the wrapped
  # build. The socket is $TMPDIR/emacs$UID/server, so a shell with another
  # TMPDIR (an agent's sandbox) needs `--socket-name=<absolute path>`.
  services.emacs = {
    enable = true;
    package = emacs;
  };

  # macOS: launchd jobs and apps launched via LaunchServices don't source
  # hm-session-vars.sh, so they lack TERMINFO — and `emacsclient -t' TTY
  # frames would then fail to resolve TERM=xterm-ghostty (Ghostty installs
  # that entry only under ~/.local/share/terminfo). The daemon gets it in its
  # own environment (no race with the setenv agent at login); the setenv
  # agent publishes it to the GUI session for a hand-launched Emacs.app.
  # Start the daemon from the executable inside Emacs.app, not bin/emacs:
  # outside the bundle macOS reports no bundle ID (app name "emacs"), so
  # paneru's org.gnu.Emacs rules miss its frames and tile the posframe
  # minibuffer beside the main frame.
  launchd.agents.emacs.config.ProgramArguments = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
    lib.mkForce [
      "${emacs}/Applications/Emacs.app/Contents/MacOS/Emacs"
      "--fg-daemon"
    ]
  );
  launchd.agents.emacs.config.EnvironmentVariables = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    TERMINFO = "${config.xdg.dataHome}/terminfo";
  };
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
