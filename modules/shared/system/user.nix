{
  pkgs,
  lib,
  user,
  sshPublicKey,
  isDarwin,
  ...
}:
{
  # nix-darwin sets a user's shell only for users.knownUsers, which would hand
  # it the whole account, so on darwin the login shell stays Apple's /bin/zsh.
  users.users.${user} =
    lib.optionalAttrs isDarwin {
      name = user;
      home = "/Users/${user}";
    }
    // lib.optionalAttrs (!isDarwin) {
      shell = pkgs.zsh;
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
