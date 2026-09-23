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
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "git-hooks/flake-compat";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
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
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs"; # only upstream's hydraJobs use it
    };
    # Mattpocock's curated skill collection — consumed by pi via
    # modules/shared/home/pi.nix, which links only the skills its plugin
    # manifest promotes. Locked via flake.lock; the lock bump moves it.
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
      treefmt-nix,
      nixos-wsl,
      zen-browser,
      sops-nix,
      paneru,
      git-hooks,
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
            # Apps that rewrite a managed file (Zen's containers.json and
            # search.json) leave a fresh backup on every switch; replacing the
            # old one beats failing the switch, unattended ones included.
            overwriteBackup = true;
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
          extraModules = [ ./modules/nixos/system/desktop.nix ];
          hmModules = [
            ./modules/shared/home
            ./modules/shared/home/desktop.nix
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
            packages = preCommit.enabledPackages ++ [
              pkgs.nixfmt
              pkgs.nixd
              pkgs.dix
              pkgs.nh
              pkgs.just
              pkgs.sops
            ];
          };
        }
      );

      # ── Templates (`nixify [name]` = nix flake init -t ~/nix-config#<name> + the git/direnv tail) ──
      # Each template layers the strict lint tier over the global floor: ruff via
      # `extend`, clang-tidy via `InheritParentConfig`, clangd by project-over-user merge.
      templates = {
        default = {
          path = ./templates/default;
          description = "Bare devShell flake: add packages";
        };
        python-uv = {
          path = ./templates/python-uv;
          description = "Python devShell: uv-managed interpreter + venv, ruff and ty on PATH for eglot (rass); strict ruff tier over the global floor";
          welcomeText = ''
            # python-uv

            `nixify` follows this with `git init`, intent-to-add of these files,
            and `direnv allow`. Then, from the project directory:

            1. Set `name` in `pyproject.toml`; bump `.python-version` if the
               course target moves.
            2. Starter code with a `requirements.txt`: `uv add -r requirements.txt`.
            3. The shellHook runs `uv sync` (downloads the pinned CPython once)
               and activates `.venv`.

            `[tool.ruff]` extends `~/.config/ruff/ruff.toml` (the floor) with the
            project tier; keep `extend` as its first line.
          '';
        };
        cpp = {
          path = ./templates/cpp;
          description = "C++ devShell: clang-tools on PATH; strict clang-tidy/clangd tier over the global floor";
          welcomeText = ''
            # cpp

            `.clang-tidy` inherits `~/.clang-tidy` and `.clangd` merges over the
            user clangd config; both add the strict tier. Add the compiler and
            build system to `flake.nix`: the devShell ships only clang-tools.
          '';
        };
      };
    };
}
