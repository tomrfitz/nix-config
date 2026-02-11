# Nix Config — TODO

## Next Steps

- [ ] Configure alacritty and kitty settings (currently just `.enable = true`)
- [ ] Helix language servers — configure LSPs
- [ ] Real secrets via agenix (API tokens, SSH keys — currently only a test secret)
- [ ] Desktop wallpaper (nix-darwin can manage this)
- [ ] Auto-update via launchd agent (nix flake update + rebuild on schedule)
- [ ] NixOS host config when a target Linux machine is available
- [ ] Login items — investigate declaring startup apps via `launchd.agents`
- [ ] Uninstall leftover Homebrew CLI formulae (`brew leaves` to audit)

## Undeclared Apps

### Mac App Store

| App   | MAS ID    | Notes          |
| ----- | --------- | -------------- |
| Xcode | 497799835 | Add to masApps |

- [ ] Look into using xcodes to manage xcode versions declaratively. I only need the most recent major version

### /Applications (not in casks, MAS, or nix)

| App                                  | Source         | Action                                                        |
| ------------------------------------ | -------------- | ------------------------------------------------------------- |
| FlixorMac.app                        | Unknown        | Add to casks or remove                                        |
| Google Docs/Sheets/Slides            | Chrome PWAs    | No action needed                                              |
| Subway Builder.app                   | Unknown        | Add to casks or remove                                        |
| Pear Desktop.app (fka YouTube Music) | Manual install | No cask available — renamed for legal reasons, brew cask gone |

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
