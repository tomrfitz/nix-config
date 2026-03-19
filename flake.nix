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
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.noctalia-qs.follows = "noctalia-qs";
    };
    noctalia-qs = {
      url = "github:noctalia-dev/noctalia-qs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-topology = {
      url = "github:oddlama/nix-topology";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    paneru = {
      url = "github:karinushka/paneru";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
      nixos-wsl,
      niri-flake,
      zen-browser,
      noctalia,
      noctalia-qs,
      sops-nix,
      disko,
      nix-topology,
      paneru,
      git-hooks,
      llm-agents,
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
            ./modules/shared/system/user.nix
          ];
        in
        systemBuilder {
          inherit system;
          specialArgs = commonSpecialArgs;
          modules = [
            {
              nixpkgs.overlays = [ llm-agents.overlays.default ] ++ overlays;
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
          ]
          ++ lib.optionals (!isDarwin) [
            sops-nix.nixosModules.sops
            nix-topology.nixosModules.default
          ]
          ++ extraModules;
        };

      hosts = {
        trfmbp = {
          system = "aarch64-darwin";
          platform = "darwin";
          hostModule = ./hosts/trfmbp;
          overlays = [
            # REVISIT(upstream): remove overlay once a214160f is in nixpkgs-unstable
            # check: gh api repos/NixOS/nixpkgs/compare/a214160f...nixpkgs-unstable --jq '.status' → "ahead" or "identical" means it's in
            # ref: https://github.com/NixOS/nixpkgs/commit/a214160f092d5a3eacd6831237db8fad6f578d4a; checked: 2026-03-17
            (_: prev: {
              anki = prev.anki.overrideAttrs (old: {
                env = old.env // {
                  UV_FIND_LINKS =
                    let
                      ankiAudio = prev.fetchurl {
                        url = "https://files.pythonhosted.org/packages/66/c7/b4c86d89c51d5bdcfc21bffc58be96b84075cff24b6d6fa0276a699084ff/anki_audio-0.1.0-cp39-abi3-macosx_11_0_arm64.whl";
                        hash = "sha256-JJ4/eDc2b42jQUE5KC+F32/mXe8uH3bCNg6ojgOGj2s=";
                      };
                      ankiMacHelper = prev.fetchurl {
                        url = "https://files.pythonhosted.org/packages/40/82/edb6194704defec181dddce8bc6a53c4afc72fa1f2bb4d68ffe244567767/anki_mac_helper-0.1.1-py3-none-any.whl";
                        hash = "sha256-d0ppz58P5tS1SUni1liKVKdv9R54y/wmtSfR7TxbNOM=";
                      };
                    in
                    prev.runCommand "uv-wheels-patched" { } ''
                      mkdir -p $out
                      ln -s ${old.env.UV_FIND_LINKS}/* $out/
                      ln -sf ${ankiAudio} $out/${ankiAudio.name}
                      ln -sf ${ankiMacHelper} $out/${ankiMacHelper.name}
                    '';
                };
              });
            })
          ];
          hmModules = [
            ./modules/shared/home
            ./modules/shared/home/desktop.nix
            ./modules/darwin/home
            paneru.homeModules.paneru
          ];
        };
        trfnix = {
          system = "x86_64-linux";
          platform = "nixos";
          hostModule = ./hosts/trfnix;
          extraModules = [
            ./modules/nixos/system/desktop.nix
            niri-flake.nixosModules.niri
            disko.nixosModules.disko
          ];
          hmModules = [
            ./modules/shared/home
            ./modules/shared/home/desktop.nix
            ./modules/nixos/home/desktop.nix
            noctalia.homeModules.default
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

      topology = forAllSystems (
        _system: pkgs:
        import nix-topology {
          pkgs = pkgs.extend nix-topology.overlays.default;
          modules = [
            ./topology.nix
            {
              nixosConfigurations = self.nixosConfigurations;
            }
          ];
        }
      );

      packages = forAllSystems (
        system: _pkgs: {
          topology = self.topology.${system}.config.output;
        }
      );

      # ── Formatter (nix fmt — runs all formatters via treefmt) ─────────
      formatter = forAllSystems (system: _pkgs: treefmtEval.${system}.config.build.wrapper);

      # ── Checks (CI formatting + pre-commit hooks) ──────────────────
      checks = forAllSystems (
        system: _pkgs: {
          formatting = treefmtEval.${system}.config.build.check self;
          pre-commit-check = git-hooks.lib.${system}.run {
            src = ./.;
            hooks.treefmt = {
              enable = true;
              package = treefmtEval.${system}.config.build.wrapper;
            };
          };
        }
      );

      # ── Dev shell (tools for working on this config) ────────────────
      devShells = forAllSystems (
        system: pkgs:
        let
          preCommit = self.checks.${system}.pre-commit-check;
        in
        {
          default = pkgs.mkShellNoCC {
            inherit (preCommit) shellHook;
            packages =
              preCommit.enabledPackages
              ++ [
                pkgs.nixfmt
                pkgs.nixd
                pkgs.dix
                pkgs.nh
                pkgs.just
                pkgs.sops
              ]
              ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
                defaults2nix.packages.${system}.default
              ];
          };
        }
      );
    };
}
