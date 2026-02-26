{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  nix.package = pkgs.lixPackageSets.stable.lix;
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    accept-flake-config = true;
    extra-substituters = [
      "https://cache.lix.systems"
      "https://nix-community.cachix.org"
      "https://tomrfitz.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "tomrfitz.cachix.org-1:LwNFrIvyn1kTHi9VH6w9gVz5VE5qhZpqIe7JMYAlDZI="
    ];
  };
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };
  nix.optimise.automatic = true;
}
