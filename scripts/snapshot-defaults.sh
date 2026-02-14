#!/usr/bin/env bash
# snapshot-defaults.sh — Take and diff macOS defaults snapshots using defaults2nix.
#
# Usage:
#   ./scripts/snapshot-defaults.sh snapshot <name>   Take a snapshot
#   ./scripts/snapshot-defaults.sh diff <before> <after>  Diff two snapshots
#   ./scripts/snapshot-defaults.sh domains <name>    List domains in a snapshot
#
# Requires defaults2nix on PATH (enter via `nix develop` first).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SNAPSHOTS_DIR="$REPO_ROOT/snapshots"

usage() {
    cat >&2 <<EOF
Usage: $(basename "$0") <command> [args]

Commands:
  snapshot <name>          Take a filtered snapshot of all macOS defaults
  diff <before> <after>    Show settings that changed between two snapshots
  domains <name>           List all domains captured in a snapshot

Examples:
  $(basename "$0") snapshot before
  # ... change a setting in System Settings ...
  $(basename "$0") snapshot after
  $(basename "$0") diff before after
EOF
    exit 1
}

cmd_snapshot() {
    local name="${1:?snapshot name required}"
    local dest="$SNAPSHOTS_DIR/$name"

    if ! command -v defaults2nix &>/dev/null; then
        echo "Error: defaults2nix not found. Enter the dev shell first:" >&2
        echo "  nix develop" >&2
        exit 1
    fi

    mkdir -p "$dest"
    echo "Taking snapshot '$name' -> $dest/"
    defaults2nix -split -filter dates,state,uuids -out "$dest/" 2>&1
    echo ""
    echo "Snapshot '$name' complete: $(ls "$dest/" | wc -l | tr -d ' ') domains captured."
}

cmd_diff() {
    local before="${1:?'before' snapshot name required}"
    local after="${2:?'after' snapshot name required}"
    local before_dir="$SNAPSHOTS_DIR/$before"
    local after_dir="$SNAPSHOTS_DIR/$after"

    if [[ ! -d $before_dir ]]; then
        echo "Error: snapshot '$before' not found at $before_dir" >&2
        exit 1
    fi
    if [[ ! -d $after_dir ]]; then
        echo "Error: snapshot '$after' not found at $after_dir" >&2
        exit 1
    fi

    local found_diff=false

    # Check files in 'after' for changes or additions
    for file in "$after_dir"/*.nix; do
        local basename
        basename="$(basename "$file")"
        local before_file="$before_dir/$basename"

        if [[ ! -f $before_file ]]; then
            echo "=== NEW DOMAIN: $basename ==="
            cat "$file"
            echo ""
            found_diff=true
        elif ! diff -q "$before_file" "$file" &>/dev/null; then
            echo "=== CHANGED: $basename ==="
            diff -u "$before_file" "$file" --label "$before/$basename" --label "$after/$basename" || true
            echo ""
            found_diff=true
        fi
    done

    # Check for domains removed in 'after'
    for file in "$before_dir"/*.nix; do
        local basename
        basename="$(basename "$file")"
        if [[ ! -f "$after_dir/$basename" ]]; then
            echo "=== REMOVED DOMAIN: $basename ==="
            echo ""
            found_diff=true
        fi
    done

    if [[ $found_diff == "false" ]]; then
        echo "No differences found between '$before' and '$after'."
    fi
}

cmd_domains() {
    local name="${1:?snapshot name required}"
    local dir="$SNAPSHOTS_DIR/$name"

    if [[ ! -d $dir ]]; then
        echo "Error: snapshot '$name' not found at $dir" >&2
        exit 1
    fi

    ls "$dir/" | sed 's/\.nix$//' | sort
}

# ── Main ───────────────────────────────────────────────────────────────
[[ $# -lt 1 ]] && usage

case "$1" in
snapshot)
    shift
    cmd_snapshot "$@"
    ;;
diff)
    shift
    cmd_diff "$@"
    ;;
domains)
    shift
    cmd_domains "$@"
    ;;
*) usage ;;
esac
