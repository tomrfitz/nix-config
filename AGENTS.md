# AGENTS.md

Repo-specific guidance for AI agents working on this nix-config. See also `~/.config/AGENTS.md` for global, project-agnostic conventions.

## What This Is

A Nix flake managing macOS (nix-darwin) and NixOS systems with home-manager. Tracks on nixpkgs-unstable.

### Machines

| Hostname | Platform | Role | Status |
| -------- | ---------------- | ---------------------------------------- | ------ |
| `trfmbp` | aarch64-darwin | Daily driver (M1 Pro MacBook Pro) | Active |
| `trfnix` | x86_64-linux | NixOS testbed (Samsung laptop) | Active |
| `trfwsl` | x86_64-linux WSL | Interim homelab on gaming PC, later dev | Stub |
| `trflab` | x86_64-linux | Dedicated homelab server | Future |
| `trfvm` | TBD | Scratch/sandbox VM | Future |

The primary config target is `trfmbp`. `trfnix` is a real NixOS install useful for prototyping NixOS service configs. `trfwsl` is the next host to build out (see Roadmap below).

## Commands

All common workflows are in the `justfile` (requires `just`, available via `nix develop`):

```bash
just rebuild       # nh darwin switch (builds + activates with diff)
just check         # nh darwin build (dry-run with diff)
just update        # nh darwin switch --update (flake update + rebuild)
just fmt           # nix fmt (nixfmt)
just fmt-check     # check formatting without modifying
just eval          # nix flake check (eval errors only)
just rollback      # switch to previous generation
just diff          # dix diff between previous and current system profile
just snapshot NAME # take macOS defaults snapshot
just rekey         # re-encrypt secrets for all recipients
```

**Validation:** There are no tests. Correctness = `just check` (dry-run) or `just eval` succeeding. Do not run `just rebuild` unless explicitly asked — it mutates the live system.

**Important:** Nix flakes only see files tracked by git. When adding new files referenced by the flake (e.g., config files used in `home.file` or `source`), you must `git add` them before `just eval` or `just check` will work.

## Architecture

### Flake structure

`flake.nix` defines one darwin host and two NixOS hosts (one bare-metal, one WSL stub) plus host builders (`mkDarwinHost`/`mkNixosHost`) and a `mkHM` helper that wires home-manager modules consistently. Core inputs: nixpkgs (unstable), nix-darwin, home-manager, agenix, stylix, treefmt-nix, defaults2nix, zen-browser.

### Hosts are thin wiring

`hosts/<machine>/default.nix` files only set hostname, user, and import system modules. All real configuration lives in `modules/`.

### Module organization

```text
modules/
  shared/          # Cross-platform (maximized — put everything here first)
    system/        # nix.nix, stylix.nix
    home/          # Focused modules: packages, shell, git, editors, browser, media, tooling
  darwin/          # macOS-only
    system/        # homebrew.nix, settings.nix (system.defaults), security.nix
    home/          # zsh.nix, git.nix (1Password signing), topgrade.nix, aerospace.nix, sketchybar.nix
  nixos/           # Linux-only
    system/        # zsh/nh, sway+greetd, tailscale, 1Password GUI, howdy, openssh
    home/          # homeDirectory, sway config, darkman, mako, gammastep
```

`default.nix` files are aggregators — mostly import lists.

### Common edit locations

- Add/remove nix packages: `modules/shared/home/packages.nix`
- Add/remove macOS casks: `modules/darwin/system/homebrew.nix`
- Change macOS system settings: `modules/darwin/system/settings.nix`
- Shell aliases/functions (cross-platform): `modules/shared/home/shell.nix`
- Shell aliases/functions (macOS-only): `modules/darwin/home/zsh.nix`
- Linux system services: `modules/nixos/system/default.nix`
- Linux desktop/session behavior: `modules/nixos/home/{default,darkman}.nix`
- Configure editors: `modules/shared/home/editors.nix`
- Firefox extensions: `modules/shared/home/firefox.nix`
- Git settings (shared): `modules/shared/home/git.nix`
- Git settings (1Password signing): `modules/darwin/home/git.nix`
- Stylix defaults / fonts: `modules/shared/system/stylix.nix`

### Key design rules

- **Maximize `modules/shared/`** — platform-specific modules only for genuine differences (e.g., 1Password SSH agent path, homebrew, macOS system.defaults)
- **Prefer native home-manager modules** (`programs.*`) over `home.file` when available
- **Package source priority:** nixpkgs shared → nixpkgs platform-specific → homebrew casks → Mac App Store (mas)
- **Brew-preferred exceptions:** 1Password, Emacs (macOS native patches), Ghostty (macOS app integration)

### Guardrails

- **Don't run `just rebuild`** unless explicitly asked — it mutates the live system
- **Don't modify `flake.lock`** directly — that's `just update`'s job
- **Don't add packages to platform modules** without first checking if they work in `modules/shared/`
- **Don't create new top-level modules** without discussing placement — the structure is intentional

### Upstream Revisit Notation

For temporary workarounds blocked on upstream changes, use this marker in comments and TODOs:

- `REVISIT(upstream): <action when unblocked>; ref: <url-or-issue>; checked: <YYYY-MM-DD>`
- Keep one central checklist in `TODO.md` under an "Upstream Watchlist" section.
- When updating `flake.lock`, re-check all `REVISIT(upstream)` items before removing overrides/workarounds.

### Platform-conditional pattern

When a package needs different sources per platform, use `pkgs.stdenv.isDarwin` in a shared module rather than duplicating across platform modules:

```nix
# package = null means "installed outside nix" (e.g., via brew cask on macOS)
package = lib.mkIf pkgs.stdenv.isDarwin null;
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
- **Stylix:** shared defaults in `modules/shared/system/stylix.nix`; NixOS home uses dark/light specialisations with darkman auto-switching
- **macOS behavior:** Ghostty and Zed keep native system-responsive theming (Stylix targets disabled on darwin)

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

## Roadmap

### Phase 1 — NixOS-WSL on gaming PC (`trfwsl`)

Interim homelab: run services inside NixOS-WSL on the existing Windows desktop until a dedicated server is available.

1. Add `nixos-wsl` flake input
2. Build out `trfwsl` host config with WSL module (`wsl.enable`, `wsl.defaultUser`, etc.)
3. Enable native NixOS service modules for homelab stack (Plex/Jellyfin, Immich, *arr, etc.)
4. Media storage stays on Windows NTFS drives (accessed via `/mnt/`)
5. Tailscale for remote access (works on eduroam via DERP relay fallback over port 443)
6. Auto-start WSL via Windows scheduled task

**Constraints:** WSL doesn't auto-start with Windows, networking is NAT'd by default (use mirrored mode or Tailscale), no direct disk/hardware access, Windows updates can kill WSL. Acceptable for an interim setup.

### Phase 2 — Dedicated NixOS server (`trflab`)

When a separate machine is available:

1. Same service configs from phase 1, swap WSL module for real hardware config
2. NAS or network-attached storage with proper Linux filesystem (ext4/ZFS/btrfs)
3. Auto-update/rebuild via systemd timers
4. Tailscale carries over unchanged
5. `trfwsl` becomes a lightweight dev environment on the gaming PC

### Naming convention

Hostnames follow `trf<identifier>` — initials prefix for network disambiguation (eduroam has many colliding default Apple/Windows names), short suffix for the device/role. Under 7 chars, unique prefixes for tab completion.

### Future machines

- **`trflab`** — dedicated homelab server (phase 2)
- **`trfvm`** — scratch/sandbox NixOS VM (host TBD — could be local on Mac via UTM, or on the gaming PC via Hyper-V)
- **`trfnix`** may be retired when the Samsung laptop is repurposed or replaced

## Active overlays

- **`overlays/vesktop-darwin.nix`** — fixes codesign failure on macOS; `REVISIT(upstream): remove overlay after NixOS/nixpkgs#489725 lands in nixpkgs-unstable`
- **`overlays/zed-editor-darwin.nix`** — temporary zed-editor darwin fix; `REVISIT(upstream): remove overlay after NixOS/nixpkgs#490957 lands in nixpkgs-unstable`
