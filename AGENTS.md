# AGENTS.md

Repo-specific guidance for AI agents working on this nix-config. See also `~/.config/AGENTS.md` for global, project-agnostic conventions.

## What This Is

A Nix flake managing macOS (nix-darwin) and NixOS systems with home-manager. Tracks on nixpkgs-unstable. Uses Lix as the nix runtime across all hosts.

### Machines

| Hostname | Platform | Role | Status |
| -------- | ---------------- | ---------------------------------------- | ------ |
| `trfmbp` | aarch64-darwin | Daily driver (M1 Pro MacBook Pro) | Active |
| `trfnix` | x86_64-linux | NixOS testbed (Samsung laptop) | Active |
| `trfwsl` | x86_64-linux WSL | Interim homelab on gaming PC, later dev | Active |
| `trflab` | x86_64-linux | Dedicated homelab server | Future |
| `trfvm` | TBD | Scratch/sandbox VM | Future |

The primary config target is `trfmbp`. `trfnix` is a real NixOS install useful for prototyping NixOS service configs. `trfwsl` runs the homelab stack via NixOS-WSL (see Roadmap for remaining work).

## Commands

### Rebuild workflow

`NH_FLAKE` defaults to `github:tomrfitz/nix-config/main` — rebuilds fetch from the remote, so every build corresponds to a pushed commit. This enforces clean git discipline and triggers CI before any local build.

nh derives the target host from macOS's `LocalHostName`, which the OS silently renames on a network clash (seen: `trfmbp-2` → `nh` fails with "Did you mean trfmbp?"). The justfile passes `-H` explicitly; the permanent fix is `sudo scutil --set LocalHostName trfmbp` (nix-darwin reasserts it on activation).

A switch that changes paneru or uninstalls many apps can wedge paneru's event tap (every click freezes input until a forced restart — seen 2026-09-03): quit paneru before switching and run `paneru restart` after. Its logs are in `~/Library/Logs/paneru.err.log`.

Project templates: `nixify [default|python-uv|cpp]` runs `nix flake init -t ~/nix-config#<name>` and then the tail nix cannot do (git init, intent-to-add of the written files, `.envrc` fallback, `direnv allow`). Templates carry the strict lint tier over the global floor. See `templates/`.

- `nh darwin switch` — rebuild from remote (uses cached tarball; add `--refresh` to force re-fetch after a push)
- `nh darwin switch .` — local iteration escape hatch (dirty/uncommitted changes; flakeref is positional in nh 4.x)
- `nh darwin switch --refresh` — force re-fetch from remote (what `nrsr` runs); does **not** bump `flake.lock`
- `nh darwin switch --refresh --update` — force re-fetch + bump inputs (what `just update` runs)

Personal `nr*` aliases (declared in `modules/shared/home/shell.nix`):

- `nrs` — switch from remote `NH_FLAKE` (daily-driver path)
- `nrsr` — switch with `--refresh` (force re-fetch the remote flake tarball)
- `nrsl` — switch from the local working tree (`~/nix-config`); use for dirty/iterative work. It lasts only until the next switch from remote `main` (`nrs`, or the 06:30 daemon), which puts `main`'s build back: push to keep it
- `nrb` — build only (no activation)

On macOS every switch also updates Homebrew and upgrades every managed cask (greedy, so self-updating ones too) and App Store app (`modules/darwin/system/homebrew.nix`). A cask upgrade can quit its running app, and `.pkg` casks ask for Touch ID.

The `justfile` defers to `NH_FLAKE` for switches; `check` builds the local tree and every nh recipe passes `-H` (see the hostname note above):

```bash
just rebuild       # nh darwin switch
just check         # nh darwin build . (local tree; build closure without activating, with diff)
just update        # nh darwin switch --update (flake update + rebuild)
just fmt           # nix fmt (nixfmt)
just fmt-check     # check formatting without modifying
just eval          # eval current host's system (catches eval errors without building)
just eval-all      # eval all configured hosts (trfmbp + trfnix + trfwsl)
just rollback      # switch to previous generation
just diff          # dix diff between previous and current system profile
just snapshot NAME # take macOS defaults snapshot; snapshot-diff BEFORE AFTER compares two
just clean         # nh clean all (old generations + unreferenced store paths)
just sops-edit     # edit secrets/trfwsl.yaml (HOST=... for another host)
```

**Validation:** There are no tests. Correctness = `just check` (build without activating) or `just eval` succeeding. Use `just eval-all` to gate cross-platform changes.

**Important:** Nix flakes only see files tracked by git. When adding new files referenced by the flake (e.g., config files used in `home.file` or `source`), you must `git add` them before `just eval` or `just check` will work.

## Architecture

### Flake structure

`flake.nix` defines a single host registry (`hosts = { ... };`) plus a shared `mkHost` builder and `mkHM` helper. Inputs: nixpkgs (unstable), nix-darwin, home-manager, emacs-overlay, paneru, zen-browser, nixos-wsl, sops-nix, treefmt-nix, git-hooks, nix-index-database, mattpocock-skills (pi skills), hermes-agent (on trial on the Mac, with its own nixpkgs). pi, noctalia and niri come from nixpkgs through home-manager and NixOS modules; Claude Code is configured by home-manager everywhere, but on macOS its binary comes from Anthropic's native installer (nixpkgs on Linux) — see `modules/shared/home/claude-code.nix`.

### Hosts are thin wiring

`hosts/<machine>/default.nix` files only set machine facts (hardware imports, hostname, boot/networking quirks) and import system modules. All user/profile logic lives in `modules/`.

### Host contract

Keep host files concise, idiomatic, portable, and composable:

- **Hosts (`hosts/<name>/default.nix`)** define only machine facts.
- **OS system modules (`modules/{darwin,nixos}/system`)** define user/account shape and OS-wide services.
- **Home-manager modules (`modules/{shared,darwin,nixos}/home`)** define user environment and app/tooling behavior.
- **Use `hostName`, `isDarwin`, and `isWSL` from `specialArgs`** for conditional behavior instead of duplicating host-specific modules.

### Module organization

```text
modules/
  shared/          # Cross-platform (maximized — put everything here first)
    system/        # nix.nix, user.nix
    home/          # packages, shell, git, editors, emacs, ghostty, zen, browser-policies, obsidian, notes, desktop, claude-code, pi, dprint, xdg-*, etc.
  darwin/          # macOS-only
    system/        # homebrew.nix, settings.nix (system.defaults), security.nix, paneru.nix, auto-rebuild.nix
    home/          # zsh.nix, git.nix (1Password signing)
  nixos/           # Linux-only
    system/        # desktop.nix, hardening.nix, homelab/, auto-update.nix, remote-build-cache.nix, wsl-gpu.nix, tailscale, 1Password GUI, openssh
    home/          # desktop.nix (niri + noctalia theming)
```

`default.nix` files are aggregators — mostly import lists.

### Common edit locations

- Add/remove nix packages: `modules/shared/home/packages.nix`
- Add/remove macOS casks: `modules/darwin/system/homebrew.nix`
- Change macOS system settings: `modules/darwin/system/settings.nix`
- Shell aliases/functions (cross-platform): `modules/shared/home/shell.nix`
- Shell aliases/functions (macOS-only): `modules/darwin/home/zsh.nix`
- Linux system services: `modules/nixos/system/default.nix`
- Homelab shared config: `modules/nixos/system/homelab/default.nix`
- Homelab per-service conventions: `modules/nixos/system/homelab/<service>.nix`
- Enable homelab services: `hosts/trfwsl/default.nix` (via `services.<name>.enable`)
- WSL GPU / container runtime: `modules/nixos/system/wsl-gpu.nix`
- Linux desktop/session behavior: `modules/nixos/home/desktop.nix`
- Configure editors: Zed in `modules/shared/home/desktop.nix`, Helix in `modules/shared/home/editors.nix`, Emacs in `modules/shared/home/emacs.nix`
- Claude Code: settings in `config/claude-settings.json`, wiring in `modules/shared/home/claude-code.nix`
- Python global tooling (ruff floor, ty): `modules/shared/home/python.nix`; project tier: `templates/python-uv/pyproject.toml`
- C/C++ floor: `config/clang-format`, `config/clang-tidy`, `config/clangd.yaml`; project tier: `templates/cpp/`
- Universal formatter front (dprint, exec-wrapped CLIs, fence tag map): `modules/shared/home/dprint.nix`
- Browsers: Zen is primary (`modules/shared/home/zen.nix`); extension/policy manifest in `browser-policies.nix` (live on both platforms: on darwin home-manager writes the policies to macOS defaults, which the brew cask reads); Helium via cask; Orion via cask (the one extra, as a paying Kagi member); Safari native; Linux base Firefox in `modules/nixos/home/desktop.nix`.
- Git settings (shared): `modules/shared/home/git.nix`
- Git settings (1Password signing): `modules/darwin/home/git.nix`
- Fontconfig defaults: `modules/shared/home/fonts.nix`
- Noctalia theming / night light / launcher: `modules/nixos/home/desktop.nix`

### Key design rules

- **Maximize `modules/shared/`** — platform-specific modules only for genuine differences (e.g., 1Password SSH agent path, homebrew, macOS system.defaults)
- **Prefer native home-manager modules** (`programs.*`) over `home.file` when available
- **Package source priority:** nixpkgs shared → nixpkgs platform-specific → homebrew casks → Mac App Store (mas)
- **Brew-preferred exceptions:** 1Password, Ghostty (macOS app integration). **Vendor-installer exception:** the Claude Code CLI on macOS (Anthropic's native installer keeps it current alongside the desktop app's bundled copy, which shares `~/.claude`); home-manager still owns its config via `package = null`. Emacs is nix-owned (emacs-overlay, nixpkgs emacs 31 on both platforms) — see `modules/shared/home/emacs.nix`
- **Language tooling belongs in project devShells**, not in the system config — only editor-universal tools (`nixd`, `nixfmt`, `shfmt`, `shellcheck`) stay global
- **Global floor vs project tier**: global lint configs (`programs.ruff`, `~/.clang-tidy`, the clangd user config) hold only rules you would accept in someone else's checkout; `templates/*` carry the strict tier and layer it with ruff `extend`, clang-tidy `InheritParentConfig`, and clangd's project-over-user merge. Formatters (`~/.clang-format`, `ruff format`) can be opinionated globally since they only run on files you format. ruff and ty are nix-owned globally (`modules/shared/home/python.nix`) so loose scripts get editor diagnostics; project devShells pin their own copies, which win on PATH
- **Zed uses `load_direnv = "shell_hook"`** to discover project-provided LSPs/formatters automatically

### Guardrails

- **Don't run rebuilds yourself** — neither `just rebuild` nor the personal `nr*` aliases; applying mutates the live system
- **Don't commit during exploratory work** — leave the working tree dirty so commits can be shaped in magit (trim/atomize) after the apply
- **Don't modify `flake.lock`** directly — that's `just update`'s job
- **Inputs float** — every input tracks its upstream default branch and a bump moves all of them; adapt the config to upstream changes rather than pinning. A pin is a last resort and carries a `REVISIT(upstream)`
- **Don't add packages to platform modules** without first checking if they work in `modules/shared/`
- **Don't create new top-level modules** without discussing placement — the structure is intentional

### Upstream Revisit Notation

For temporary workarounds blocked on upstream changes, use this marker in comments and TODOs:

- `REVISIT(upstream): <action when unblocked>; ref: <url-or-issue>; checked: <YYYY-MM-DD>`
- Keep one central checklist in `TODO.md` under an "Upstream Watchlist" section.
- When updating `flake.lock`, re-check all `REVISIT(upstream)` items before removing overrides/workarounds.

### Platform-conditional pattern

When a package needs different sources per platform, use `pkgs.stdenv.hostPlatform.isDarwin` in a shared module rather than duplicating across platform modules:

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

- **1Password** — user-space secrets where a human is present to unlock (SSH agent, vault-backed credentials, `op://` references). Used on all platforms.
- **sops-nix** — service-level secrets that must be available without user interaction (homelab API keys, tunnel tokens, VPN credentials). Age-encrypted in `secrets/`, decrypted to `/run/secrets/` at activation. Each host's age key is derived from its SSH host key; the admin key is a standalone age key (`~/.config/sops/age/keys.txt` on trfmbp).

### Config files

`config/` holds files that modules deploy or import as-is: the Emacs config, Helix themes (`lib.importTOML`), editorconfig, clang-format, clang-tidy, clangd.yaml (deployed to `~/Library/Preferences/clangd/` on macOS, since clangd ignores XDG there), karabiner.json, the Zen userChrome/userContent CSS, the dprint plugin selector, the wallpaper. `config/agents.md` is the global agent instructions file deployed to the agents' home paths; `config/claude-settings.json` is Claude Code's settings.

## Theming

- **Linux theming engine:** Noctalia — wallpaper-derived Material You colors, template-based app theming (GTK, Qt, foot, Ghostty, Emacs, Vesktop), auto dark/light scheduling, night light, app launcher
- **macOS theming:** native system appearance (Ghostty and Zed respond to system dark/light preference); Flexoki theme for Zed/Emacs
- **Fonts:** Atkinson Hyperlegible Next (sans), Atkinson Hyperlegible Mono (monospace), fontconfig defaults in `modules/shared/home/fonts.nix`
- **Emacs:** Noctalia-generated theme on Linux, Flexoki fallback on macOS

## Custom packages

- **`pkgs/sgram-tui/`** — the only custom package (pinned to upstream's latest tag; not in nixpkgs).

## Bootstrap

Fresh machine setup (darwin or NixOS):

```bash
bash <(curl -L https://raw.githubusercontent.com/tomrfitz/nix-config/main/scripts/bootstrap.sh)
```

The script handles: Xcode CLT (darwin), Lix installation, repo clone, first `darwin-rebuild`/`nixos-rebuild`, and Claude Code's native installer (darwin). The manual post-bootstrap steps are signing into 1Password and (on darwin) Apple ID.

## Roadmap

### Phase 1 — NixOS-WSL on gaming PC (`trfwsl`)

Interim homelab running NixOS-WSL on the existing Windows desktop. Config is largely complete — host runs Plex, full *arr stack, sabnzbd, tautulli, recyclarr, minecraft, bookshelf, with Mullvad VPN + Tailscale coexistence, Cloudflare tunnel, sops-nix secrets, and ollama.

**Done:** nixos-wsl input, host config, WSL module, homelab service modules, media path config (NTFS mounts), Tailscale, Mullvad VPN with nftables split-tunnel, Cloudflare tunnel, sops-nix secrets.

**Remaining:**

1. Windows-side: scheduled task to auto-start WSL, `.wslconfig` for mirrored networking (the daily flake.lock pipeline only runs while the PC is on — it has been silent since 2026-06-08)
2. Test Tailscale on eduroam (DERP relay fallback over 443)

**Constraints:** WSL doesn't auto-start with Windows, networking is NAT'd by default (use mirrored mode or Tailscale), no direct disk/hardware access, Windows updates can kill WSL. Acceptable for an interim setup.

### Phase 2 — Dedicated NixOS server (`trflab`)

**Hardware:** i5-12400 (6C/12T, 65W, Quick Sync) + B660M DDR4 mATX + 32GB DDR4. Reuses existing Fractal Focus G Mini case, Noctua NH-U9S cooler (LGA 1700 kit), EVGA 550 G2 PSU, GTX 1070 (ollama), and existing drives (512GB NVMe boot, 2TB HDD media, 240GB SSD scratch). Quick Sync handles Plex transcode; 1070 is for light ollama (7-8B models), not video.

**Storage:** Direct-attached (no NAS). ZFS pool on new drive(s), ext4 or btrfs boot. DrivePool drives (NTFS, ~8TB, 95% full) migrate by rsyncing to the new ZFS pool — DrivePool is file-level pooling (not striped), so each drive is independently readable NTFS. Old drives then join the ZFS pool or become backup targets. NAS is a future consideration only if multiple machines need shared storage.

1. Build `trflab`, add host to flake (swap WSL module for hardware config)
2. Create ZFS pool on new drive(s), rsync media from DrivePool
3. Migrate services from `trfwsl` (see TODO.md migration plan)
4. Auto-rebuild via systemd timer
5. Demote `trfwsl` to lightweight dev environment on gaming PC
6. Tailscale carries over unchanged

## Automation

### Auto-update pipeline

`trfwsl` runs a daily pipeline that updates flake.lock, builds x86 closures, caches to Attic, and pushes to main. Other hosts rebuild on schedule.

```text
04:45  trfwsl: update flake.lock → eval all 3 hosts → build trfwsl + trfnix
               → push to Attic → switch trfwsl → commit + push flake.lock to main
06:30  trfnix: nixos-rebuild switch from remote main (Attic cache hits)
06:30  trfmbp: nh darwin switch --refresh from remote main (local darwin build)
on-push CI:    eval all 3 hosts + formatting check (safety net)
```

**Key files:**

- `scripts/auto-update.sh` — pipeline logic (phases 0–7)
- `modules/nixos/system/auto-update.nix` — systemd services/timers + msmtp
- `modules/darwin/system/auto-rebuild.nix` — root launchd daemon for trfmbp (unattended; user sudo is Touch ID-only). Log: `/var/log/auto-rebuild.log`. It fires at 06:30 Mac-local time, or on the next wake if the Mac slept through it. It has no Full Disk Access, so only interactive switches write the sandboxed apps' preferences (Safari, Mail; `settings.nix`), and the daemon logs a warning instead

**Manual trigger:** `sudo systemctl start auto-update` on trfwsl

**Check status:** `systemctl status auto-update.timer` / `journalctl -u auto-update`

**Failure notification:** email to `tomrfitz@gmail.com` via msmtp/Gmail relay (sops secret `mail/app-pass`)

### Naming convention

Hostnames follow `trf<identifier>` — initials prefix for network disambiguation (eduroam has many colliding default Apple/Windows names), short suffix for the device/role. Under 7 chars, unique prefixes for tab completion.

### Future machines

- **`trflab`** — dedicated homelab server (phase 2)
- **`trfvm`** — scratch/sandbox NixOS VM (host TBD — could be local on Mac via UTM, or on the gaming PC via Hyper-V)
- **`trfnix`** may be retired when the Samsung laptop is repurposed or replaced
