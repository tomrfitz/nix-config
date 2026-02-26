{
  pkgs,
  lib,
  fullName,
  email,
  sshPublicKey,
  isWSL,
  ...
}:
{
  # ── Git ────────────────────────────────────────────────────────────────
  programs.git = {
    enable = true;

    lfs.enable = true;

    signing = {
      key = sshPublicKey;
      signByDefault = true;
      format = "ssh";
    };

    ignores = [
      ".DS_Store"
      ".direnv"
      ".envrc"
      ".vscode"
    ];

    settings = {
      user = {
        name = fullName;
        inherit email;
      };
      init.defaultBranch = "main";
      core = {
        preloadindex = true;
        fscache = true;
      }
      // lib.optionalAttrs isWSL {
        # Route SSH through Windows OpenSSH (talks to 1Password's agent)
        sshCommand = "/mnt/c/Windows/System32/OpenSSH/ssh.exe";
      };
      # On WSL, use 1Password's WSL signing binary for commit signatures.
      gpg.ssh = lib.mkIf isWSL {
        program = "/mnt/c/Users/Thomas FitzGerald/AppData/Local/Microsoft/WindowsApps/op-ssh-sign-wsl.exe";
      };
      diff = {
        algorithm = "histogram";
        colorMoved = "default";
      };
      pull.rebase = false;
      push = {
        default = "current";
        followTags = true;
      };
      fetch = {
        prune = true;
        parallel = 0;
      };
      rerere.enabled = true;
      rebase = {
        autoStash = true;
        updateRefs = true;
      };
      merge.conflictStyle = "zdiff3";
    };
  };

  # ── Delta (git pager) ─────────────────────────────────────────────────
  programs.delta = {
    enable = true;
    options = {
      navigate = true;
      line-numbers = true;
      hyperlinks = true;
    };
  };

  # ── Jujutsu ────────────────────────────────────────────────────────────
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = fullName;
        inherit email;
      };
    };
  };
}
