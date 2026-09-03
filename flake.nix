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
      inputs.flake-compat.follows = "git-hooks/flake-compat";
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
      url = "github:noctalia-dev/noctalia";
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
      inputs.nix-darwin.follows = "nix-darwin";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Mattpocock's curated skill collection — consumed by pi via
    # modules/shared/home/pi.nix; pi's recursive SKILL.md discovery walks
    # the symlinked tree. Locked via flake.lock; `nix flake update' bumps.
    mattpocock-skills = {
      url = "github:mattpocock/skills";
      flake = false;
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
      sops-nix,
      disko,
      nix-topology,
      paneru,
      git-hooks,
      llm-agents,
      nix-index-database,
      emacs-overlay,
      mattpocock-skills,
    }:
    let
      inherit (nixpkgs) lib;
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
              nix-index-database.homeModules.nix-index
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
              mattpocock-skills
              ;
            hostName = name;
            inherit isWSL;
            inherit isDarwin;
          };
          sharedSystemModules = [
            ./modules/shared/system/nix.nix
            ./modules/shared/system/user.nix
          ];
        in
        systemBuilder {
          specialArgs = commonSpecialArgs;
          modules = [
            {
              nixpkgs.hostPlatform = system;
              nixpkgs.overlays = [
                llm-agents.overlays.shared-nixpkgs
                emacs-overlay.overlays.default
              ]
              ++ overlays;
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
          extraModules = [ paneru.darwinModules.paneru ];
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
              inherit (self) nixosConfigurations;
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

      # ── Templates (nix flake init -t github:tomrfitz/nix-config#python-uv) ──
      templates.python-uv = {
        path = ./templates/python-uv;
        description = "Python devShell: uv-managed interpreter + venv, ruff and ty on PATH for eglot (rass)";
        welcomeText = ''
          # python-uv

          Next steps (from the project directory):

          1. `git init` — flakes only see tracked files, and git filtering keeps
             `.venv/` out of the Nix store copy.
          2. Set `name` in `pyproject.toml`; bump `.python-version` if the course
             target moves.
          3. Starter code with a `requirements.txt`: `uv add -r requirements.txt`.
          4. `direnv allow` — the shellHook runs `uv sync` (downloads the pinned
             CPython once) and activates `.venv`.

          Ruff uses `~/.config/ruff/ruff.toml` automatically; add a `[tool.ruff]`
          table only with `extend = "~/.config/ruff/ruff.toml"` as its first line.
        '';
      };
    };
}
