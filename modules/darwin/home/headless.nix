# The home side of system/headless.nix: this Mac has its own key for GitHub
# and commit signing, since 1Password's agent refuses to sign behind a locked
# screen; see AGENTS.md § Headless Macs
{
  config,
  hostName,
  lib,
  ...
}:
let
  key = "${config.home.homeDirectory}/.ssh/id_ed25519_${hostName}";
in
{
  # Made here so the private half never leaves this Mac, and without a
  # passphrase: nobody is there to type one. It opens nothing until its
  # public half is registered at GitHub.
  home.activation.headlessKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e ${key} ]; then
      run /usr/bin/ssh-keygen -q -t ed25519 -N "" -C ${hostName} -f ${key}
    fi
  '';

  # Only GitHub: every other host still goes through `Host *` and 1Password.
  programs.ssh.settings."github.com" = {
    IdentityFile = key;
    IdentityAgent = "none";
    IdentitiesOnly = true;
  };

  programs.git = {
    signing.key = lib.mkForce key;
    settings.gpg.ssh.program = lib.mkForce "/usr/bin/ssh-keygen";
  };

  # iCloud delivers ~/Documents/notes; the repo and its auto-commit belong to
  # the Mac someone sits at (notes.nix). Unattended, the repo check waits on
  # macOS's Documents-folder prompt and hangs the 06:30 switch.
  home.activation.notes-repo = lib.mkForce (lib.hm.dag.entryAnywhere "");
  launchd.agents.notes-sync.enable = lib.mkForce false;

  # No GUI editor here: a terminal frame on the Emacs daemon.
  home.sessionVariables.EDITOR = lib.mkForce "emacsclient -t";

  # Auto-login leaves the desktop open until the display sleeps. Sleeping it
  # at login locks at once: the lock delay is "immediately", set by hand.
  launchd.agents.lock-at-login = {
    enable = true;
    config = {
      ProgramArguments = [
        "/usr/bin/pmset"
        "displaysleepnow"
      ];
      RunAtLoad = true;
    };
  };
}
