# nix-config task runner

flake := "~/nix-config"

# Apply the current configuration
rebuild:
    nh darwin switch {{ flake }}

# Build the system closure without activating
check:
    nh darwin build {{ flake }}

# Rollback to the previous generation
rollback:
    sudo darwin-rebuild switch --rollback

# Update flake inputs and rebuild
update:
    nh darwin switch --update {{ flake }}

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
    dix $(ls -d1 /nix/var/nix/profiles/system-*-link | tail -2 | head -1) /run/current-system

# Re-encrypt all secrets for the current set of recipients
rekey:
    cd secrets && agenix --rekey
