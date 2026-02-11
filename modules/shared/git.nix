{
  config,
  pkgs,
  lib,
  ...
}:
{
  # ── Git ────────────────────────────────────────────────────────────────
  programs.git = {
    enable = true;

    lfs.enable = true;

    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJAf+U5Lj9RGzpxZJWVBTFpEAIqY2oTQor3URBBzWY2v";
      signByDefault = true;
      format = "ssh";
    };

    ignores = [
      ".DS_Store"
      ".vscode"
    ];

    settings = {
      user = {
        name = "Thomas FitzGerald";
        email = "tomrfitz@gmail.com";
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
        name = "Thomas FitzGerald";
        email = "tomrfitz@gmail.com";
      };
    };
  };
}
