{
  pkgs,
  user,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;
  # REVISIT(upstream): remove doInstallCheck override; ref: https://git.lix.systems/lix-project/lix/issues/1113; checked: 2026-03-14
  nix.package = pkgs.lixPackageSets.stable.lix.overrideAttrs { doInstallCheck = false; };
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    accept-flake-config = true;
    # Trigger GC mid-build if free space drops below 25 GB, stop at 50 GB
    min-free = 26843545600;
    max-free = 53687091200;
    fallback = true;
    connect-timeout = 5;
    log-lines = 25;
    trusted-users = [
      "root"
      user
    ];
    extra-substituters = [
      "https://cache.lix.systems"
      "https://nix-community.cachix.org"
      "https://niri.cachix.org"
      "https://tomrfitz.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "tomrfitz.cachix.org-1:LwNFrIvyn1kTHi9VH6w9gVz5VE5qhZpqIe7JMYAlDZI="
    ];
  };
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };
  nix.optimise.automatic = true;
}
