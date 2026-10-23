{
  pkgs,
  user,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;
  # Unmodified, so it comes from cache.nixos.org: any override (as the old
  # darwin doInstallCheck one) makes every Lix bump a local build.
  nix.package = pkgs.lixPackageSets.stable.lix;
  # The tools that wrap a nix of their own, built against Lix instead of
  # CppNix (https://lix.systems/add-to-config/). Spelled as the overrides
  # lixPackageSets itself applies: inheriting its attributes recurses, since
  # the set builds them from the final package set. Same derivations, so all
  # cached. comma stays on CppNix: its Lix build isn't cached.
  nixpkgs.overlays = [
    (final: prev: {
      nix-direnv = prev.nix-direnv.override { nix = final.lixPackageSets.stable.lix; };
      nurl = prev.nurl.override { nix = final.lixPackageSets.stable.lix; };
      nix-init = prev.nix-init.override {
        nix = final.lixPackageSets.stable.lix;
        inherit (final) nurl;
      };
    })
  ];
  # Flakes only: no channels, so no dead channels entry on the Nix search path
  # (impure evaluations warned that root's channels profile does not exist).
  nix.channel.enable = false;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    # Keep ~/.nix-defexpr, ~/.nix-profile, ~/.nix-channels out of $HOME;
    # relocate to ~/.local/state/nix per XDG Base Directory spec.
    use-xdg-base-directories = true;
    # Trigger GC mid-build if free space drops below 25 GB, stop at 50 GB
    min-free = 26843545600;
    max-free = 53687091200;
    fallback = true;
    # A full `nix flake update` can time out on GitHub tarballs at this
    # setting; that run can take --option connect-timeout 60 --option
    # download-attempts 10.
    connect-timeout = 5;
    log-lines = 25;
    trusted-users = [
      "root"
      user
    ];
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://tomrfitz.cachix.org"
    ];
    extra-trusted-public-keys = [
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
