#!/bin/bash
# Block live-system mutations unless the user explicitly requested them:
# just rebuild/update/rollback, nh darwin|os switch, and darwin-/nixos-rebuild
# switch|boot|test|activate. Dry-run forms (build, dry-build,
# --list-generations) stay allowed.
# PreToolUse hook — exit 2 blocks the command, stderr becomes the reason.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')

# Match at the start of the command or after a shell separator, so compound
# invocations (cd … && just rebuild) are caught but occurrences inside
# strings (e.g. commit messages) are not.
if echo "$COMMAND" | grep -qE '(^|[;&|()]\s*)(sudo\s+)?(just\s+(rebuild|update|rollback)\b|nh\s+(darwin|os)\s+switch\b|(darwin|nixos)-rebuild\s+(switch|boot|test|activate)\b)'; then
    echo "Live-system mutation blocked: 'just rebuild/update/rollback', 'nh … switch', and 'darwin-/nixos-rebuild switch|boot|test|activate' all activate the system. Use 'just check' or 'just eval' for validation. Only run rebuilds when explicitly asked." >&2
    exit 2
fi

exit 0
