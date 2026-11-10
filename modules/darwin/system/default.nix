{ ... }:
{
  # paneru.nix is not here: lenis lists it in flake.nix, with the input's
  # module it needs. fortis runs without a window manager for now.
  imports = [
    ./homebrew.nix
    ./settings.nix
    ./security.nix
    ./mas.nix
    ./auto-rebuild.nix
  ];
}
