{
  isDarwin,
  lib,
  user,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;
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
    # Trust is as good as root on the daemon (nix.conf(5)), and nothing the
    # Macs run needs it (audited 2026-11-10). Without it the daemon ignores,
    # with a warning, most `--option` flags a user passes, `--builders` and
    # any substituter not listed here; `connect-timeout` still applies.
    trusted-users = lib.optionals (!isDarwin) [ user ];
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
