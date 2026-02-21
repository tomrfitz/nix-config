{
  pkgs,
  user,
  sshPublicKey,
  ...
}:
{
  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [ sshPublicKey ];
  };
}
