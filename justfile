# nix-config task runner for repo-local work: checks, formatting, snapshots.
# Switches, rollbacks and lock bumps belong to the user (the nr* aliases in
# modules/shared/home/shell.nix).

host := `hostname`
nh_cmd := if host == "trfmbp" { "darwin" } else { "os" }
system := if host == "trfmbp" { "aarch64-darwin" } else { "x86_64-linux" }

# nh derives the target from macOS's LocalHostName, which the OS silently
# renames on a network clash (seen: trfmbp-2) — pass the flake host explicitly.
nh_host := "-H " + host

# Build the system closure without activating (local working tree, keep-going)
check:
    nh {{ nh_cmd }} build . {{ nh_host }} --keep-going

# Format all files (nix, toml, shell, json, md, yaml, justfile)
fmt:
    nix fmt

# CI's sandboxed check: it sees only tracked files, and unlike `nix fmt -- --ci`
# (which formats in place, then fails) it changes nothing.
# Check formatting without modifying
fmt-check:
    nix build --no-link .#checks.{{ system }}.formatting

# Evaluate config (catches syntax/eval errors without building)
[macos]
eval:
    nix eval .#darwinConfigurations.trfmbp.system --raw

[linux]
eval:
    nix eval .#nixosConfigurations.{{ host }}.config.system.build.toplevel --raw

# Evaluate all flake hosts (darwin + nixos + nixos-wsl)
eval-all:
    nix eval .#darwinConfigurations.trfmbp.system --raw
    nix eval .#nixosConfigurations.trfnix.config.system.build.toplevel.drvPath --raw
    nix eval .#nixosConfigurations.trfwsl.config.system.build.toplevel.drvPath --raw

# Regenerate trfnix facter report
[linux]
facter-trfnix:
    sudo nix run nixpkgs#nixos-facter -- -o hosts/trfnix/facter.json

# Take a macOS defaults snapshot
[macos]
snapshot name:
    ./scripts/snapshot-defaults.sh snapshot {{ name }}

# Diff two macOS defaults snapshots
[macos]
snapshot-diff before after:
    ./scripts/snapshot-defaults.sh diff {{ before }} {{ after }}

# Show what packages changed between current and previous generation
diff:
    dix $(ls -d1 /nix/var/nix/profiles/system-*-link | tail -2 | head -1) /run/current-system
