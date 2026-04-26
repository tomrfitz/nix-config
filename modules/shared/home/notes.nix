{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (pkgs.stdenv) isDarwin;
  notesPath = "${config.home.homeDirectory}/Documents/notes";
  # On macOS, keep git objects outside iCloud (same pattern as obsidian.nix)
  gitDir = if isDarwin then "${config.xdg.dataHome}/notes-git" else null;
in
{
  home.sessionVariables = {
    NOTES = "${notesPath}/";
  };

  home.activation.notes-repo = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    NOTES="${notesPath}"

    if [ ! -d "$NOTES" ]; then
      mkdir -p "$NOTES"
      ${pkgs.git}/bin/git init \
        ${if gitDir != null then "--separate-git-dir=\"${gitDir}\"" else ""} \
        "$NOTES"
      verboseEcho "notes-repo: initialized new repo at $NOTES"
    fi
  '';
}
