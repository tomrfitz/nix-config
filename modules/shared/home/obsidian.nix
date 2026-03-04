{
  pkgs,
  lib,
  config,
  ...
}:
let
  isDarwin = pkgs.stdenv.isDarwin;
  vaultRepo = "git@github.com:tomrfitz/Obsidian.git";
  vaultPath =
    if isDarwin then
      "${config.home.homeDirectory}/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian"
    else
      "${config.home.homeDirectory}/notes/vault";
  # Git object database lives outside cloud storage (XDG_DATA_HOME)
  gitDir = if isDarwin then "${config.xdg.dataHome}/obsidian-git" else null; # linux uses normal in-tree .git
in
{
  home.sessionVariables = {
    OBSD = "${vaultPath}/";
  };

  # On macOS the CLI lives inside the .app bundle; on Linux nixpkgs already puts it on PATH.
  home.sessionPath = lib.mkIf isDarwin [
    "${config.home.homeDirectory}/Applications/Home Manager Apps/Obsidian.app/Contents/MacOS"
  ];

  home.activation.obsidian-vault = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    VAULT="${vaultPath}"

    if [ ! -d "$VAULT" ]; then
      export GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh"
      if ! ${pkgs.git}/bin/git clone \
        ${lib.optionalString (gitDir != null) "--separate-git-dir=\"${gitDir}\""} \
        "${vaultRepo}" "$VAULT" 2>&1; then
        verboseEcho "obsidian-vault: clone failed (no network/key?), skipping"
      fi
    elif [ ${lib.boolToString (gitDir != null)} = "true" ]; then
      # Vault exists — verify git dir linkage
      if [ ! -d "${gitDir}" ]; then
        verboseEcho "obsidian-vault: warning: vault exists but git dir missing at ${gitDir}"
      elif [ ! -e "$VAULT/.git" ]; then
        verboseEcho "obsidian-vault: warning: vault exists but .git pointer missing"
      fi
    fi
  '';
}
