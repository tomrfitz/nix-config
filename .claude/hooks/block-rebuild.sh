#!/bin/bash
# Block live-system mutations — the user runs those, not the agent:
# nh darwin|os switch and darwin-/nixos-rebuild switch|boot|test|activate.
# Dry-run forms (build, dry-build, --list-generations) stay allowed.
# PreToolUse hook — exit 2 blocks the command, stderr becomes the reason.
#
# Scope, verified 2026-09-23: Claude Code's Bash tool gets no zsh aliases, so
# the nr* aliases can't run here and aren't matched. Every match exits 2, so
# the matching `ask` rules in .claude/settings.json never get to prompt; a
# hook returning `permissionDecision: "ask"` would prompt instead, even in
# auto mode.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')

# Match at the start of the command or after a shell separator, so compound
# invocations (cd … && nh darwin switch) are caught and a mention mid-sentence
# (a commit message) is not. A quoted string with a separator before the
# trigger still matches; to probe this hook, read test commands from a file.
if echo "$COMMAND" | grep -qE '(^|[;&|()]\s*)(sudo\s+)?(nh\s+(darwin|os)\s+switch\b|(darwin|nixos)-rebuild\s+(switch|boot|test|activate)\b)'; then
    echo "Live-system mutation blocked: 'nh … switch' and 'darwin-/nixos-rebuild switch|boot|test|activate' activate the system, and the user runs those. Validate with 'just check' or 'just eval'; if the change needs applying, give the user the command." >&2
    exit 2
fi

exit 0
