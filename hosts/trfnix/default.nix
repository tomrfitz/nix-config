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
  boot.loader.systemd-boot.editor = false; # no boot entry editing (security)
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 3;
  boot.kernelParams = [
    "panic=10" # reboot 10s after kernel panic
    "panic_on_oops=1"
  ];

  # ── Networking ────────────────────────────────────────────────────────
  networking.hostName = hostName;
  networking.networkmanager.enable = true;
}
