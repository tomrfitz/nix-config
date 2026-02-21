# nix-config task runner

flake := "~/nix-config"
host := `hostname`
nh_cmd := if host == "trfmbp" { "darwin" } else { "os" }

# Apply the current configuration
rebuild:
    nh {{ nh_cmd }} switch {{ flake }}

# Build the system closure without activating
check:
    nh {{ nh_cmd }} build {{ flake }}

# Rollback to the previous generation
[linux]
rollback:
    sudo nixos-rebuild switch --rollback

[macos]
rollback:
    sudo darwin-rebuild switch --rollback

# Update flake inputs and rebuild
update:
    nh {{ nh_cmd }} switch --update {{ flake }}

# Format all files (nix, toml, shell, json, md, yaml, justfile)
fmt:
    nix fmt

# Check formatting without modifying
fmt-check:
    nix fmt -- --ci

# Evaluate config (catches syntax/eval errors without building)
[macos]
eval:
    nix eval .#darwinConfigurations.trfmbp.system --raw

[linux]
eval:
    nix eval .#nixosConfigurations.{{ host }}.config.system.build.toplevel --raw

# Take a macOS defaults snapshot
[macos]
snapshot name:
    nix develop --command ./scripts/snapshot-defaults.sh snapshot {{ name }}

# Diff two macOS defaults snapshots
[macos]
snapshot-diff before after:
    ./scripts/snapshot-defaults.sh diff {{ before }} {{ after }}

# Show what packages changed between current and previous generation
diff:
    dix $(ls -d1 /nix/var/nix/profiles/system-*-link | tail -2 | head -1) /run/current-system

# Switch to base (default) system configuration
[linux]
spec-base:
    sudo /run/current-system/bin/switch-to-configuration switch

# Switch to Plasma specialisation
[linux]
spec-plasma:
    sudo /run/current-system/specialisation/plasma/bin/switch-to-configuration switch

# Switch to Sway specialisation
[linux]
spec-sway:
    sudo /run/current-system/specialisation/sway/bin/switch-to-configuration switch
