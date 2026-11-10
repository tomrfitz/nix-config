{
  hostName,
  ...
}:
{
  system.stateVersion = 5;

  networking.hostName = hostName;
  networking.localHostName = hostName;
  networking.computerName = hostName;
}
