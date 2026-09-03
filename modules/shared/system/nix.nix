{
  pkgs,
  user,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;
  # REVISIT(upstream): drop the doInstallCheck override on macOS once lix#1101
  # (fork safety on macOS Sequoia/Tahoe) lands — retargeted to milestone 2.97.
  # ref: https://git.lix.systems/lix-project/lix/issues/1101; checked: 2026-08-26
  nix.package = pkgs.lixPackageSets.stable.lix.overrideAttrs {
    doInstallCheck = pkgs.stdenv.hostPlatform.isLinux;
  };
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
    connect-timeout = 5;
    log-lines = 25;
    trusted-users = [
      "root"
      user
    ];
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
