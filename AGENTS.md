# Nix Configuration — Agent Guide

## Owner

Thomas FitzGerald (`tomrfitz`) — macOS (aarch64-darwin), with plans for NixOS (x86_64-linux).

## Build & Apply

```sh
cd ~/nixos-config
sudo nix run nix-darwin -- switch --flake .#tomrfitz
```

Rollback: `sudo darwin-rebuild switch --rollback`

Make use of static analysis tools and formatters before making commits.

## Repository Structure

```text
flake.nix                       # Entry point: darwinConfigurations + nixosConfigurations
hosts/
  darwin/default.nix            # macOS system-level config (brew casks, system defaults, nix settings, users)
  nixos/default.nix             # NixOS system-level config (stub — no target machine yet)
modules/
  shared/home-manager.nix       # Cross-platform user config (the bulk of everything)
  darwin/home-manager.nix       # macOS-specific user config (brew shellenv, 1Password, ghostty macOS keys, SSH agent)
  nixos/home-manager.nix        # NixOS-specific user config (stub)
config/
  starship.toml                 # Starship prompt config (imported via lib.importTOML)
  helix-flexoki-dark.toml       # Helix Flexoki Dark theme (imported via lib.importTOML)
  helix-flexoki-light.toml      # Helix Flexoki Light theme (imported via lib.importTOML)
secrets/
  secrets.nix                   # Agenix public key mapping (read by CLI, not imported into system config)
  test-secret.age               # Encrypted test secret (verifies agenix pipeline)
```

The key design principle: **`modules/shared/` should contain as much as possible.** Platform-specific modules should only contain things that genuinely differ between macOS and Linux (paths, package sources, platform-specific app settings).

## Package Source Priority

When deciding where to install something, prefer in this order:

1. **Cross-platform nixpkg** (in `modules/shared/`) — best for reproducibility
2. **Darwin-only nixpkg** (in `modules/darwin/`) — when the package only makes sense on macOS
3. **Homebrew cask** (in `hosts/darwin/`) — for macOS GUI apps not in nixpkgs
4. **Mac App Store via mas** — for apps only available there

## Project Goals

### Vision

A single nix flake that fully declares the user environment for both macOS (nix-darwin) and NixOS. Running `darwin-rebuild switch` or `nixos-rebuild switch` on a fresh machine should reproduce the entire working environment with zero (or near-zero) manual steps.

### Design Principles

1. **Maximize native home-manager modules** — use `programs.*` options over raw `home.file` wherever a module exists. This gives better integration (shell integration flags, proper config generation, etc.)

2. **Minimize platform-specific config** — anything that can be expressed identically on both OSes belongs in `modules/shared/`. Platform modules should be thin.

3. **Nix replaces other package managers** — CLI tools should come from nixpkgs, not brew/yay/etc. Homebrew is only for macOS GUI apps (casks) that aren't in nixpkgs. All brew casks are declared in `hosts/darwin/default.nix` with `homebrew.onActivation.cleanup = "zap"` so brew is fully declarative.

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
- [ ] Rename repo from `nixos-config` to `nix-config` (it's primarily nix-darwin, not NixOS)

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

### Style Notes

- Use section headers with box-drawing characters (`# ── Section ──`) for visual separation in nix files
- Keep nix files well-organized with clear sections
- Prefer structured `programs.*.settings` over raw `home.file` text blocks
- When adding a new tool: first check if a `programs.*` module exists in home-manager before falling back to `home.file` or `xdg.configFile`
