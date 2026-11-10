{
  hostName,
  user,
  ...
}:
{
  system.stateVersion = 7;
  home-manager.users.${user}.home.stateVersion = "26.11";

  networking.hostName = hostName;
  networking.localHostName = hostName;
  networking.computerName = hostName;
}
