{
  pkgs,
  user,
  sshPublicKey,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/shared/system/nix.nix
    ../../modules/shared/system/stylix.nix
    ../../modules/nixos/system
  ];

  system.stateVersion = "24.11";

  # ── Boot ──────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ── Networking ────────────────────────────────────────────────────────
  networking.hostName = "trfnix";
  networking.networkmanager.enable = true;

  # ── User ──────────────────────────────────────────────────────────────
  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      sshPublicKey
    ];
  };
}
