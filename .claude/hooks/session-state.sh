#!/bin/bash
# SessionStart hook: tell the agent what state the repo and this machine are in,
# so it never has to reconstruct whether the running system is main, a local
# nrsl build, or something older. Stdout is added to the session's context.
# The running commit comes from system.configurationRevision (flake.nix).

cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

branch=$(git symbolic-ref --short -q HEAD || git rev-parse --short HEAD)
head=$(git rev-parse HEAD)
changed=$(git --no-optional-locks status --porcelain | wc -l | tr -d ' ')
lock=""
git --no-optional-locks diff --quiet HEAD -- flake.lock 2>/dev/null || lock=", flake.lock modified"

repo="$branch at ${head:0:7}"
if upstream=$(git rev-parse -q --verify '@{upstream}' 2>/dev/null); then
    ahead=$(git rev-list --count '@{upstream}..HEAD')
    behind=$(git rev-list --count 'HEAD..@{upstream}')
    repo+=", $(git rev-parse --abbrev-ref '@{upstream}') at ${upstream:0:7} ($ahead ahead, $behind behind as of the last fetch)"
fi
repo+="; $changed changed files$lock"

if command -v darwin-version >/dev/null; then
    running=$(darwin-version --configuration-revision 2>/dev/null)
elif command -v nixos-version >/dev/null; then
    running=$(nixos-version --configuration-revision 2>/dev/null)
fi
rev=${running%-dirty}
host=$(hostname -s)
if [ -z "$rev" ] || [ "$rev" = null ]; then
    machine="$host: running commit unknown (recorded from the next switch on)"
elif [ "$running" != "$rev" ]; then
    machine="$host runs ${rev:0:7}-dirty: a local nrsl build with uncommitted changes, not a pushed commit"
elif [ -n "$upstream" ] && [ "$rev" = "$upstream" ]; then
    machine="$host runs ${rev:0:7}, the same commit as the upstream branch"
elif [ "$rev" = "$head" ]; then
    machine="$host runs ${rev:0:7}, the local HEAD (not pushed)"
elif [ -n "$upstream" ] && git merge-base --is-ancestor "$rev" "$upstream" 2>/dev/null; then
    machine="$host runs ${rev:0:7}, $(git rev-list --count "$rev..$upstream") commits behind the upstream branch"
else
    machine="$host runs ${rev:0:7}, which is not on the upstream branch"
fi

printf 'Repo and machine state at session start (.claude/hooks/session-state.sh):\n- %s\n- %s\n' "$repo" "$machine"
