#!/usr/bin/env bash
# Claude Code status line: model · effort │ context │ plan limits │ git │ session.
# Claude Code pipes the session JSON on stdin (https://code.claude.com/docs/en/statusline);
# linked to ~/.claude/statusline.sh by modules/shared/home/claude-code.nix.

input=$(cat)

# One jq pass. Fields are joined with the unit separator, not tabs: read collapses
# runs of whitespace delimiters, which would shift fields after an empty one.
IFS=$'\x1f' read -r model effort pct size five seven dir name < <(
    jq -r '[
    .model.display_name // "?",
    .effort.level // "",
    (.context_window.used_percentage // 0 | floor),
    .context_window.context_window_size // 0,
    (.rate_limits.five_hour.used_percentage // "" | if . == "" then . else floor end),
    (.rate_limits.seven_day.used_percentage // "" | if . == "" then . else floor end),
    .workspace.current_dir // .cwd // "",
    .session_name // ""
  ] | map(tostring) | join("\u001f")' <<<"$input"
)

paint() { printf '\033[%sm%s\033[0m' "$1" "$2"; }
sep=$(paint 2 ' │ ')

# Context: yellow from 150k tokens or 50%, red from 300k or 75% (when to hand off).
tokens=$((pct * size / 100))
color=32
if ((tokens >= 300000 || pct >= 75)); then
    color=31
elif ((tokens >= 150000 || pct >= 50)); then
    color=33
fi
out="$(paint 36 "$model")"
[ -n "$effort" ] && out+=" $(paint 2 "$effort")"
out+="$sep$(paint "$color" "ctx ${pct}% $((tokens / 1000))k")"

limit() { # label percent
    [ -z "$2" ] && return
    local c=2
    if (($2 >= 90)); then c=31; elif (($2 >= 70)); then c=33; fi
    printf '%s' "$(paint "$c" "$1 $2%")"
}
limits="$(limit 5h "$five")"
[ -n "$seven" ] && limits+="${limits:+ }$(limit 7d "$seven")"
[ -n "$limits" ] && out+="$sep$limits"

# Git: branch, dirty file count, unpushed commits. --no-optional-locks keeps this
# from taking index.lock while the session runs its own git commands.
if [ -n "$dir" ] && branch=$(git -C "$dir" symbolic-ref --short -q HEAD 2>/dev/null ||
    git -C "$dir" rev-parse --short HEAD 2>/dev/null); then
    dirty=$(git --no-optional-locks -C "$dir" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    ahead=$(git -C "$dir" rev-list --count '@{upstream}..HEAD' 2>/dev/null || echo 0)
    git_part="$branch"
    ((dirty > 0)) && git_part+=" $(paint 33 "●$dirty")"
    ((ahead > 0)) && git_part+=" $(paint 35 "↑$ahead")"
    out+="$sep$git_part"
fi

[ -n "$name" ] && out+="$sep$(paint 2 "${name:0:32}")"
printf '%s\n' "$out"
