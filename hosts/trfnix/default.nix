{
  hostName,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  system.stateVersion = "24.11";

  # ── Boot ──────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ── Networking ────────────────────────────────────────────────────────
  networking.hostName = hostName;
  networking.networkmanager.enable = true;
}
