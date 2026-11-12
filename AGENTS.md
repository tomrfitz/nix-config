# AGENTS.md

Repo-specific guidance for AI agents working on this nix-config.
See also `~/.config/AGENTS.md` for global, project-agnostic conventions.

## What This Is

A Nix flake managing macOS (nix-darwin) and NixOS systems with home-manager.
Tracks on nixpkgs-unstable.
Uses nixpkgs' default Nix (CppNix) on every host.

### Machines

| Hostname | Platform | Role | Status |
| -------- | ---------------- | ---------------------------------------- | ------ |
| `fortis` | aarch64-darwin | Primary Mac (M5 Pro MacBook Pro) | Active |
| `lenis` | aarch64-darwin | Secondary Mac (M1 Pro MacBook Pro) | Active |
| `trfnix` | x86_64-linux | NixOS testbed (Samsung laptop) | Dormant |
| `trfwsl` | x86_64-linux WSL | Interim homelab on gaming PC, later dev | Active |
| `trflab` | x86_64-linux | Dedicated homelab server | Future |
| `trfvm` | TBD | Scratch/sandbox VM | Future |

The primary config target is `fortis`.
`fortis` takes the whole `mac` profile in `flake.nix`:
every cask and App Store app, paneru and the desktop home modules.
`lenis` is headless and holds as little as it can
(see Headless Macs):
in `flake.nix` it replaces the profile's modules with `batt.nix`,
`headless.nix` and a home list without `desktop.nix`.
Each Mac has one charge limiter (see Charge limiters).
`trfnix` is a real NixOS install useful for prototyping NixOS service configs
(and the only host that exercises the Linux desktop modules);
it has been powered off since ~2026-03, so the daily pipeline only evaluates it.
`trfwsl` runs NixOS-WSL with Tailscale, ollama, a Rex server
(see Rex),
Attic and the auto-update pipeline; its homelab is off until trflab
(see Roadmap).

## Commands

### Rebuild workflow

`NH_FLAKE` defaults to `github:tomrfitz/nix-config/main` —
rebuilds fetch from the remote, so every build corresponds to a pushed commit.
This enforces clean git discipline and triggers CI before any local build.

Each generation records the commit it was built from
(`system.configurationRevision`, set in `mkHost`):
`darwin-version --configuration-revision`
(NixOS: `nixos-version`) prints it, with `-dirty` marking a local `nrsl` build.
The SessionStart hook `.claude/hooks/session-state.sh` gives every agent session
that, plus the branch and its uncommitted and unpushed state.

nh derives the target host from macOS's `LocalHostName`,
which the OS silently renames on a network clash
(seen: `trfmbp-2` → `nh` fails with "Did you mean trfmbp?").
The justfile passes `-H` explicitly;
the permanent fix is `sudo scutil --set LocalHostName <host>`
(nix-darwin reasserts it on activation).

Switches need no paneru routine.
If clicks ever freeze all input after one
(a wedged event tap, seen once, 2026-09-03,
when paneru's agent moved from home-manager to nix-darwin),
run `launchctl bootout gui/$UID/com.github.karinushka.paneru` from a terminal,
which beats a forced restart,
then `paneru restart`. paneru now re-enables a disabled tap itself,
and the many unattended switches that changed it since haven't frozen.
Its logs are in `~/Library/Logs/paneru.err.log`.

Project templates: `nixify [default|python-uv|cpp]` runs
`nix flake init -t ~/nix-config#<name>` and then the tail nix cannot do (git
init, intent-to-add of the written files, `.envrc` fallback, `direnv allow`).
Templates carry the strict lint tier over the global floor.
See `templates/`.

- `nh darwin switch` — rebuild from remote
  (uses cached tarball; add `--refresh` to force re-fetch after a push)
- `nh darwin switch .` — local iteration escape hatch
  (dirty/uncommitted changes; flakeref is positional in nh 4.x)
- `nh darwin switch --refresh` — force re-fetch from remote
  (what `nrsr` runs); does **not** bump `flake.lock`
- `nh darwin switch --refresh --update` — force re-fetch + bump inputs

Personal `nr*` aliases (declared in `modules/shared/home/shell.nix`).
Commands the user runs from any directory are zsh aliases there;
`just` recipes are for repo-local work.

- `nrs` — switch from remote `NH_FLAKE` (daily-driver path)
- `nrsr` — switch with `--refresh` (force re-fetch the remote flake tarball)
- `nrsl` — switch from the local working tree (`~/nix-config`);
  use for dirty/iterative work.
  It lasts only until the next switch from remote `main`
  (`nrs`, or the 06:30 daemon), which puts `main`'s build back: push to keep it.
  Going back can downgrade stateful tools
  (atuin 18.19 refuses a database 18.21 migrated)
- `nrb` — build only (no activation)

On macOS a switch installs and removes Homebrew casks to match the Brewfile
but upgrades nothing, so the unattended 06:30 switch can finish
(some cask upgrades need sudo).
`nrs`, `nrsr` and `nrsl` then upgrade:
`brew bundle` against `/etc/homebrew/Brewfile`
(greedy, so self-updating casks too, except Microsoft's two)
(`modules/darwin/system/homebrew.nix`).
App Store apps install and upgrade at every activation through nix-darwin's
`programs.mas` (`mas.nix`).
A cask upgrade can quit its running app, and `.pkg` casks ask for Touch ID.

### Charge limiters

`fortis` uses BatFi (cask), which needs a GUI session.
A Mac that lists `modules/darwin/system/batt.nix` in `flake.nix`
(`lenis`, headless)
runs [batt](https://github.com/charlie0129/batt) instead,
and `homebrew.nix` drops BatFi there. batt is a Homebrew formula
(not in nixpkgs, checked 2026-11-10);
nix-darwin runs its daemon
(`org.nixos.batt`, log `/var/log/batt.log`)
in place of the formula's `sudo brew services start batt`.
Never start both.

- The limit is `settings.limit` in `batt.nix`.
  Every daemon start writes it over `/etc/batt.json`,
  so `batt limit N` and `batt disable --for=1d` last
  until the next start. batt's own default is 80%.
- A brew upgrade leaves the old daemon running until a restart
  or `sudo launchctl kickstart -k system/org.nixos.batt`.
- On a first switch launchd loads the daemon before brew installs batt;
  the start script polls for the binary
  (`wait4path` rechecks only when the mount table changes,
  so it never saw the install and the daemon hung on lenis, 2026-11-10).
- batt's docs say to turn off Optimized Battery Charging in System Settings.
- macOS 27 needs batt 0.9 or later,
  which sets the limit through macOS's own charge limit (upper limit only).
  0.8.0 starts, reports `Control mode: unsupported` and limits nothing.
  After a daemon start macOS takes about a minute to apply the target; above it,
  the Mac drains the battery to the target while plugged in.

### Headless Macs

`lenis` is always on and driven from `fortis`
(Rex, SSH, Screen Sharing), with its lid open and the display asleep.
It lists `modules/darwin/system/headless.nix`
and `modules/darwin/home/headless.nix` in `flake.nix`:

- It installs three casks
  (1Password, ChatGPT and Claude; `homebrew.casks` in `headless.nix`),
  no App Store apps, no window manager and none of `desktop.nix`
  (Zed, Zen, Ghostty, Zotero and its MCP server, GUI apps, fonts).
  FileVault is off and auto-login on,
  so whatever lenis holds is open to whoever holds lenis:
  an app comes back by being named there, when missed.
  `EDITOR` is `emacsclient -t`.
- It never sleeps and restarts after a freeze.
  `power.sleep.computer` runs `systemsetup`,
  which left the battery profile at one minute,
  so `headless.nix` also runs `pmset -a sleep 0`:
  lenis idle-slept during a power interruption and then stayed asleep on AC,
  surfacing only in background wakes, until something declared user activity
  (2026-11-11; `caffeinate -u -t 20` over SSH during one of those wakes gave the
  full wake, as a keypress would).
  Without AC it now runs until the battery is empty.
  This MacBook has no restart-after-power-failure setting
  (`pmset -g cap` lists no `autorestart`);
  an Apple silicon laptop starts when power is connected.
- sudo asks for the password in the terminal, with no Touch ID:
  from a shell inside the GUI session (Rex) the prompt waits on the locked
  screen for good and ignores SIGTERM (measured 2026-11-10; over plain SSH sudo
  fell back to the password by itself).
  Two commands need no password:
  `sudo launchctl kickstart system/org.nixos.auto-rebuild`
  (a switch from remote `main`, as at 06:30)
  and `sudo launchctl kickstart -k system/org.nixos.batt`.
- Tailscale is nixpkgs' `tailscaled` as a root daemon (`services.tailscale`),
  not the app, which
  [runs only after a login](https://tailscale.com/kb/1065/macos-variants).
  It can't use exit nodes and has no GUI;
  nix-darwin points `ts.net` lookups at MagicDNS (`/etc/resolver/ts.net`).
  Rex keeps its own tailnet node (`<host>-rex`), separate from both.
- GitHub and commit signing use lenis's own key, `~/.ssh/id_ed25519_lenis`
  (`modules/darwin/home/headless.nix`, listed in `flake.nix`):
  behind a locked screen 1Password's agent refuses to sign.
  Activation makes the key if it is missing, with no passphrase;
  it opens nothing until its public half is registered at GitHub,
  as an authentication key, a signing key or both,
  and deleting it there revokes it.
  No host accepts it, and every other ssh destination still goes through
  1Password, so it works only while lenis is unlocked.
  A standing forward of fortis's agent was built and dropped (2026-11-10):
  once approved, anything running
  as the user on lenis could have used fortis's main key until 1Password locked.
- It has `~/Documents/notes` through iCloud and `$NOTES`,
  but not the notes repo step or the `notes-sync` agent
  (`modules/darwin/home/headless.nix` turns both off):
  from the 06:30 daemon, git's first read under `~/Documents` waited on macOS's
  Documents-folder prompt and hung the switch for 13 hours (2026-11-11).
  Activation that runs unattended must stay out of `~/Documents`,
  `~/Desktop` and `~/Downloads`.
- A launchd agent sleeps the display at login (`lock-at-login`),
  which locks the screen:
  auto-login would otherwise leave the desktop open
  until the display slept by itself.
- Set by hand, since nix-darwin can't: auto-login, Screen Sharing,
  Rex as a login item, Optimized Battery Charging off, the lock delay
  ("immediately").
  In Tailscale's policy file `lenis`
  and Rex's node `lenis-rex` carry `tag:server`,
  and the only grant's source is `autogroup:member`:
  the user's devices reach them, and they can start nothing on the tailnet
  (checked 2026-11-10; `tailscale ping` still answers, real connections don't).

sshd takes keys only on every Mac (`security.nix`);
the key is the one in `flake.nix`, served from `/etc/ssh`.
Between the Macs Tailscale relays through DERP on eduroam,
which is too slow for Screen Sharing:
use `vnc://lenis.local` on the same network.
`.local` needs both Macs on one subnet:
across eduroam's subnets a connection opens and then carries no data
(ssh times out at the banner exchange, port 5900 stays silent;
seen 2026-11-10 with the firewall on and off).
The application firewall lets sshd through:
over the tailnet ssh reached both Macs with it on.

The `justfile` is the agents' command surface for checks; it has no switch,
rollback or lock-bump recipes.
`check` builds the local tree and passes `-H` (see the hostname note above):

```bash
just check         # nh darwin build . (local tree; build closure without activating, with diff)
just eval          # eval current host's system (catches eval errors without building)
just eval-all      # eval all configured hosts (fortis + lenis + trfnix + trfwsl)
just fmt           # nix fmt: format the tree in place (treefmt)
just fmt-check     # CI's sandboxed formatting check: read-only, sees tracked files only
just diff          # dix diff between previous and current system profile
just snapshot NAME # take macOS defaults snapshot; snapshot-diff BEFORE AFTER compares two
```

**Validation:** There are no tests.
Correctness = `just check` (build without activating) or `just eval` succeeding.
Use `just eval-all` to gate cross-platform changes.

**Important:** Nix flakes only see files tracked by git.
When adding new files referenced by the flake
(e.g., config files used in `home.file` or `source`),
you must `git add` them before `just eval` or `just check` will work.

## Architecture

### Flake structure

`flake.nix` defines a single host registry
(`hosts = { ... };`) plus a shared `mkHost` builder and `mkHM` helper.
Inputs: nixpkgs (unstable), nix-darwin, home-manager, nix-homebrew
(Homebrew itself, pinned),
emacs-overlay, paneru, zen-browser, nixos-wsl, sops-nix, treefmt-nix, git-hooks,
nix-index-database, rex, mattpocock-skills
(pi skills).
pi, noctalia and niri come from nixpkgs through home-manager and NixOS modules;
Claude Code is configured by home-manager everywhere,
but on macOS its binary comes from Anthropic's native installer
(nixpkgs on Linux) — see `modules/shared/home/claude-code.nix`.

### Hosts are thin wiring

`hosts/<machine>/default.nix` files only set machine facts
(hardware imports, hostname, boot/networking quirks) and import system modules.
All user/profile logic lives in `modules/`.

### Host contract

Keep host files concise, idiomatic, portable, and composable:

- **Hosts (`hosts/<name>/default.nix`)** define only machine facts.
- **OS system modules (`modules/{darwin,nixos}/system`)** define user/account
  shape and OS-wide services.
- **Home-manager modules (`modules/{shared,darwin,nixos}/home`)** define user
  environment and app/tooling behavior.
- **Use `hostName`, `isDarwin`, and `isWSL` from `specialArgs`**
  for conditional behavior instead of duplicating host-specific modules.

### Module organization

```text
modules/
  shared/          # Cross-platform (maximized — put everything here first)
    system/        # nix.nix, user.nix
    home/          # packages, shell, git, editors, emacs, ghostty, zen, browser-policies, obsidian, notes, desktop, claude-code, pi, dprint, xdg-*, etc.
  darwin/          # macOS-only
    system/        # homebrew.nix, settings.nix (system.defaults), security.nix, paneru.nix, batt.nix, headless.nix, auto-rebuild.nix
    home/          # zsh.nix, git.nix (1Password signing); per host in flake.nix: headless.nix
  nixos/           # Linux-only
    system/        # desktop.nix, hardening.nix, homelab/, auto-update.nix, remote-build-cache.nix, wsl-gpu.nix, tailscale, 1Password GUI, openssh; per host in flake.nix: rex.nix
    home/          # desktop.nix (niri + noctalia theming)
```

`default.nix` files are aggregators — mostly import lists.

### Common edit locations

- Add/remove nix packages: `modules/shared/home/packages.nix`
- Add/remove macOS casks: `modules/darwin/system/homebrew.nix`; App Store apps:
  `modules/darwin/system/mas.nix`; a headless Mac's own few casks:
  `modules/darwin/system/headless.nix`
- Change macOS system settings: `modules/darwin/system/settings.nix`
- Shell aliases/functions (cross-platform): `modules/shared/home/shell.nix`
- Shell aliases/functions (macOS-only): `modules/darwin/home/zsh.nix`
- Linux system services: `modules/nixos/system/default.nix`
- Homelab shared config: `modules/nixos/system/homelab/default.nix`
- Homelab per-service conventions: `modules/nixos/system/homelab/<service>.nix`
- Enable homelab services: the homelab host's file,
  via `trf.homelab` and `services.<name>.enable`
  (no host runs it since 2026-10-01;
  trfwsl's last declaration is `git show 76e9d16:hosts/trfwsl/default.nix`)
- WSL GPU / container runtime: `modules/nixos/system/wsl-gpu.nix`
- Rex server on a Linux host: `modules/nixos/system/rex.nix`,
  listed in the host's `extraModules` in `flake.nix`
- Linux desktop/session behavior: `modules/nixos/home/desktop.nix`
- Configure editors: Zed in `modules/shared/home/desktop.nix`,
  Helix in `modules/shared/home/editors.nix`,
  Emacs in `modules/shared/home/emacs.nix`
- Claude Code: settings in `config/claude-settings.json`,
  status line in `config/claude-statusline.sh`,
  wiring in `modules/shared/home/claude-code.nix`
- Other agent harnesses: pi in `modules/shared/home/pi.nix`
  (with `pi-resources/`),
  omp in `omp.nix`; the Anthropic API key pi and omp read
  (Max's monthly API credits; 1Password, never exported)
  in `anthropic-api-key.nix`
- Agent skills: for every project in `config/skills/`
  (linked into `~/.config/claude/skills/` by `claude-code.nix`,
  and as `~/.agents/skills`, which omp and pi read, by `default.nix`);
  for this repo only in `.claude/skills/`. omp's global instructions come from
  the same `config/agents.md` (`omp.nix`); its memory settings (Mnemopi,
  auto-retain off) live in its own `~/.omp/agent/config.yml`
- MCP servers: `programs.mcp`
  (Claude Code picks them up via `enableMcpIntegration`);
  the Zotero server, its CLI
  (both uvx-wrapped)
  and the Linux app in `modules/shared/home/zotero.nix`,
  which also merges the server into the Claude desktop app's config on darwin.
  Nothing else is declared:
  the `claude.ai <name>` servers are the account's connectors,
  added and removed at claude.ai
  (Customize → Connectors),
  and `syncClaudeAiPlugins` in `config/claude-settings.json` keeps the account's
  Cowork plugins and their MCP servers out of Claude Code
- Python global tooling (ruff floor, ty): `modules/shared/home/python.nix`;
  project tier: `templates/python-uv/pyproject.toml`
- C/C++ floor: `config/clang-format`, `config/clang-tidy`, `config/clangd.yaml`;
  project tier: `templates/cpp/`
- Universal formatter front
  (dprint, exec-wrapped CLIs, fence tag map): `modules/shared/home/dprint.nix`
- Browsers: Zen is primary (`modules/shared/home/zen.nix`);
  extension/policy manifest in `browser-policies.nix`
  (live on both platforms:
  on darwin home-manager writes the policies to macOS defaults,
  which the brew cask reads); Helium via cask; Orion via cask
  (the one extra, as a paying Kagi member);
  Safari native; Linux base Firefox in `modules/nixos/home/desktop.nix`.
- Git settings (shared): `modules/shared/home/git.nix`
- Git settings (1Password signing): `modules/darwin/home/git.nix`
- Fontconfig defaults: `modules/shared/home/fonts.nix`
- Noctalia theming / night light / launcher: `modules/nixos/home/desktop.nix`

### Key design rules

- **Maximize `modules/shared/`** —
  platform-specific modules only for genuine differences
  (e.g., 1Password SSH agent path, homebrew, macOS system.defaults)
- **Prefer native home-manager modules** (`programs.*`) over `home.file`
  when available
- **Package source priority:** nixpkgs shared → nixpkgs platform-specific →
  homebrew casks → Mac App Store (mas)
- **Brew-preferred exceptions:** 1Password, Ghostty (macOS app integration).
  **Vendor-installer exception:** the Claude Code CLI on macOS
  (Anthropic's native installer keeps it current alongside the desktop app's
  bundled copy, which shares the config directory); home-manager still owns its
  config via `package = null`, in `~/.config/claude` (`CLAUDE_CONFIG_DIR`, which
  launchd also hands to GUI apps).
  Emacs is nix-owned (emacs-overlay, nixpkgs emacs 31 on both platforms) —
  see `modules/shared/home/emacs.nix`
- **Language tooling belongs in project devShells**, not in the system config —
  only editor-universal tools
  (`nixd`, `nixfmt`, `shfmt`, `shellcheck`) stay global
- **Global floor vs project tier**: global lint configs
  (`programs.ruff`, `~/.clang-tidy`, the clangd user config)
  hold only rules you would accept in someone else's checkout;
  `templates/*` carry the strict tier and layer it with ruff `extend`,
  clang-tidy `InheritParentConfig`, and clangd's project-over-user merge.
  Formatters (`~/.clang-format`, `ruff format`) can be opinionated globally
  since they only run on files you format. ruff
  and ty are nix-owned globally (`modules/shared/home/python.nix`)
  so loose scripts get editor diagnostics;
  project devShells pin their own copies, which win on PATH
- **Zed uses `load_direnv = "shell_hook"`** to discover project-provided
  LSPs/formatters automatically
- **Zed settings go through home-manager**
  (`programs.zed-editor.userSettings` in `modules/shared/home/desktop.nix`),
  never the live `settings.json`: each switch merges the declared keys over it
- **Files an app rewrites stay out of home-manager's links**:
  once an app replaces a link with a file,
  every activation moves that file to `.hm-backup`,
  and a non-forced path fails activation when its content differs
  and an old backup exists.
  Disable the link (`home.file.<path>.enable = false`)
  and install a writable copy from activation when the content changes,
  as `zen.nix` does for `profiles.ini`
- **A few rarely-changing files from a larger upstream repo**:
  a pinned sparse `fetchFromGitHub` (`sparseCheckout`) or a pinned `fetchurl`
  (the Emacs icon), not a vendored copy or a whole-repo flake input.
  Bump by setting `hash = lib.fakeHash` and copying the hash nix reports

### Guardrails

- **Don't switch the system yourself** — no `nh … switch`,
  `darwin-/nixos-rebuild switch` or `nr*` aliases;
  activating mutates the live system
  (`.claude/hooks/block-rebuild.sh` enforces this for Claude Code)
- **Commit only when asked** — until then leave the working tree dirty;
  the user shapes commits in magit.
  When asked, run `/land`: topic commits built from hunks on `main`
  (no landing branch; amending unpushed commits is fine),
  each gated on its own staged tree,
  pushed once the tip is green and only if asked
- **Don't touch `flake.lock` unless asked** —
  the Update flake.lock workflow opens a bump PR twice a week;
  a requested bump is `nix flake update`, committed on its own
- **Inputs float** — every input tracks its upstream default branch
  and a bump moves all of them;
  adapt the config to upstream changes rather than pinning.
  A pin is a last resort and carries a `REVISIT(upstream)`.
  Wire each input the way its upstream documents,
  and drop it once nixpkgs or home-manager carries the same thing
- **Don't add packages to platform modules** without first checking
  if they work in `modules/shared/`
- **Don't create new top-level modules** without discussing placement —
  the structure is intentional
- **This repo is public** — keep personal details out of it: location,
  IP addresses, key fingerprints, school emails, health.
  They belong in the user's private notes
  (`~/Documents/notes/agent-context.org`)

### Upstream Revisit Notation

For temporary workarounds blocked on upstream changes,
use this marker in comments and TODOs:

- `REVISIT(upstream): <action when unblocked>; ref: <url-or-issue>; checked: <YYYY-MM-DD>`
- Keep one central checklist in `TODO.md` under an "Upstream Watchlist" section.
- When updating `flake.lock`,
  re-check all `REVISIT(upstream)` items before removing overrides/workarounds.

### Platform-conditional pattern

When a package needs different sources per platform,
use `pkgs.stdenv.hostPlatform.isDarwin` in a shared module rather than
duplicating across platform modules:

```nix
# package = null means "installed outside nix" (e.g., via brew cask on macOS)
package = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin null;
```

For packages that only exist on one platform, use `lib.optionals`:

```nix
home.packages = [ ... ] ++ lib.optionals (!pkgs.stdenv.hostPlatform.isDarwin) [ pkgs.element-desktop ];
```

### Secrets

Two mechanisms, split by trust model:

- **1Password** — user-space secrets where a human is present to unlock
  (SSH agent, vault-backed credentials, `op://` references).
  Used on all platforms.
- **sops-nix** — service-level secrets
  that must be available without user interaction
  (homelab API keys, tunnel tokens, VPN credentials).
  Age-encrypted in `secrets/`, decrypted to `/run/secrets/` at activation.
  Each host's age key is derived from its SSH host key;
  the admin key is a standalone age key
  (`~/.config/sops/age/keys.txt` on the Macs).
  Edit with `sops secrets/<host>.yaml`:
  sops-nix reads `/` in a key name as YAML nesting, so write nested maps,
  and quote every value (a number-like one, such as a Mullvad account number,
  otherwise parses as an integer).

### Rex

On the Macs the Rex Beta app, installed by hand,
runs the server and bundles the `rex` CLI; nix installs neither.
A Linux host that lists `modules/nixos/system/rex.nix` in `flake.nix` (`trfwsl`)
runs a personal server from Rex's own flake (input `rex`, the preview channel
the app follows): a systemd user service of the login user
(`journalctl --user -u rex`), kept across logouts by lingering, with a tailnet
node of its own, `<host>-rex`, as the app has on each Mac.

- Personal mode is what upstream recommends for a single-user machine
  ([server modes](https://www.superlogical.com/rex/docs/linux/server-modes)).
  The flake's NixOS module runs the other two,
  a shared server as a `rex` account and a root login server.
- The node is enrolled by hand, once per host:
  after the first switch `rex server status` prints a sign-in link,
  and the server keeps the login in its state directory.
  An untagged node admits only the account that enrolled it.
  A tagged one has no owner
  (`lenis-rex` carries `tag:server`),
  so it would also need `tailscale.allowTailnetMembers`.
- Clients add the host themselves:
  `rex hosts add <host> https://<host>-rex.<tailnet>.ts.net` for the CLI,
  and Add Remote Host… in the app, which doesn't read the CLI's list.
- A switch never restarts the server, which would end every session:
  after a lock bump moves Rex, `systemctl --user restart rex` picks it up.
- The module's home-manager half is imported on every host (`mkHM`).
  Its lingering warning prints at every eval of a host that runs the server;
  `users.users.<user>.linger` in `rex.nix` already answers it.

### Config files

`config/` holds files that modules deploy or import as-is: the Emacs config,
Helix themes (`lib.importTOML`), editorconfig, clang-format, clang-tidy,
clangd.yaml (deployed to `~/Library/Preferences/clangd/` on macOS,
since clangd ignores XDG there), karabiner.json,
the Zen userChrome/userContent CSS, the dprint plugin selector, the wallpaper.
`config/agents.md` is the global agent instructions file deployed to the agents'
home paths; `config/claude-settings.json` is Claude Code's settings,
`config/claude-statusline.sh` its status line, and `config/skills/` the skills
every project gets.

## Theming

- **Linux theming engine:** Noctalia — wallpaper-derived Material You colors,
  template-based app theming
  (GTK, Qt, foot, Ghostty, Emacs, Vesktop),
  auto dark/light scheduling, night light, app launcher
- **macOS theming:** native system appearance
  (Ghostty and Zed respond to system dark/light preference);
  Flexoki theme for Zed/Emacs
- **Fonts:** Sarasa Gothic SC orthography everywhere
  (since 2026-10-13):
  `Sarasa Fixed SC` (monospace; Iosevka Latin, no ligatures,
  CJK at exactly two cells) and `Sarasa UI SC` (sans; Inter Latin).
  One family covers Latin, Greek, Cyrillic, Hangul, kana and Han,
  so no CJK fallback fonts or fontsets.
  Fontconfig defaults in `modules/shared/home/fonts.nix`
- **Emacs:** Noctalia-generated theme on Linux, Flexoki fallback on macOS

## Custom packages

- **`pkgs/sgram-tui/`** — the only custom package
  (pinned to upstream's latest tag; not in nixpkgs).

## Bootstrap

Fresh machine setup (darwin or NixOS):

```bash
bash <(curl -L https://raw.githubusercontent.com/tomrfitz/nix-config/main/scripts/bootstrap.sh) <host>
```

Pass the flake host (`fortis` for a new Mac):
without it the script uses the machine's current name,
which on a fresh Mac is a default like `Toms-MacBook-Pro`.

The script handles: Xcode CLT (darwin), Nix installation
(nixos.org's script),
repo clone, first `darwin-rebuild`/`nixos-rebuild`
(which installs Homebrew through nix-homebrew on darwin),
and Claude Code's native installer (darwin).
The manual post-bootstrap steps are signing into 1Password and
(on darwin)
Apple ID, and opening Karabiner-Elements once:
the cask registers nothing until then,
and its settings window lists the approvals to grant
(background services, Accessibility, the driver extension).

## Roadmap

### Phase 1 — NixOS-WSL on gaming PC (`trfwsl`)

Interim homelab running NixOS-WSL on the existing Windows desktop.
The config ran Plex, full *arr stack, sabnzbd, tautulli, recyclarr, minecraft,
bookshelf, with Mullvad VPN + Tailscale coexistence, Cloudflare tunnel,
sops-nix secrets, and ollama, but those services never held data:
the live homelab is still Windows-native Plex
and \*arr on the PC's DrivePool (`K:\data\media`).

**The homelab is off on trfwsl since 2026-10-01**:
WSL 3.0's kernel can't host Mullvad's split tunneling
(the why is in `modules/nixos/system/homelab/vpn.nix`).
The modules stay ready for trflab;
trfwsl's last declaration is `git show 76e9d16:hosts/trfwsl/default.nix`. trfwsl
runs without the NixOS firewall: NixOS-WSL masks `firewall.service`, and
Windows' firewall fronts the WSL NAT.

**Done:** nixos-wsl input, host config, WSL module, homelab service modules,
media path config (NTFS mounts), Tailscale
(on eduroam it falls back to DERP relays over 443, which works),
Mullvad VPN with nftables split-tunnel, Cloudflare tunnel, sops-nix secrets,
the Windows `Start-NixOS-WSL` scheduled task
(boot trigger, runs whether or not anyone is logged on),
and an out-of-band path to trfwsl through the Windows host
(details in the user's private notes).

Open items: TODO.md § Homelab.

**Constraints:** WSL starts only through the Windows scheduled task,
networking is NAT'd by default
(use mirrored mode or Tailscale),
no direct disk/hardware access, Windows updates can kill WSL.
Acceptable for an interim setup.

### Phase 2 — Dedicated NixOS server (`trflab`)

Decided 2026-09-26: an i5-12400 box with direct-attached mergerfs + SnapRAID
storage, reusing the GTX 1070 for light ollama.
Parts, storage layout and steps: TODO.md § Phase 2; the plan of record
(prices, migration runbook)
is a Claude Doc linked from the user's private notes.
Tailscale carries over unchanged.

## Automation

### Auto-update pipeline

Lock bumps come from GitHub: a scheduled workflow opens a PR, CI checks it,
and a merge lands it on main.
Every host then follows main on its own schedule.

```text
Mon, Thu  CI: Update flake.lock opens/refreshes a bump PR; Check runs on it:
              check (eval + format) → darwin (build fortis's allowlisted
              uncached derivations on macos-latest, push to tomrfitz.cachix.org)
              → automerge (rebase-merge the tested commit onto main)
04:45  trfwsl: build trfwsl from main → push to Attic → switch trfwsl
06:30  trfnix: nixos-rebuild switch from remote main (when powered on; no
               Attic hits while the pipeline skips its build)
06:30  Macs:   nh darwin switch --refresh from remote main (local darwin build)
PRs + main CI: the same check → darwin (no automerge)
daily CI:      fail if flake.lock hasn't changed on main for 10 days (watchdog)
```

**Key files:**

- `.github/workflows/update-flake-lock.yml` — the bump PR
  (DeterminateSystems' action),
  opened as the `tomrfitz-lock-bump` GitHub App
  (variable `LOCK_BUMP_CLIENT_ID`, secret `LOCK_BUMP_PRIVATE_KEY`;
  contents and pull requests read/write, installed on this repo only).
  A PR opened with `GITHUB_TOKEN` would hold its runs
  until someone with write access clicked "Approve and run"
  (GitHub's rule for github-actions[bot] since 2026-06;
  the repo's first-time-contributor setting covers only forks)
- `.github/workflows/check.yml` + `scripts/build-uncached.sh` — the checks,
  the Cachix build (secret `CACHIX`, the cache's auth token;
  a cold run takes ~20 min) and the bump PR's merge.
  Only allowlisted, free derivations get built:
  unfree vendor repackages must stay out of a public cache,
  and caching a download saves the Mac nothing.
  A merge made with `GITHUB_TOKEN` starts no push run on main,
  which the PR's run already covered
- `scripts/auto-update.sh` — trfwsl's pipeline
  (phases 0–4; it no longer bumps or pushes,
  so its deploy key needs only read access)
- `modules/nixos/system/auto-update.nix` — systemd services/timers + msmtp
- `modules/darwin/system/auto-rebuild.nix` — root launchd daemon on each Mac
  (unattended; user sudo is Touch ID-only).
  Log: `/var/log/auto-rebuild.log`.
  It fires at 06:30 Mac-local time,
  or on the next wake if the Mac slept through it
  (a run lost to a shutdown is not retried;
  a run on an unchanged `main` makes no new generation).
  It has no Full Disk Access,
  so only interactive switches write the sandboxed apps' preferences
  (Safari, Mail; `settings.nix`), and the daemon logs a warning instead

**Manual trigger:** `sudo systemctl start auto-update` on trfwsl

**Check status:** `systemctl status auto-update.timer` /
`journalctl -u auto-update`;
`journalctl -u auto-update -o short-iso | grep '==>'` shows how far each run
got.
On the Mac, `/var/log/auto-rebuild.log` has ANSI codes
(`sed 's/\x1b\[[0-9;]*m//g'`),
and `launchctl print system/org.nixos.auto-rebuild` counts runs since boot only.

**Diagnose a build failure from the Mac:**
`nix eval --raw --no-write-lock-file --override-input nixpkgs github:NixOS/nixpkgs/<rev> .#nixosConfigurations.trfwsl.config.system.build.toplevel.drvPath`,
then `nix-store -q --requisites <drv> | rg <name>`;
`nix path-info --store <cache-url> <outpath>` tells whether a cache has it.

**Failure notification:** email to `tomrfitz@gmail.com` via msmtp/Gmail relay
(sops secret `mail/app-pass`).
It needs trfwsl's network, which most failed runs lacked.
The lock itself is watched from GitHub's side:
`.github/workflows/auto-update-watchdog.yml` fails,
and GitHub mails whoever last edited its cron line,
once `flake.lock` has gone 10 days without changing on main
(the bump workflow failing, or its PRs left unmerged);
the SessionStart hook reports the same gap.
While the pipeline is off on purpose,
`gh workflow disable auto-update-watchdog.yml`
(re-enabling routes its mail to whoever re-enables it).

### Naming convention

New hosts take phonetic-feature adjectives, without the old `trf` prefix:
an uncommon word already avoids eduroam's colliding default names.
Every machine keeps its name for life: `fortis` is the M5 and `lenis` the M1,
and a later Mac gets a new name under whatever scheme is chosen then.
The other machines take trait names
(draft assignments and the unused pool are in the user's private notes);
`trfnix` and `trfwsl` keep their names until they're renamed.

### Future machines

- **`trflab`** — dedicated homelab server (phase 2)
- **`trfvm`** — scratch/sandbox NixOS VM
  (host TBD — could be local on Mac via UTM, or on the gaming PC via Hyper-V)
- **`trfnix`** may be retired when the Samsung laptop is repurposed or replaced
