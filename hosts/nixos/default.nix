{
  config,
  pkgs,
  ...
}:
{
  imports = [ ];

  # TODO: Add NixOS system configuration here
  # hardware-configuration.nix, boot loader, networking, etc.

  system.stateVersion = "24.11";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  users.users.tomrfitz = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
}
