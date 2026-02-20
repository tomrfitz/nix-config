{
  pkgs,
  lib,
  config,
  ...
}:
let
  isDarwin = pkgs.stdenv.isDarwin;
  vaultPath =
    if isDarwin then
      "${config.home.homeDirectory}/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian"
    else
      "${config.home.homeDirectory}/notes/vault";
  gitDir = "${config.home.homeDirectory}/notes/obsidian-git/.git";
  git = "${pkgs.git}/bin/git";
  repo = "git@github.com:tomrfitz/Obsidian.git";
in
{
  # ── Session environment ────────────────────────────────────────────────
  home.sessionVariables = {
    OBSD = "${vaultPath}/";
  };

  # ── Vault activation ──────────────────────────────────────────────────
  # Ensures the Obsidian vault repo exists with a separate git dir.
  # On a fresh machine this requires SSH access to GitHub; if that isn't
  # available yet the clone is skipped and retried on the next activation.
  home.activation.obsidian-vault = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    GIT_DIR="${gitDir}"
    VAULT="${vaultPath}"

    run mkdir -p "$(dirname "$GIT_DIR")" "$VAULT"

    # ── Clone (first run only) ──────────────────────────────────────────
    if [ ! -d "$GIT_DIR" ]; then
      if run ${git} clone --separate-git-dir="$GIT_DIR" \
           ${repo} "$VAULT" 2>&1; then
        verboseEcho "Obsidian vault cloned to $VAULT"
      else
        verboseEcho "Obsidian vault clone skipped (SSH not ready?); will retry next activation"
      fi
    fi

    # ── Fixups (idempotent) ─────────────────────────────────────────────
    if [ -d "$GIT_DIR" ]; then
      # Ensure .git pointer in the worktree
      WANT="gitdir: $GIT_DIR"
      if [ ! -e "$VAULT/.git" ] || [ "$(cat "$VAULT/.git" 2>/dev/null)" != "$WANT" ]; then
        run printf '%s\n' "$WANT" > "$VAULT/.git"
      fi

      # Ensure core.worktree is set
      CURRENT="$(${git} --git-dir="$GIT_DIR" config --get core.worktree 2>/dev/null || true)"
      if [ "$CURRENT" != "$VAULT" ]; then
        run ${git} --git-dir="$GIT_DIR" config core.worktree "$VAULT"
      fi
    fi
  '';
}
