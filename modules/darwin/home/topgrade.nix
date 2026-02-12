{ ... }:
{
  programs.topgrade.settings = {
    pre_commands = {
      "Nix Flake Update + Darwin Rebuild" =
        "readlink -f /run/current-system > /tmp/.nix-pre-update-system && nix flake update --flake ~/nix-config && sudo darwin-rebuild switch";
    };
    post_commands = {
      "Nix package diff" =
        "nvd diff $(cat /tmp/.nix-pre-update-system) /run/current-system; rm -f /tmp/.nix-pre-update-system";
    };
    brew = {
      greedy_latest = true;
      greedy_auto_updates = true;
      autoremove = true;
      fetch_head = true;
    };
  };
}
