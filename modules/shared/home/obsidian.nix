{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  vaultRepo = "git@github.com:tomrfitz/Obsidian.git";
  vaultPath =
    if isDarwin then
      "${config.home.homeDirectory}/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian"
    else
      "${config.home.homeDirectory}/notes/vault";
  # Git object database lives outside cloud storage (XDG_DATA_HOME)
  gitDir = if isDarwin then "${config.xdg.dataHome}/obsidian-git" else null; # linux uses normal in-tree .git

  # Rebuilds a lost git dir from the remote without touching the worktree:
  # a bare clone made non-bare, then a mixed reset to rebuild the index, so
  # local edits since the last push show up as changes. Submodule git dirs
  # live inside it (modules/<name>) and are rebuilt the same way, detached at
  # the recorded commit. Each clone lands beside its target and moves into
  # place only once complete, so a failed run is retried on the next switch.
  restore-gitdir = pkgs.writeShellApplication {
    name = "obsidian-restore-gitdir";
    runtimeInputs = [
      pkgs.git
      pkgs.openssh
      pkgs.coreutils
    ];
    text = ''
      vault=$1 gitdir=$2 url=$3

      clone() { # target url
        rm -rf "$1.partial"
        git clone --quiet --bare "$2" "$1.partial"
        git --git-dir="$1.partial" config core.bare false
        git --git-dir="$1.partial" config core.logallrefupdates true
        git --git-dir="$1.partial" config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
        git --git-dir="$1.partial" fetch --quiet origin
        mkdir -p "$(dirname "$1")"
        mv "$1.partial" "$1"
      }

      if [ ! -d "$gitdir" ]; then
        clone "$gitdir" "$url"
        branch=$(git --git-dir="$gitdir" symbolic-ref --short HEAD)
        git --git-dir="$gitdir" config "branch.$branch.remote" origin
        git --git-dir="$gitdir" config "branch.$branch.merge" "refs/heads/$branch"
        git -C "$vault" reset --quiet
      fi

      [ -f "$vault/.gitmodules" ] || exit 0
      git -C "$vault" config --file .gitmodules --get-regexp '^submodule\..*\.path$' |
        while read -r key path; do
          name=''${key#submodule.}
          name=''${name%.path}
          sub="$gitdir/modules/$name"
          [ -d "$sub" ] && continue
          clone "$sub" "$(git -C "$vault" config --file .gitmodules "submodule.$name.url")"
          git --git-dir="$sub" config core.worktree "$vault/$path"
          git -C "$vault/$path" update-ref --no-deref HEAD "$(git -C "$vault" rev-parse "HEAD:$path")"
          git -C "$vault/$path" reset --quiet
        done
      git -C "$vault" submodule init --quiet
    '';
  };
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
        ${if gitDir != null then "--separate-git-dir=\"${gitDir}\"" else ""} \
        "${vaultRepo}" "$VAULT" 2>&1; then
        verboseEcho "obsidian-vault: clone failed (no network/key?), skipping"
      fi
    ${
      if gitDir != null then
        ''
          elif [ ! -e "$VAULT/.git" ]; then
            warnEcho "obsidian-vault: vault exists but its .git pointer is missing"
          else
            run ${lib.getExe restore-gitdir} "$VAULT" "${gitDir}" "${vaultRepo}" \
              || warnEcho "obsidian-vault: restoring the git dir from ${vaultRepo} failed (no network/key?); retrying next switch"
        ''
      else
        ""
    }
    fi
  '';
}
