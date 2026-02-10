{
  description = "nix-darwin + home-manager config (macOS & NixOS)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      agenix,
    }:
    let
      user = "tomrfitz";
    in
    {
      darwinConfigurations.tomrfitz = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit agenix user; };
        modules = [
          ./hosts/darwin
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              users.${user} = {
                imports = [
                  agenix.homeManagerModules.default
                  ./modules/shared/home-manager.nix
                  ./modules/darwin/home-manager.nix
                ];
              };
            };
          }
        ];
      };

      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/nixos
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              users.${user} = {
                imports = [
                  agenix.homeManagerModules.default
                  ./modules/shared/home-manager.nix
                  ./modules/nixos/home-manager.nix
                ];
              };
            };
          }
        ];
      };
    };
}
