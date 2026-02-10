# Nix Configuration — Agent Guide

## Owner

Thomas FitzGerald (`tomrfitz`) — macOS (aarch64-darwin), with plans for NixOS (x86_64-linux).

## Build & Apply

```sh
cd ~/nixos-config
sudo nix run nix-darwin -- switch --flake .#tomrfitz
```

Rollback: `sudo darwin-rebuild switch --rollback`

## Repository Structure

```
flake.nix                       # Entry point: darwinConfigurations + nixosConfigurations
hosts/
  darwin/default.nix            # macOS system-level config (brew casks, nix settings, users)
  nixos/default.nix             # NixOS system-level config (stub — no target machine yet)
modules/
  shared/home-manager.nix       # Cross-platform user config (the bulk of everything)
  darwin/home-manager.nix       # macOS-specific user config (brew shellenv, 1Password, ghostty macOS keys)
  nixos/home-manager.nix        # NixOS-specific user config (stub)
starship.toml                   # Starship prompt config (imported via lib.importTOML)
fastfetch.jsonc                 # Fastfetch config (JSONC, managed via xdg.configFile)
atuin.toml                      # Reference copy of atuin config (not imported — settings are inline)
```

The key design principle: **`modules/shared/` should contain as much as possible.** Platform-specific modules should only contain things that genuinely differ between macOS and Linux (paths, package sources, platform-specific app settings).

## Project Goals

### Vision

A single nix flake that fully declares the user environment for both macOS (nix-darwin) and NixOS. Running `darwin-rebuild switch` or `nixos-rebuild switch` on a fresh machine should reproduce the entire working environment with zero (or near-zero) manual steps.

### Design Principles

1. **Maximize native home-manager modules** — use `programs.*` options over raw `home.file` wherever a module exists. This gives better integration (shell integration flags, proper config generation, etc.)

2. **Minimize platform-specific config** — anything that can be expressed identically on both OSes belongs in `modules/shared/`. Platform modules should be thin.

3. **Nix replaces other package managers** — CLI tools should come from nixpkgs, not brew/yay/etc. Homebrew is only for macOS GUI apps (casks) that aren't in nixpkgs. The goal is to eventually declare all brew casks in `hosts/darwin/default.nix` and enable `homebrew.onActivation.cleanup = "zap"` to make brew fully declarative.

4. **Nix replaces topgrade and manual updates** — `nix flake update` + `darwin-rebuild switch` is the single update path. This can be automated via a launchd agent.

5. **Config should be stable** — once set up, the config should rarely need commits except when adopting new tools or when upstream nix modules add new capabilities worth using.

6. **Never break the live machine** — this is the user's primary work machine. All changes are additive. The `backupFileExtension = "hm-backup"` setting preserves originals. Test with `--dry-run` when uncertain.

### Migration Status

#### Done
- [x] nix-darwin + home-manager installed and working
- [x] Zsh config (aliases, env vars, PATH, completions, plugins, functions)
- [x] Git config (signing, delta, LFS, credential helpers)
- [x] Starship prompt (full config via lib.importTOML)
- [x] Atuin shell history (native module)
- [x] Zoxide (native module)
- [x] Fzf (native module)
- [x] Ghostty terminal (native module, platform-aware)
- [x] CLI tools via native modules: bat, eza, fd, ripgrep, jq, btop, htop, gh, lazygit, helix, neovim, fastfetch, jujutsu, delta
- [x] Zsh plugins (autosuggestions, fast-syntax-highlighting) sourced from nixpkgs instead of brew
- [x] Chezmoi-managed dotfiles fully replaced (zshrc, zprofile, zshenv, gitconfig, starship.toml)

#### Next Steps (priority order)
- [ ] macOS system defaults (dock layout/size, keyboard repeat rate, trackpad settings, Finder preferences, NSGlobalDomain) — these are one-time declarations in `hosts/darwin/default.nix` via `system.defaults`
- [ ] Migrate remaining Homebrew CLI formulae to nix `home.packages` — run `brew leaves` to find what's not yet declared
- [ ] SSH config via `programs.ssh` in home-manager
- [ ] Declare all Homebrew casks — then enable `homebrew.onActivation.cleanup = "zap"`
- [ ] Secrets management (agenix or sops-nix) for SSH keys, API tokens
- [ ] Editor configs: Zed, Neovim, Helix — via their respective HM modules
- [ ] Additional app configs as HM modules exist (tmux, mpv, etc.)
- [ ] Desktop wallpaper (nix-darwin can manage this)
- [ ] Fonts (declarative via home-manager or nix-darwin)
- [ ] Auto-update via launchd agent (nix flake update + rebuild on schedule)
- [ ] NixOS host config when a target Linux machine is available
- [ ] Retire chezmoi entirely (remove from packages, delete `~/.local/share/chezmoi`)

#### Hard Boundaries (can't fully nix-ify)
- Apple ID / iCloud / Google Drive sign-in (account state, not config)
- App Store apps require Apple ID login first (mas can install declaratively after)
- 1Password vault content
- Browser profiles / bookmarks (partial — extensions can be managed for Firefox)

### Important Context

- The old `.gitconfig` at `~/.gitconfig` still exists alongside the HM-managed `~/.config/git/config`. Git reads both. It should be removed once the user is confident in the nix config.
- `atuin.toml` in the repo root is a reference copy. The actual atuin config is generated by `programs.atuin.settings` in the shared module. The reference file can be removed once no longer needed.
- Ghostty is installed via Homebrew cask on macOS (so `package = null` in the HM module) but would be installed via nixpkgs on NixOS.
- The flake currently pins `nixpkgs-unstable`. This is intentional for access to latest packages.

### Style Notes

- Use section headers with box-drawing characters (` # ── Section ──`) for visual separation in nix files
- Keep nix files well-organized with clear sections
- Prefer structured `programs.*.settings` over raw `home.file` text blocks
- When adding a new tool: first check if a `programs.*` module exists in home-manager before falling back to `home.file` or `xdg.configFile`
