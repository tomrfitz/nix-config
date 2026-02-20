{ ... }:
{
  programs.topgrade.settings = {
    pre_commands = {
      "Update nix-config + Flake Update + Darwin Rebuild" = ''
        # Warm up SSH so the git pull doesn't hang on first connect.
        ssh -T git@github.com || true

        repo="''${NH_FLAKE:-$HOME/nix-config}"
        if [ -d "$repo/.git" ]; then
          if git -C "$repo" diff --quiet && git -C "$repo" diff --cached --quiet; then
            git -C "$repo" pull --ff-only
          else
            echo "nix-config is dirty; skipping git pull" >&2
          fi
        fi

        nh darwin switch --update "$repo"
      '';
    };
    brew = {
      greedy_latest = true;
      greedy_auto_updates = true;
      autoremove = true;
      fetch_head = true;
    };
  };
}
