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

      mkHM = hmModules: {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "hm-backup";
          users.${user}.imports = [ agenix.homeManagerModules.default ] ++ hmModules;
        };
      };
    in
    {
      darwinConfigurations.trfmbp = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit agenix user; };
        modules = [
          ./hosts/trfmbp
          home-manager.darwinModules.home-manager
          (mkHM [
            ./modules/shared/home
            ./modules/darwin/home
          ])
        ];
      };

      nixosConfigurations.trfnix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit user; };
        modules = [
          ./hosts/trfnix
          home-manager.nixosModules.home-manager
          (mkHM [
            ./modules/shared/home
            ./modules/nixos/home
          ])
        ];
      };

      nixosConfigurations.trfhomelab = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit user; };
        modules = [
          ./hosts/trfhomelab
          home-manager.nixosModules.home-manager
          (mkHM [
            ./modules/shared/home
            ./modules/nixos/home
          ])
        ];
      };
    };
}
