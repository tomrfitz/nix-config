{
  pkgs,
  lib,
  config,
  hostName,
  ...
}:
let
  inherit (pkgs.stdenv) isDarwin;
  notesPath = "${config.home.homeDirectory}/Documents/notes";
  notesRepo = "git@github.com:tomrfitz/notes.git"; # private
  # On macOS, keep git objects outside iCloud (same pattern as obsidian.nix)
  gitDir = if isDarwin then "${config.xdg.dataHome}/notes-git" else null;

  # Auto-commit, as obsidian-git did for the vault: commit whatever changed,
  # then push. It never fetches (the Mac is the only writer) and pushes only
  # after a fresh commit, so 1Password's Touch ID prompt for the SSH key comes
  # only within one interval of editing; commits a declined push left behind
  # go out with the next one. Unsigned, or each commit would prompt too.
  # Not services.git-sync: it fetches on every run, so it would prompt every
  # interval even when nothing changed.
  notes-sync = pkgs.writeShellApplication {
    name = "notes-sync";
    runtimeInputs = [
      pkgs.git
      pkgs.openssh
    ];
    text = ''
      cd "${notesPath}"
      [ -n "$(git status --porcelain)" ] || exit 0
      git add --all
      git -c commit.gpgsign=false commit --quiet \
        --message "Auto-commit from ${hostName} at $(date '+%Y-%m-%dT%H:%M')"
      git push --quiet origin HEAD
    '';
  };
in
{
  home.sessionVariables = {
    NOTES = "${notesPath}/";
  };

  home.packages = lib.optionals isDarwin [ notes-sync ];

  home.activation.notes-repo = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    NOTES="${notesPath}"

    if [ ! -d "$NOTES" ]; then
      mkdir -p "$NOTES"
      ${pkgs.git}/bin/git init \
        ${if gitDir != null then "--separate-git-dir=\"${gitDir}\"" else ""} \
        "$NOTES"
      verboseEcho "notes-repo: initialized new repo at $NOTES"
    fi
    if ! ${pkgs.git}/bin/git -C "$NOTES" remote get-url origin >/dev/null 2>&1; then
      ${pkgs.git}/bin/git -C "$NOTES" remote add origin "${notesRepo}"
    fi
  '';

  # Every 10 min while logged in. Run `notes-sync` to sync now.
  launchd.agents.notes-sync = lib.mkIf isDarwin {
    enable = true;
    config = {
      ProgramArguments = [ "${notes-sync}/bin/notes-sync" ];
      StartInterval = 600;
      ProcessType = "Background";
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/notes-sync.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/notes-sync.log";
    };
  };
}
