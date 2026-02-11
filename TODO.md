# Nix Config — Audit & Future Work

## Mac App Store Apps (not yet declared via `mas`)

The following MAS apps are installed but not declared in the nix config.
Adding them via `homebrew.masApps` would make them declarative.

| App                    | MAS ID     |
| ---------------------- | ---------- |
| RapidClick             | 419891002  |
| KakaoTalk              | 869223134  |
| TestFlight             | 899247664  |
| Infuse                 | 1136220934 |
| Steam Link             | 1246969117 |
| Dropover               | 1355679052 |
| Flighty                | 1358823008 |
| Dark Reader for Safari | 1438243180 |
| Userscripts            | 1463298887 |
| Tot                    | 1491071483 |
| Hand Mirror            | 1502839586 |
| 1Password for Safari   | 1569813296 |
| One Thing              | 1604176982 |
| Velja                  | 1607635845 |
| Axonium                | 6756084985 |

## Launch Agents / Daemons That Could Be Declared

### User Launch Agents (`~/Library/LaunchAgents/`)

| Agent                                    | Status    | Notes                                                                                                                                                    |
| ---------------------------------------- | --------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `homebrew.mxcl.spotifyd`                 | Running   | spotifyd is already in `home.packages` via nix; this brew launch agent is leftover. Could use `launchd.agents` in HM or `services.spotifyd` if available |
| `Handy`                                  | Running   | Starts `/Applications/Handy.app` at login. Could be a `launchd.agents` entry                                                                             |
| `com.riot.riotclient.checkinstalls`      | Installed | Riot/League auto-updater — app-managed, leave as-is                                                                                                      |
| `com.valvesoftware.steamclean`           | Installed | Steam cleanup — app-managed, leave as-is                                                                                                                 |
| `org.nix-community.home.activate-agenix` | Installed | Managed by HM agenix module — leave as-is                                                                                                                |

### System Launch Agents (`/Library/LaunchAgents/`)

All app-managed (Google, Microsoft, Zoom, RustDesk) — no action needed.

### System Launch Daemons (`/Library/LaunchDaemons/`)

All either app-managed or nix-managed (`org.nixos.*`, `systems.determinate.*`) — no action needed.

### Login Items (macOS System Settings)

Currently configured: Ice, One Thing, Ghostty, Loop, TabTab, BatFi, Stats, Maccy,
Mullvad VPN, Google Drive, ActivityWatch, LookAway, Shottr, Pika, BetterDisplay,
KeyClu, Warp, Velja, Macs Fan Control, KeepingYouAwake.

These are managed via macOS System Settings, not nix. Some could potentially be
declared via `launchd.agents` in home-manager instead.

## Brew Formula Still Installed (not in nix)

- `mole` — declared in `hosts/darwin/default.nix` under `brews`. Check if available in nixpkgs.

## ~~Spotifyd Conflict~~ (resolved)

Removed spotifyd from `home.packages` and deleted the stale brew launch agent.

## Cleanup Candidates

- [x] Old `~/.gitconfig` — already gone
- [x] Retire chezmoi — removed `~/.local/share/chezmoi`
- [x] Removed spotifyd from `home.packages` and its stale brew launch agent
- [x] Removed TickTick.app, Surf.app, Surf 2.app from /Applications
- [x] `~/.hm-backup` files — removed 14 stale backups
- [x] Removed Warp from login items (app was uninstalled, stale entry)
- [ ] Uninstall leftover Homebrew CLI formulae (`brew leaves` shows `mole` — check others)

## Apps in /Applications Not Declared Anywhere

These are in `/Applications/` but not in casks, MAS, or nix packages:

| App                                  | Source                    | Action                                                        |
| ------------------------------------ | ------------------------- | ------------------------------------------------------------- |
| Emacs.app / Emacs Client.app         | Unknown (manual install?) | Add as cask `emacs-mac` or build via nix                      |
| FlixorMac.app                        | Unknown                   | Add to casks or remove                                        |
| Google Docs/Sheets/Slides            | Chrome PWAs               | No action needed                                              |
| iA Writer.app                        | Likely MAS                | Check MAS ID and add to masApps                               |
| Subway Builder.app                   | Unknown                   | Add to casks or remove                                        |
| ~~Surf.app / Surf 2.app~~            | Removed                   | Deleted                                                       |
| ~~TickTick.app~~                     | Removed                   | Deleted                                                       |
| Pear Desktop.app (fka YouTube Music) | Manual install            | No cask available — renamed for legal reasons, brew cask gone |
| Xcode.app                            | MAS                       | Add to masApps (ID: 497799835)                                |

## PATH Cleanup

Entries currently on `$PATH` that need attention:

| PATH entry                                                    | Action                                                                                |
| ------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| `$HOME/.cargo/bin`                                            | ✅ Added to darwin `home.sessionPath`                                                 |
| `$HOME/Library/Application Support/JetBrains/Toolbox/scripts` | ✅ Moved from `profileExtra` to darwin `home.sessionPath`                             |
| `$HOME/Library/Application Support/Coursier/bin`              | ✅ Moved from `profileExtra` to darwin `home.sessionPath`                             |
| `/Applications/Ghostty.app/Contents/MacOS`                    | Not stale — added by Ghostty's own shell integration (`GHOSTTY_SHELL_FEATURES=path`)  |
| `$HOME/.zsh/plugins/zsh-autosuggestions`                      | Not stale — added by HM's `programs.zsh.plugins` mechanism                            |
| `$HOME/.zsh/plugins/zsh-fast-syntax-highlighting`             | Same as above                                                                         |
| Broken yarn path segment                                      | ✅ Removed `yarn global bin` from `initContent` (was outputting error text into PATH) |

## Recommended Priority

- [x] **Declare MAS apps** via `homebrew.masApps` — 15 apps added
- [x] **Spotifyd** — removed from packages and deleted stale launch agent
- [x] **Cleanup** — removed hm-backup files, chezmoi data, Warp login item, stale apps
- [x] **Zed editor** — migrated to `programs.zed-editor` HM module with full settings + extensions
- [ ] **Configure alacritty and kitty settings** — both are `.enable = true` with no config
- [ ] **Helix language servers** — configure LSPs
- [ ] **Resolve undeclared apps** — Emacs, FlixorMac, iA Writer, Subway Builder
- [ ] **Auto-update via launchd** — `nix flake update` + rebuild on schedule
- [ ] **Real secrets via agenix** — API tokens beyond the test secret
- [ ] **Login items** — investigate declaring startup apps via `launchd.agents`
