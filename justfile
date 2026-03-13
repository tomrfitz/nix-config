# nix-config task runner

host := `hostname`
nh_cmd := if host == "trfmbp" { "darwin" } else { "os" }
system := if host == "trfmbp" { "aarch64-darwin" } else { "x86_64-linux" }

# Apply the current configuration
rebuild:
    nh {{ nh_cmd }} switch

# Build the system closure without activating
check:
    nh {{ nh_cmd }} build

# Rollback to the previous generation
[linux]
rollback:
    sudo nixos-rebuild switch --rollback

[macos]
rollback:
    sudo darwin-rebuild switch --rollback

# Update flake inputs and rebuild
update:
    nh {{ nh_cmd }} switch --update

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

# Evaluate all flake hosts (darwin + nixos + nixos-wsl)
eval-all:
    nix eval .#darwinConfigurations.trfmbp.system --raw
    nix eval .#nixosConfigurations.trfnix.config.system.build.toplevel.drvPath --raw
    nix eval .#nixosConfigurations.trfwsl.config.system.build.toplevel.drvPath --raw

# Build rendered topology diagrams for the current architecture
topology:
    nix build path:.#topology.{{ system }}.config.output

# Build the generated disko script for trfnix
[linux]
disko-trfnix-script:
    nix build path:.#nixosConfigurations.trfnix.config.system.build.diskoScript

# Dry-run disko for trfnix (prints script path, does not execute)
[linux]
disko-trfnix-dry-run:
    nix run github:nix-community/disko -- --mode destroy,format,mount --dry-run --flake path:.#trfnix

# Regenerate trfnix facter report
[linux]
facter-trfnix:
    sudo nix run nixpkgs#nixos-facter -- -o hosts/trfnix/facter.json

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

# List available system specialisations in the currently booted generation
[linux]
spec-list:
    ls -1 /run/current-system/specialisation

# Switch to base (default) system configuration
[linux]
spec-base:
    sudo /run/current-system/bin/switch-to-configuration switch

# Switch to Plasma specialisation
[linux]
spec-plasma:
    @path="/run/current-system/specialisation/plasma/bin/switch-to-configuration"; \
      if [ ! -x "$path" ]; then \
        echo "Plasma specialisation not found in current generation."; \
        echo "Run 'just rebuild' first, then retry."; \
        echo "Available specialisations:"; \
        ls -1 /run/current-system/specialisation 2>/dev/null || echo "(none)"; \
        exit 1; \
      fi; \
      sudo "$path" switch

# Switch to Sway specialisation
[linux]
spec-sway:
    @path="/run/current-system/specialisation/sway/bin/switch-to-configuration"; \
      if [ ! -x "$path" ]; then \
        echo "Sway specialisation not found in current generation."; \
        echo "Run 'just rebuild' first, then retry."; \
        echo "Available specialisations:"; \
        ls -1 /run/current-system/specialisation 2>/dev/null || echo "(none)"; \
        exit 1; \
      fi; \
      sudo "$path" switch
