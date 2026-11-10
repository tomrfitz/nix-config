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
  users.users.${user} = {
    # System-level on both platforms. A home-manager link at
    # ~/.ssh/authorized_keys resolves into /nix/store, which is group-writable,
    # so sshd's StrictModes refuses the file and falls back to a password.
    openssh.authorizedKeys.keys = [ sshPublicKey ];
  }
  // lib.optionalAttrs isDarwin {
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
  };

}
// lib.optionalAttrs isDarwin {
  # nix-darwin requires declaring who can administer the system
  system.primaryUser = user;
}
