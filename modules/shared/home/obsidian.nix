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
in
{
  # ── Session environment ────────────────────────────────────────────────
  home.sessionVariables = {
    OBSD = "${vaultPath}/";
  };

  # ── Vault activation ──────────────────────────────────────────────────
  home.activation.obsidian-vault = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    GIT_DIR="${gitDir}"
    VAULT_PATH="${vaultPath}"

    mkdir -p "$(dirname "$GIT_DIR")"
    mkdir -p "$VAULT_PATH"

    if [ ! -d "$GIT_DIR" ]; then
      run ${pkgs.git}/bin/git clone --separate-git-dir="$GIT_DIR" \
        git@github.com:tomrfitz/Obsidian.git "$VAULT_PATH"
    fi

    # Ensure .git file in vault points to the separate git dir
    if [ ! -e "$VAULT_PATH/.git" ] || [ "$(cat "$VAULT_PATH/.git" 2>/dev/null)" != "gitdir: $GIT_DIR" ]; then
      echo "gitdir: $GIT_DIR" > "$VAULT_PATH/.git"
    fi

    # Ensure worktree is configured
    run ${pkgs.git}/bin/git --git-dir="$GIT_DIR" config core.worktree "$VAULT_PATH"
  '';
}
