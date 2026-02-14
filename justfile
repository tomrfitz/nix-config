# nix-config task runner

flake := "~/nix-config"

# Apply the current configuration
rebuild:
    sudo darwin-rebuild switch

# Dry-run to check for errors without applying
check:
    sudo darwin-rebuild switch --dry-run

# Rollback to the previous generation
rollback:
    sudo darwin-rebuild switch --rollback

# Update flake inputs and rebuild
update:
    readlink -f /run/current-system > /tmp/.nix-pre-update-system
    nix flake update --flake {{flake}}
    sudo darwin-rebuild switch
    nvd diff $(cat /tmp/.nix-pre-update-system) /run/current-system
    rm -f /tmp/.nix-pre-update-system

# Format all files (nix, toml, shell, json, md, yaml, justfile)
fmt:
    nix fmt

# Check formatting without modifying
fmt-check:
    nix fmt -- --ci

# Evaluate the flake (catches syntax/eval errors without building)
eval:
    nix flake check

# Take a macOS defaults snapshot
snapshot name:
    nix develop --command ./scripts/snapshot-defaults.sh snapshot {{name}}

# Diff two macOS defaults snapshots
snapshot-diff before after:
    ./scripts/snapshot-defaults.sh diff {{before}} {{after}}

# Show what packages changed between current and previous generation
diff:
    nvd diff $(ls -d1 /nix/var/nix/profiles/system-*-link | tail -2 | head -1) /run/current-system
