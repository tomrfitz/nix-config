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
    defaults2nix = {
      url = "github:joshryandavis/defaults2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
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
      defaults2nix,
      treefmt-nix,
      stylix,
    }:
    let
      user = "tomrfitz";
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
      treefmtEval = forAllSystems (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);

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
        specialArgs = { inherit agenix user; };
        modules = [
          { nixpkgs.hostPlatform = "aarch64-darwin"; }
          ./hosts/trfmbp
          home-manager.darwinModules.home-manager
          (mkHM [
            ./modules/shared/home
            ./modules/darwin/home
          ])
          stylix.darwinModules.stylix
        ];
      };

      nixosConfigurations.trfnix = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit user; };
        modules = [
          { nixpkgs.hostPlatform = "x86_64-linux"; }
          ./hosts/trfnix
          home-manager.nixosModules.home-manager
          (mkHM [
            ./modules/shared/home
            ./modules/nixos/home
          ])
          stylix.nixosModules.stylix
        ];
      };

      nixosConfigurations.trfhomelab = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit user; };
        modules = [
          { nixpkgs.hostPlatform = "x86_64-linux"; }
          ./hosts/trfhomelab
          home-manager.nixosModules.home-manager
          (mkHM [
            ./modules/shared/home
            ./modules/nixos/home
          ])
          stylix.nixosModules.stylix
        ];
      };

      # ── Formatter (nix fmt — runs all formatters via treefmt) ─────────
      formatter = forAllSystems (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);

      # ── Checks (CI formatting validation) ───────────────────────────
      checks = forAllSystems (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      });

      # ── Dev shell (tools for working on this config) ────────────────
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.nixfmt
            pkgs.nixd
            pkgs.nvd
            pkgs.just
          ]
          ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
            defaults2nix.packages.${pkgs.system}.default
          ];
          shellHook = ''
            git config core.hooksPath .githooks
          '';
        };
      });
    };
}
