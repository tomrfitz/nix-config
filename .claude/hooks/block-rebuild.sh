#!/bin/bash
# Block 'just rebuild' unless the user explicitly requested it.
# PreToolUse hook — exit 2 blocks the command, stderr becomes the reason.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')

# Only block when 'just rebuild' is the actual command being run,
# not when it appears inside a string (e.g., commit messages).
if echo "$COMMAND" | grep -qE '^(sudo\s+)?just rebuild'; then
    echo "'just rebuild' mutates the live system. Use 'just check' for dry-run validation. Only run rebuild when explicitly asked." >&2
    exit 2
fi

exit 0
