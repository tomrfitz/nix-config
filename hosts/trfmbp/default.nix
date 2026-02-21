{
  hostName,
  ...
}:
{
  imports = [
    ../../modules/shared/system/nix.nix
    ../../modules/shared/system/stylix.nix
    ../../modules/darwin/system
  ];

  system.stateVersion = 5;

  networking.hostName = hostName;
  networking.localHostName = hostName;
  networking.computerName = hostName;
}
