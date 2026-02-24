{
  pkgs,
  lib,
  fullName,
  email,
  sshPublicKey,
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
