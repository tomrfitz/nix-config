{
  hostName,
  ...
}:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
  ];

  # Keep generated hardware defaults as a fallback, but prefer facter data
  # when hosts/trfnix/facter.json exists.
  hardware.facter.reportPath = if builtins.pathExists ./facter.json then ./facter.json else null;

  system.stateVersion = "26.05";

  # ── Boot ──────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false; # no boot entry editing (security)
  boot.loader.systemd-boot.configurationLimit = 10;
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
