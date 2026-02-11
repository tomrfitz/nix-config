# Nix Configuration — Agent Guide

## Owner

Thomas FitzGerald (`tomrfitz`) — macOS (aarch64-darwin), with plans for NixOS (x86_64-linux).

## Build & Apply

```sh
cd ~/nix-config
sudo darwin-rebuild switch
```

Rollback: `sudo darwin-rebuild switch --rollback`

Make use of static analysis tools and formatters before making commits.

## Repository Structure

```text
flake.nix                            # Entry point with mkHM helper (DRY home-manager config)
hosts/
  trfmbp/default.nix                 # macOS laptop — thin wiring (hostname, user, system packages)
  trfnix/default.nix                 # NixOS laptop — thin wiring (stub)
  trfhomelab/default.nix             # NixOS home server — placeholder
modules/
  shared/
    system/
      nix.nix                        # nixpkgs + flakes settings (imported by all hosts)
    home/
      default.nix                    # HM aggregator (session vars, tmux, ssh, topgrade, agenix)
      packages.nix                   # home.packages (CLI tools, dev toolchains, fonts)
      shell.nix                      # Zsh, starship, atuin, zoxide, fzf
      git.nix                        # Git, delta, jujutsu
      ghostty.nix                    # Ghostty (platform-conditional package via isDarwin)
      firefox.nix                    # Firefox policies + extensions
      fastfetch.nix                  # Fastfetch config
      editors.nix                    # Helix, neovim, vscode, zed
  darwin/
    system/
      default.nix                    # Aggregator (imports homebrew, settings, security)
      homebrew.nix                   # Taps, brews, casks, masApps
      settings.nix                   # macOS system.defaults (dock, trackpad, finder, etc.)
      security.nix                   # Touch ID for sudo
    home/
      default.nix                    # Aggregator + macOS basics (packages, paths, session vars, emacs-plus build.yml)
      zsh.nix                        # macOS-specific shell (brew shellenv, bun, nvm, jn function, zed alias)
      git.nix                        # 1Password SSH signing, gh credential helpers
      ssh.nix                        # 1Password agent socket
      topgrade.nix                   # Darwin rebuild, brew settings, nvd diff
  nixos/
    system/
      default.nix                    # NixOS system basics (zsh enable)
    home/
      default.nix                    # Aggregator (homeDirectory, nixos-only packages)
config/
  starship.toml                      # Starship prompt config (imported via lib.importTOML)
  helix-flexoki-dark.toml            # Helix Flexoki Dark theme (imported via lib.importTOML)
  helix-flexoki-light.toml           # Helix Flexoki Light theme (imported via lib.importTOML)
secrets/
  secrets.nix                        # Agenix public key mapping
  test-secret.age                    # Encrypted test secret
```

### Design principles

- **Hosts are machines, not OSes** — `hosts/trfmbp/`, not `hosts/darwin/`. The machine is the stable identity.
- **Host files are thin wiring** — hostname, user, system packages, and imports. All logic lives in modules.
- **`modules/shared/` contains as much as possible** — platform modules only hold things that genuinely differ between macOS and Linux.
- **`default.nix` files are aggregators** — mostly `imports = [...]` lists. Business logic lives in focused single-concern modules.
- **`flake.nix` uses a `mkHM` helper** — DRYs the repeated home-manager configuration block across all hosts.

## Package Source Priority

When deciding where to install something, prefer in this order:

1. **Cross-platform nixpkg** (in `modules/shared/`) — best for reproducibility
2. **Darwin-only nixpkg** (in `modules/darwin/`) — when the package only makes sense on macOS
3. **Homebrew cask** (in `modules/darwin/system/homebrew.nix`) — for macOS GUI apps not in nixpkgs
4. **Mac App Store via mas** — for apps only available there

### Brew-preferred packages (system integration)

Some packages work better via brew on macOS due to keychain access, code signing, system entitlements, or custom build features. These use nix on NixOS but brew on darwin:

- **1Password** — SSH agent socket, browser extension, Touch ID require brew cask. `_1password-gui` is nixos-only in `modules/nixos/home/default.nix`.
- **Emacs** — emacs-plus@31 via `d12frosted/emacs-plus` tap for macOS-native patches and custom icon. Build config managed via HM (`xdg.configFile."emacs-plus/build.yml"`). Vanilla `emacs` is nixos-only.
- **Ghostty** — brew cask on macOS (`package = null`), flake package on NixOS. Platform selection handled automatically via `pkgs.stdenv.isDarwin` in `modules/shared/home/ghostty.nix`.
- **Zed** — installed via nix `programs.zed-editor` for config management, but the `zed` shell alias in `modules/darwin/home/zsh.nix` points to the stable `~/Applications/Home Manager Apps/Zed.app/Contents/MacOS/cli` to preserve keychain access across rebuilds.

## Project Goals

### Vision

A single nix flake that fully declares the user environment for macOS (nix-darwin), NixOS workstation, and NixOS home server. Running `darwin-rebuild switch` or `nixos-rebuild switch` on a fresh machine should reproduce the entire working environment with zero (or near-zero) manual steps.

### Design Principles

1. **Maximize native home-manager modules** — use `programs.*` options over raw `home.file` wherever a module exists. This gives better integration (shell integration flags, proper config generation, etc.)

2. **Minimize platform-specific config** — anything that can be expressed identically on both OSes belongs in `modules/shared/`. Platform modules should be thin. Use `pkgs.stdenv.isDarwin` / `pkgs.stdenv.isLinux` for platform-conditional values within shared modules where it keeps things concise.

3. **Nix replaces other package managers** — CLI tools should come from nixpkgs, not brew/yay/etc. Homebrew is only for macOS GUI apps (casks) that aren't in nixpkgs, or apps that need macOS system integration (see "Brew-preferred packages" above). All brew entries are declared in `modules/darwin/system/homebrew.nix` with `homebrew.onActivation.cleanup` so brew is fully declarative.

4. **Config should be stable** — once set up, the config should rarely need commits except when adopting new tools or when upstream nix modules add new capabilities worth using.

5. **Never break the live machine** — this is the user's primary work machine. All changes are additive. The `backupFileExtension = "hm-backup"` setting preserves originals. Test with `--dry-run` when uncertain.

### Important Context

- The flake pins `nixpkgs-unstable`. This is intentional for access to latest packages.
- Apple-proprietary fonts (SF Mono, SF Pro) remain as Homebrew casks since they're not in nixpkgs.
- Some upstream nixpkgs packages are currently broken on aarch64-darwin and commented out in `packages.nix`: `cava`, `poetry`, `gossip`. Revisit after `nix flake update`.
- Firefox extensions are managed declaratively via `policies.ExtensionSettings`. Browser profiles/bookmarks are not managed.

### Hard Boundaries (can't fully nix-ify)

- Apple ID / iCloud / Google Drive sign-in (account state, not config)
- App Store apps require Apple ID login first (mas can install declaratively after)
- 1Password vault content
- Browser profiles / bookmarks (partial — extensions can be managed for Firefox)

### Problem-Solving Approach

When implementing new features or restructuring, **design for the final state from the start**. Don't build incrementally toward a structure you can already foresee — lay the foundation correctly and fill it in. Specifically:

1. **Think about where things will live at scale** — if a module will eventually need splitting, split it now rather than cramming everything into one file and refactoring later.
2. **Name things for what they are, not what category they happen to fall into today** — e.g., hosts should be named for the machine (`trfmbp`), not the OS (`darwin`), because the machine is the stable identity.
3. **DRY from the start** — if you can see that a pattern will be repeated (e.g., home-manager boilerplate for each host), extract a helper immediately rather than copy-pasting and planning to refactor later.
4. **Keep aggregator files thin** — `default.nix` files should mostly be `imports = [...]` lists. Business logic belongs in focused, single-concern modules.
5. **Match directory structure to mental model** — the repo structure should mirror how you think about the system (hosts → machines, modules → features), not implementation details.

### Style Notes

- Use section headers with box-drawing characters (`# ── Section ──`) for visual separation in nix files
- Keep nix files well-organized with clear sections
- Prefer structured `programs.*.settings` over raw `home.file` text blocks
- When adding a new tool: first check if a `programs.*` module exists in home-manager before falling back to `home.file` or `xdg.configFile`
