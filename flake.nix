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
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      defaults2nix,
      treefmt-nix,
      stylix,
      nixos-wsl,
      zen-browser,
    }:
    let
      lib = nixpkgs.lib;
      user = "tomrfitz";
      fullName = "Thomas FitzGerald";
      email = "tomrfitz@gmail.com";
      sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJAf+U5Lj9RGzpxZJWVBTFpEAIqY2oTQor3URBBzWY2v";
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system nixpkgs.legacyPackages.${system});
      treefmtEval = forAllSystems (_system: pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);

      mkHM =
        {
          hmModules,
          specialArgs,
        }:
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "hm-backup";
            extraSpecialArgs = specialArgs;
            users.${user}.imports = [
              zen-browser.homeModules.twilight
            ]
            ++ hmModules;
          };
        };

      mkHost =
        {
          name,
          system,
          hostModule,
          platform,
          overlays ? [ ],
          hmModules,
          wsl ? false,
          extraModules ? [ ],
        }:
        let
          isDarwin = platform == "darwin";
          isWSL = wsl;
          systemBuilder = if isDarwin then nix-darwin.lib.darwinSystem else lib.nixosSystem;
          platformSystemModule = if isDarwin then ./modules/darwin/system else ./modules/nixos/system;
          hmModule =
            if isDarwin then
              home-manager.darwinModules.home-manager
            else
              home-manager.nixosModules.home-manager;
          commonSpecialArgs = {
            inherit
              user
              fullName
              email
              sshPublicKey
              system
              ;
            hostName = name;
            isWSL = isWSL;
            isDarwin = isDarwin;
          };
          sharedSystemModules = [
            ./modules/shared/system/nix.nix
            ./modules/shared/system/stylix.nix
          ];
        in
        systemBuilder {
          inherit system;
          specialArgs = commonSpecialArgs;
          modules = [
            {
              nixpkgs.overlays = overlays;
            }
          ]
          ++ sharedSystemModules
          ++ [
            platformSystemModule
            hostModule
            hmModule
            (mkHM {
              inherit hmModules;
              specialArgs = commonSpecialArgs;
            })
            (if isDarwin then stylix.darwinModules.stylix else stylix.nixosModules.stylix)
          ]
          ++ extraModules;
        };

      hosts = {
        trfmbp = {
          system = "aarch64-darwin";
          platform = "darwin";
          hostModule = ./hosts/trfmbp;
          overlays = [
            (import ./overlays/vesktop-darwin.nix)
          ];
          hmModules = [
            ./modules/shared/home
            ./modules/shared/home/desktop.nix
            ./modules/darwin/home
          ];
        };
        trfnix = {
          system = "x86_64-linux";
          platform = "nixos";
          hostModule = ./hosts/trfnix;
          extraModules = [ ./modules/nixos/system/desktop.nix ];
          hmModules = [
            ./modules/shared/home
            ./modules/shared/home/desktop.nix
            ./modules/nixos/home
            ./modules/nixos/home/desktop.nix
          ];
        };
        trfwsl = {
          system = "x86_64-linux";
          platform = "nixos";
          wsl = true;
          hostModule = ./hosts/trfwsl;
          extraModules = [ nixos-wsl.nixosModules.wsl ];
          hmModules = [
            ./modules/shared/home
            ./modules/nixos/home
          ];
        };
      };

      mkConfigurations =
        targetPlatform:
        lib.mapAttrs' (name: cfg: lib.nameValuePair name (mkHost ({ inherit name; } // cfg))) (
          lib.filterAttrs (_: cfg: cfg.platform == targetPlatform) hosts
        );
    in
    {
      darwinConfigurations = mkConfigurations "darwin";

      nixosConfigurations = mkConfigurations "nixos";

      # ── Formatter (nix fmt — runs all formatters via treefmt) ─────────
      formatter = forAllSystems (system: _pkgs: treefmtEval.${system}.config.build.wrapper);

      # ── Checks (CI formatting validation) ───────────────────────────
      checks = forAllSystems (
        system: _pkgs: {
          formatting = treefmtEval.${system}.config.build.check self;
        }
      );

      # ── Dev shell (tools for working on this config) ────────────────
      devShells = forAllSystems (
        system: pkgs: {
          default = pkgs.mkShell {
            packages = [
              pkgs.nixfmt
              pkgs.nixd
              pkgs.dix
              pkgs.nh
              pkgs.just
            ]
            ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
              defaults2nix.packages.${system}.default
            ];
            shellHook = ''
              git config core.hooksPath .githooks
            '';
          };
        }
      );
    };
}
