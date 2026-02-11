{
  pkgs,
  user,
  ...
}:
{
  imports = [
    ../../modules/shared/system/nix.nix
    ../../modules/nixos/system
  ];

  system.stateVersion = "24.11";

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
  };
}
