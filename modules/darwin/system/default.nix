{ ... }:
{
  imports = [
    ./homebrew.nix
    ./settings.nix
    ./security.nix
    ./mas.nix
    ./paneru.nix
    ./auto-rebuild.nix
  ];
}
