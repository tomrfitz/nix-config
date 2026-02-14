# AGENTS.md

Repo-specific guidance for AI agents working on this nix-config. See also `~/.config/AGENTS.md` for global, project-agnostic conventions.

## What This Is

A Nix flake managing macOS (nix-darwin) and NixOS systems with home-manager. Tracks on nixpkgs-unstable. The primary active machine is `trfmbp` (aarch64-darwin M1 Pro MacBook Pro). Two NixOS hosts (`trfnix`, `trfhomelab`) exist as stubs.

## Commands

All common workflows are in the `justfile` (requires `just`, available via `nix develop`):

```bash
just rebuild       # sudo darwin-rebuild switch
just check         # dry-run (catches errors without applying)
just update        # flake update + rebuild + nvd diff
just fmt           # nix fmt (nixfmt)
just fmt-check     # check formatting without modifying
just eval          # nix flake check (eval errors only)
just rollback      # switch to previous generation
just diff          # nvd diff between last two generations
just snapshot NAME # take macOS defaults snapshot
```

**Validation:** There are no tests. Correctness = `just check` (dry-run) or `just eval` succeeding. Do not run `just rebuild` unless explicitly asked — it mutates the live system.

## Architecture

### Flake structure

`flake.nix` defines three machines and a `mkHM` helper that wires home-manager with agenix for each host. Inputs: nixpkgs (unstable), nix-darwin, home-manager, agenix, defaults2nix.

### Hosts are thin wiring

`hosts/<machine>/default.nix` files only set hostname, user, and import system modules. All real configuration lives in `modules/`.

### Module organization

```
modules/
  shared/          # Cross-platform (maximized — put everything here first)
    system/nix.nix # Flakes, unfree, nix-command
    home/          # Focused modules: packages, shell, git, editors, firefox, etc.
  darwin/          # macOS-only
    system/        # homebrew.nix, settings.nix (system.defaults), security.nix
    home/          # zsh.nix, git.nix (1Password signing), ssh.nix, topgrade.nix
  nixos/           # Linux-only (minimal stubs)
    system/        # Just enables zsh
    home/          # homeDirectory, 1password-gui, emacs
```

`default.nix` files are aggregators — mostly import lists.

### Common edit locations

| Task | File |
|------|------|
| Add/remove nix packages | `modules/shared/home/packages.nix` |
| Add/remove macOS casks | `modules/darwin/system/homebrew.nix` |
| Change macOS system settings | `modules/darwin/system/settings.nix` |
| Shell aliases/functions (cross-platform) | `modules/shared/home/shell.nix` |
| Shell aliases/functions (macOS-only) | `modules/darwin/home/zsh.nix` |
| Configure editors | `modules/shared/home/editors.nix` |
| Firefox extensions | `modules/shared/home/firefox.nix` |
| Git settings (shared) | `modules/shared/home/git.nix` |
| Git settings (1Password signing) | `modules/darwin/home/git.nix` |

### Key design rules

- **Maximize `modules/shared/`** — platform-specific modules only for genuine differences (e.g., 1Password SSH agent path, homebrew, macOS system.defaults)
- **Prefer native home-manager modules** (`programs.*`) over `home.file` when available
- **Package source priority:** nixpkgs shared → nixpkgs platform-specific → homebrew casks → Mac App Store (mas)
- **Brew-preferred exceptions:** 1Password, Emacs (macOS native patches), Ghostty, Zed (need keychain/native integration)

### Platform-conditional pattern

When a package needs different sources per platform, use `pkgs.stdenv.isDarwin` in a shared module rather than duplicating across platform modules:

```nix
# package = null means "installed outside nix" (e.g., via brew cask on macOS)
package = if pkgs.stdenv.isDarwin then null else pkgs.ghostty;
```

For packages that only exist on one platform, use `lib.optionals`:

```nix
home.packages = [ ... ] ++ lib.optionals (!pkgs.stdenv.isDarwin) [ pkgs.element-desktop ];
```

### Secrets

Agenix manages encrypted secrets in `secrets/`. Public keys mapped in `secrets/secrets.nix`.

### Config files

`config/` holds imported TOML/YAML configs (Starship prompt, Helix themes). Referenced via `lib.importTOML` in modules. `config/agents.md` is the global agent instructions file deployed to home directories.
