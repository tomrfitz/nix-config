{ ... }:
{
  programs.topgrade.settings = {
    pre_commands = {
      "SSH ControlMaster warmup" = "ssh -T git@github.com || true";
      "Nix Flake Update + Darwin Rebuild" =
        "just -f ~/nix-config/justfile _snapshot-gen && just -f ~/nix-config/justfile update";
    };
    post_commands = {
      "Nix package diff" = "just -f ~/nix-config/justfile nvd";
    };
    brew = {
      greedy_latest = true;
      greedy_auto_updates = true;
      autoremove = true;
      fetch_head = true;
    };
  };
}
