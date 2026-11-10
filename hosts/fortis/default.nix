{
  hostName,
  ...
}:
{
  system.stateVersion = 7;

  networking.hostName = hostName;
  networking.localHostName = hostName;
  networking.computerName = hostName;
}
