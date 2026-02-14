# nix-config task runner

flake := "~/nix-config"

# Apply the current configuration
rebuild:
    sudo darwin-rebuild switch

# Build the system closure without activating
check:
    darwin-rebuild build

# Rollback to the previous generation
rollback:
    sudo darwin-rebuild switch --rollback

# Snapshot current system generation (for nvd diff later)
_snapshot-gen:
    readlink -f /run/current-system > /tmp/.nix-pre-update-system

# Update flake inputs and rebuild
update:
    nix flake update --flake {{ flake }}
    sudo darwin-rebuild switch

# Show what changed since the last _snapshot-gen
nvd:
    nvd diff $(cat /tmp/.nix-pre-update-system) /run/current-system
    rm -f /tmp/.nix-pre-update-system

# Update + diff in one shot (for standalone use)
upgrade: _snapshot-gen update nvd

# Format all files (nix, toml, shell, json, md, yaml, justfile)
fmt:
    nix fmt

# Check formatting without modifying
fmt-check:
    nix fmt -- --ci

# Evaluate darwin config (catches syntax/eval errors without building)
eval:
    nix eval .#darwinConfigurations.trfmbp.system --raw

# Take a macOS defaults snapshot
snapshot name:
    nix develop --command ./scripts/snapshot-defaults.sh snapshot {{ name }}

# Diff two macOS defaults snapshots
snapshot-diff before after:
    ./scripts/snapshot-defaults.sh diff {{ before }} {{ after }}

# Show what packages changed between current and previous generation
diff:
    nvd diff $(ls -d1 /nix/var/nix/profiles/system-*-link | tail -2 | head -1) /run/current-system
