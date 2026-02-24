{
  hostName,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  system.stateVersion = "26.05";

  # ── Boot ──────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ── Networking ────────────────────────────────────────────────────────
  networking.hostName = hostName;
  networking.networkmanager.enable = true;
}
