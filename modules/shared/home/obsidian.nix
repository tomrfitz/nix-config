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
      export GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh"
      if ! ${pkgs.git}/bin/git clone --separate-git-dir="$GIT_DIR" \
        git@github.com:tomrfitz/Obsidian.git "$VAULT_PATH" 2>&1; then
        verboseEcho "obsidian-vault: clone failed (no network/key?), skipping"
      fi
    fi

    if [ -d "$GIT_DIR" ]; then
      # Ensure .git file in vault points to the separate git dir
      if [ ! -e "$VAULT_PATH/.git" ] || [ "$(cat "$VAULT_PATH/.git" 2>/dev/null)" != "gitdir: $GIT_DIR" ]; then
        echo "gitdir: $GIT_DIR" > "$VAULT_PATH/.git"
      fi

      # Ensure worktree is configured
      ${pkgs.git}/bin/git --git-dir="$GIT_DIR" config core.worktree "$VAULT_PATH"

      # Symlink shared markdownlint config into vault root
      MDLINT_SRC="${config.home.homeDirectory}/.markdownlint-cli2.jsonc"
      MDLINT_DST="$VAULT_PATH/.markdownlint-cli2.jsonc"
      if [ -f "$MDLINT_SRC" ]; then
        ln -sf "$MDLINT_SRC" "$MDLINT_DST"
      fi
    fi
  '';
}
