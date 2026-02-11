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

  # TODO: Add hardware-configuration.nix, boot loader, networking,
  #       and server services (Plex, *arr, Immich, file storage, etc.)

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
  };
}
