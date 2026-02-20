# Nix Config — TODO

## Next Steps

- [ ] Helix language servers — configure and pin per-language tooling (nixd/ruff/ty/etc.)
- [ ] Real secrets via agenix (API tokens, SSH keys — currently only a test secret)
- [ ] Auto-update via launchd agent (nix flake update + rebuild on schedule)
- [ ] Login items — investigate declaring startup apps via `launchd.agents`
- [ ] Audit imperatively installed cargo packages (`rana`, `sgram-tui`) — package in nix or keep in cargo

## Upstream Watchlist

- [ ] `REVISIT(upstream): remove zed darwin overlay after fix is present in pinned nixpkgs rev; ref: https://github.com/NixOS/nixpkgs/pull/490957; checked: 2026-02-20`
- [ ] `REVISIT(upstream): remove vesktop darwin overlay after upstream fix lands in pinned nixpkgs rev; ref: https://github.com/NixOS/nixpkgs/issues/489725; checked: 2026-02-20`
- [ ] `REVISIT(upstream): remove polkit-agent-helper workaround once camera-device sandboxing fix lands; ref: https://github.com/NixOS/nixpkgs/issues/486044; checked: 2026-02-20`

## Phase 1 — NixOS-WSL homelab (`trfwsl`)

Interim homelab on gaming PC via NixOS-WSL. See AGENTS.md Roadmap for context.

- [ ] Add `nixos-wsl` flake input (follows nixpkgs)
- [ ] Add WSL module (`wsl.enable`, `wsl.defaultUser`) to `hosts/trfwsl`
- [ ] Bootstrap NixOS-WSL on gaming PC (import tarball, generate agenix key, rekey)
- [ ] Set up Tailscale (`services.tailscale.enable`) for remote access from Mac/phone
- [ ] Create `modules/nixos/system/homelab.nix` for service definitions (host-agnostic)
- [ ] Enable homelab services: Plex or Jellyfin, Immich, *arr stack
- [ ] Configure media storage mounts (NTFS via `/mnt/` for now)
- [ ] Windows-side: scheduled task to auto-start WSL, `.wslconfig` for mirrored networking
- [ ] Test Tailscale on eduroam (DERP relay fallback over 443)

## Phase 2 — Dedicated NixOS server (`trflab`)

- [ ] Provision new machine, add `trflab` host to flake
- [ ] Reuse homelab service module from phase 1 (swap WSL module for hardware config)
- [ ] Set up NAS/network storage with proper Linux filesystem
- [ ] Auto-rebuild via systemd timer (`nixos-rebuild switch --flake`)
- [ ] Demote `trfwsl` to lightweight dev environment

## Undeclared Apps

### /Applications (not in casks, MAS, or nix)

| App                                         | Source         | Action                                                        |
| ------------------------------------------- | -------------- | ------------------------------------------------------------- |
| FlixorMac.app                               | Unknown        | Add to casks or remove                                        |
| Google Docs/Sheets/Slides                   | Chrome PWAs    | No action needed                                              |
| Subway Builder.app                          | Unknown        | Add to casks or remove                                        |
| Pear Desktop.app (fka YouTube Music)        | Manual install | No cask available — renamed for legal reasons, brew cask gone |
| TinkerTool.app / BresinkSoftwareUpdater.app | Manual install | No cask available — manual install only                       |

### Post-Bootstrap Manual Steps

- [ ] Install Xcode via `xcodes install --latest` (requires Apple ID auth, can't be fully declarative)
- [ ] Sign into Apple ID for Mac App Store apps
- [ ] Sign into 1Password, Google Drive, iCloud

## Launch Agents / Daemons

### User Launch Agents (`~/Library/LaunchAgents/`)

| Agent                                    | Status    | Notes                                                               |
| ---------------------------------------- | --------- | ------------------------------------------------------------------- |
| `Handy`                                  | Running   | Starts `/Applications/Handy.app` at login. Could use launchd.agents |
| `com.riot.riotclient.checkinstalls`      | Installed | Riot/League auto-updater — app-managed, leave as-is                 |
| `com.valvesoftware.steamclean`           | Installed | Steam cleanup — app-managed, leave as-is                            |
| `org.nix-community.home.activate-agenix` | Installed | Managed by HM agenix module — leave as-is                           |

### Login Items (macOS System Settings)

Currently configured: Ice, One Thing, Ghostty, Loop, TabTab, BatFi, Stats, Maccy,
Mullvad VPN, Google Drive, ActivityWatch, LookAway, Shottr, Pika, BetterDisplay,
KeyClu, Velja, Macs Fan Control, KeepingYouAwake.

These are managed via macOS System Settings, not nix. Some could potentially be
declared via `launchd.agents` in home-manager instead.

## Broken Packages (revisit after `nix flake update`)

- `cava` — unity-test build failure on aarch64-darwin
- `poetry` — rapidfuzz atomics failure on aarch64-darwin
- `gossip` — SDL2/CMake version conflict on aarch64-darwin

## Done

- [x] nix-darwin + home-manager installed and working
- [x] Zsh config (aliases, env vars, PATH, completions, plugins, functions)
- [x] Git config (signing, delta, LFS, credential helpers)
- [x] Starship prompt (full config via lib.importTOML)
- [x] Atuin, zoxide, fzf (native modules)
- [x] Ghostty terminal (single shared module, platform-conditional package)
- [x] CLI tools via native modules (bat, eza, fd, ripgrep, jq, btop, htop, gh, lazygit, helix, neovim, fastfetch, jujutsu, delta)
- [x] Zsh plugins (autosuggestions, fast-syntax-highlighting) from nixpkgs
- [x] Chezmoi-managed dotfiles fully replaced and chezmoi retired
- [x] macOS system defaults (dock, trackpad, Finder, screenshot, menu bar)
- [x] Homebrew CLI formulae migrated to nix home.packages
- [x] Fastfetch config via programs.fastfetch.settings
- [x] Agenix secrets management (flake input, HM module, test secret)
- [x] Fonts via nix home.packages (nerd fonts, iosevka, fira-code, etc.)
- [x] All Homebrew casks declared with cleanup enabled
- [x] MAS apps declared (14 apps)
- [x] SSH config (1Password agent on darwin, GitHub ControlMaster)
- [x] Tmux (mouse, vi keys, 50k history, base-index 1)
- [x] Helix (Flexoki dark/light themes via lib.importTOML)
- [x] Neovim (initLua, viAlias/vimAlias)
- [x] Firefox (38 extensions via policies, privacy hardening)
- [x] Topgrade (nix-darwin rebuild as custom command, nvd diff)
- [x] Cask-to-nix migrations (alacritty, kitty, vscode, firefox, 1password-cli, powershell, mactex)
- [x] Zed editor (programs.zed-editor with settings + extensions, stable .app alias for keychain)
- [x] Emacs-plus via brew on darwin (build.yml managed by HM), vanilla emacs via nix on nixos
- [x] 1Password via brew cask on darwin, nix on nixos
- [x] Repo restructured (machine-named hosts, modular system/home split, mkHM helper)
- [x] Rename repo from nixos-config to nix-config
- [x] Old ~/.gitconfig removed
- [x] Stale .hm-backup files cleaned up
- [x] Spotifyd removed (package + stale brew launch agent)
- [x] Removed stale apps (TickTick, Surf, Surf 2)
- [x] Removed Warp from login items
- [x] PATH cleanup (removed broken yarn segment, consolidated sessionPath)
- [x] Brew leaves audited — all are emacs-plus build deps, not leftovers
- [x] Go tools declared in nix (delve, gopls, gotests, impl, go-tools)
- [x] Node tools declared in nix (prettier, yarn)
- [x] Mist and Microsoft Office added to casks
- [x] xcodes CLI added to nix packages (Xcode managed via `xcodes install`)
- [x] Axonium, iA Writer dropped (not needed)
- [x] Imperative install audit complete
- [x] Configure alacritty and kitty via home-manager
- [x] Desktop wallpaper managed via Stylix (`config/wallpaper.jpg`)
