{ ... }:
{
  # paneru.nix, batt.nix and headless.nix are not here: flake.nix lists them
  # per host (paneru with the input's module it needs).
  imports = [
    ./homebrew.nix
    ./settings.nix
    ./security.nix
    ./mas.nix
    ./auto-rebuild.nix
  ];
}
