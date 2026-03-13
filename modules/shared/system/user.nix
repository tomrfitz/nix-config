{
  pkgs,
  lib,
  user,
  sshPublicKey,
  isDarwin,
  ...
}:
{
  users.users.${user} = {
    shell = pkgs.zsh;
  }
  // lib.optionalAttrs isDarwin {
    name = user;
    home = "/Users/${user}";
  }
  // lib.optionalAttrs (!isDarwin) {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = [ sshPublicKey ];
  };

}
// lib.optionalAttrs isDarwin {
  # nix-darwin requires declaring who can administer the system
  system.primaryUser = user;
}
