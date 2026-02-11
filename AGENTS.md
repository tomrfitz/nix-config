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
      default.nix                    # HM aggregator (session vars, ghostty, tmux, ssh, topgrade, agenix)
      packages.nix                   # home.packages (CLI tools, dev toolchains, fonts)
      shell.nix                      # Zsh, starship, atuin, zoxide, fzf
      git.nix                        # Git, delta, jujutsu
      firefox.nix                    # Firefox policies + extensions
      fastfetch.nix                  # Fastfetch config
      editors.nix                    # Helix, neovim, vscode, zed
  darwin/
    system/
      default.nix                    # Aggregator (imports homebrew, defaults, security)
      homebrew.nix                   # Taps, brews, casks, masApps
      defaults.nix                   # macOS system.defaults (dock, trackpad, finder, etc.)
      security.nix                   # Touch ID for sudo
    home/
      default.nix                    # Aggregator + macOS basics (packages, paths, session vars)
      zsh.nix                        # macOS-specific shell (brew shellenv, bun, nvm, jn function)
      git.nix                        # 1Password SSH signing, gh credential helpers
      ssh.nix                        # 1Password agent socket
      topgrade.nix                   # Darwin rebuild, brew settings, nvd diff
      ghostty.nix                    # macOS-specific ghostty settings
  nixos/
    system/
      default.nix                    # NixOS system basics (zsh enable)
    home/
      default.nix                    # Aggregator (homeDirectory)
      ghostty.nix                    # Ghostty from flake input
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
3. **cask** (in `hosts/darwin/`) — for macOS GUI apps not in nixpkgs
4. **Mac App Store via mas** — for apps only available there

## Project Goals

### Vision

A single nix flake that fully declares the user environment for both macOS (nix-darwin) and NixOS. Running `darwin-rebuild switch` or `nixos-rebuild switch` on a fresh machine should reproduce the entire working environment with zero (or near-zero) manual steps.

### Design Principles

1. **Maximize native home-manager modules** — use `programs.*` options over raw `home.file` wherever a module exists. This gives better integration (shell integration flags, proper config generation, etc.)

2. **Minimize platform-specific config** — anything that can be expressed identically on both OSes belongs in `modules/shared/`. Platform modules should be thin.

3. **Nix replaces other package managers** — CLI tools should come from nixpkgs, not brew/yay/etc. Homebrew is only for macOS GUI apps (casks) that aren't in nixpkgs. All brew casks are declared in `modules/darwin/system/homebrew.nix` with `homebrew.onActivation.cleanup` so brew is fully declarative.

4. **Nix replaces topgrade and manual updates** — `nix flake update` + `darwin-rebuild switch` is the single update path. This can be automated via a launchd agent.

5. **Config should be stable** — once set up, the config should rarely need commits except when adopting new tools or when upstream nix modules add new capabilities worth using.

6. **Never break the live machine** — this is the user's primary work machine. All changes are additive. The `backupFileExtension = "hm-backup"` setting preserves originals. Test with `--dry-run` when uncertain.

### Migration Status

#### Done

- [x] nix-darwin + home-manager installed and working
- [x] Zsh config (aliases, env vars, PATH, completions, plugins, functions)
- [x] Git config (signing, delta, LFS, credential helpers)
- [x] Starship prompt (full config via lib.importTOML from config/starship.toml)
- [x] Atuin shell history (native module, inline settings)
- [x] Zoxide (native module)
- [x] Fzf (native module)
- [x] Ghostty terminal (native module, platform-aware)
- [x] CLI tools via native modules: bat, eza, fd, ripgrep, jq, btop, htop, gh, lazygit, helix, neovim, fastfetch, jujutsu, delta
- [x] Zsh plugins (autosuggestions, fast-syntax-highlighting) sourced from nixpkgs instead of brew
- [x] Chezmoi-managed dotfiles fully replaced (zshrc, zprofile, zshenv, gitconfig, starship.toml)
- [x] macOS system defaults (dock, trackpad, Finder, screenshot, menu bar, NSGlobalDomain)
- [x] Homebrew CLI formulae migrated to nix `home.packages`
- [x] Fastfetch config inlined via `programs.fastfetch.settings`
- [x] Agenix secrets management (flake input, HM module, test secret verified)
- [x] Fonts managed via nix `home.packages` (nerd fonts, iosevka, fira-code, etc.)
- [x] All Homebrew casks declared — `homebrew.onActivation.cleanup = "zap"` enabled
- [x] SSH config via `programs.ssh` (1Password agent on darwin, GitHub ControlMaster multiplexing)
- [x] Tmux via `programs.tmux` (mouse, vi keys, 50k history, base-index 1)
- [x] Helix via `programs.helix` (Flexoki dark/light themes via lib.importTOML)
- [x] Neovim via `programs.neovim` (minimal initLua, viAlias/vimAlias)
- [x] Firefox via `programs.firefox` (38 extensions via policies, privacy hardening)
- [x] Topgrade config via `programs.topgrade` (native HM module, nix-darwin rebuild as custom command)
- [x] Additional cask-to-nix migrations: alacritty, kitty, vscode, firefox, 1password-cli, powershell, mactex

#### Next Steps (priority order)

- [ ] Editor configs: Zed — settings via HM module; Helix language servers; Neovim deeper config if needed
- [ ] Configure alacritty and kitty settings (currently just `.enable = true`)
- [ ] Real secrets via agenix (API tokens, SSH keys — currently only a test secret)
- [ ] Desktop wallpaper (nix-darwin can manage this)
- [ ] Auto-update via launchd agent (nix flake update + rebuild on schedule)
- [ ] NixOS host config when a target Linux machine is available
- [ ] Retire chezmoi entirely (remove from packages, delete `~/.local/share/chezmoi`)
- [ ] Remove old `~/.gitconfig` (HM-managed config at `~/.config/git/config` is authoritative)
- [ ] Clean up old dotfiles (topgrade backup, helix `.hm-backup` files)
- [ ] Uninstall leftover Homebrew CLI formulae that are now nix packages (`brew leaves` still shows ~127)
- [x] Rename repo from `nixos-config` to `nix-config` (it's primarily nix-darwin, not NixOS)

#### Hard Boundaries (can't fully nix-ify)

- Apple ID / iCloud / Google Drive sign-in (account state, not config)
- App Store apps require Apple ID login first (mas can install declaratively after)
- 1Password vault content
- Browser profiles / bookmarks (partial — extensions can be managed for Firefox)

### Important Context

- The old `.gitconfig` at `~/.gitconfig` still exists alongside the HM-managed `~/.config/git/config`. Git reads both. It should be removed once confident in the nix config.
- Ghostty is installed via Homebrew cask on macOS (so `package = null` in the HM module) but would be installed via nixpkgs on NixOS.
- The flake currently pins `nixpkgs-unstable`. This is intentional for access to latest packages.
- Apple-proprietary fonts (SF Mono, SF Pro) remain as Homebrew casks since they're not in nixpkgs.
- Some upstream nixpkgs packages are currently broken on aarch64-darwin and commented out: `cava` (unity-test build failure), `poetry` (rapidfuzz atomics failure), `gossip` (SDL2/CMake conflict). Revisit after `nix flake update`.
- Firefox extensions are managed declaratively via `policies.ExtensionSettings` (38 extensions). Browser profiles/bookmarks are not managed.

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
