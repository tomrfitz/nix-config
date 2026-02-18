{ ... }:
{
  programs.topgrade.settings = {
    pre_commands = {
      "SSH ControlMaster warmup" = "ssh -T git@github.com || true";
      "Nix Flake Update + Darwin Rebuild" = "nh darwin switch --update ~/nix-config";
    };
    brew = {
      greedy_latest = true;
      greedy_auto_updates = true;
      autoremove = true;
      fetch_head = true;
    };
  };
}
