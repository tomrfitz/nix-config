{ ... }:
{
  programs.topgrade.settings = {
    pre_commands = {
      "Nix Flake Update + Darwin Rebuild" = "just -f ~/nix-config/justfile update";
    };
    brew = {
      greedy_latest = true;
      greedy_auto_updates = true;
      autoremove = true;
      fetch_head = true;
    };
  };
}
