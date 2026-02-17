# AGENTS.md

Repo-specific guidance for AI agents working on this nix-config. See also `~/.config/AGENTS.md` for global, project-agnostic conventions.

## What This Is

A Nix flake managing macOS (nix-darwin) and NixOS systems with home-manager. Tracks on nixpkgs-unstable. The primary active machine is `trfmbp` (aarch64-darwin M1 Pro MacBook Pro). Two NixOS hosts (`trfnix`, `trfhomelab`) exist as stubs — do not invest effort in their configs.

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
just rekey         # re-encrypt secrets for all recipients
```

**Validation:** There are no tests. Correctness = `just check` (dry-run) or `just eval` succeeding. Do not run `just rebuild` unless explicitly asked — it mutates the live system.

**Important:** Nix flakes only see files tracked by git. When adding new files referenced by the flake (e.g., config files used in `home.file` or `source`), you must `git add` them before `just eval` or `just check` will work.

## Architecture

### Flake structure

`flake.nix` defines three machines and a `mkHM` helper that wires home-manager with agenix for each host. Inputs: nixpkgs (unstable), nix-darwin, home-manager, agenix, defaults2nix.

### Hosts are thin wiring

`hosts/<machine>/default.nix` files only set hostname, user, and import system modules. All real configuration lives in `modules/`.

### Module organization

```text
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

| Task                                     | File                                 |
| ---------------------------------------- | ------------------------------------ |
| Add/remove nix packages                  | `modules/shared/home/packages.nix`   |
| Add/remove macOS casks                   | `modules/darwin/system/homebrew.nix` |
| Change macOS system settings             | `modules/darwin/system/settings.nix` |
| Shell aliases/functions (cross-platform) | `modules/shared/home/shell.nix`      |
| Shell aliases/functions (macOS-only)     | `modules/darwin/home/zsh.nix`        |
| Configure editors                        | `modules/shared/home/editors.nix`    |
| Firefox extensions                       | `modules/shared/home/firefox.nix`    |
| Git settings (shared)                    | `modules/shared/home/git.nix`        |
| Git settings (1Password signing)         | `modules/darwin/home/git.nix`        |

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

Agenix manages encrypted secrets in `secrets/`. Public keys mapped in `secrets/secrets.nix`. Each machine has a dedicated passphrase-less ed25519 key at `~/.ssh/id_ed25519_agenix` for decryption — generated automatically by the bootstrap script.

### Config files

`config/` holds imported TOML/YAML configs (Starship prompt, Helix themes). Referenced via `lib.importTOML` in modules. `config/agents.md` is the global agent instructions file deployed to home directories.

## Theming

- **Palette:** Flexoki (dark + light variants) across Ghostty, Zed, Helix, Vesktop
- **Fonts:** Atkinson Hyperlegible (sans + mono)
- **Stylix:** added to flake, single polarity (dark) for now; auto-switching via launchd + specialisations planned separately
- **Exclude from Stylix:** Ghostty and Zed have native system-responsive theming

## Custom packages

- **`pkgs/mdbase-tasknotes/`** — npm CLI packaged via `buildNpmPackage` + `fetchurl` from npm registry
  - Requires a locally-generated `package-lock.json` stored in repo (npm tarballs lack lockfiles)
  - Version bump workflow: update `version`, `hash` (via `nix-prefetch-url`), and `npmDepsHash` (let builder error tell you the correct hash)
  - Monitor for GitHub releases with prebuilt binaries — could simplify packaging

## Bootstrap

Fresh machine setup (darwin or NixOS):

```bash
bash <(curl -L https://raw.githubusercontent.com/tomrfitz/nix-config/main/scripts/bootstrap.sh)
```

The script handles: Xcode CLT (darwin), Nix installation, repo clone, agenix key generation, and first `darwin-rebuild`/`nixos-rebuild`. The only manual post-bootstrap steps are signing into 1Password and (on darwin) Apple ID.

### Adding a new machine to agenix

After bootstrapping, the new machine's agenix key can't decrypt existing secrets yet. From an existing machine:

1. Copy the pubkey printed by the bootstrap script
2. Add it to `secrets/secrets.nix` in the `allKeys` list
3. Run `just rekey` (re-encrypts all secrets for the new recipient set)
4. Commit and push
5. Pull on the new machine and rebuild

## Active overlays

- **`overlays/vesktop-darwin.nix`** — fixes codesign failure on macOS; remove when NixOS/nixpkgs#489725 merges
