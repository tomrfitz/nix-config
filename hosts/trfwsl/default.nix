{
  hostName,
  ...
}:
{
  imports = [
    ../../modules/shared/system/nix.nix
    ../../modules/shared/system/stylix.nix
    ../../modules/nixos/system
  ];

  system.stateVersion = "24.11";
  networking.hostName = hostName;

  # TODO: Add nixos-wsl module (wsl.enable, wsl.defaultUser),
  #       Tailscale, and homelab services (Plex/Jellyfin, *arr, Immich)
  #       See TODO.md "Phase 1" for the full checklist
}
