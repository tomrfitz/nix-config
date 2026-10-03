---
name: recall
description: Find where something was discussed or decided before, across past Claude Code and pi sessions, the CLI prompt history, agent memory, repo docs and the user's org notes. Use when the user asks "where did we discuss X", "what did we decide about X", or refers to an earlier conversation or session.
---

# Recall

Search past work for a topic and report what was found, with dates and where it lives. Run the cheap sources first and stop once the question is answered.

## Sources

1. **Docs and memory.** `rg -n -i '<topic>' AGENTS.md TODO.md` in the current repo, then the project's memory directory (`~/.claude/projects/<cwd with / replaced by ->/memory/`).
2. **Org notes.** `rg -n -i '<topic>' "${NOTES:-$HOME/Documents/notes}" -g '*.org'`. Older notes sit read-only in the Obsidian vault: `rg -l -i '<topic>' "$OBSD" --type md`.
3. **CLI prompt history** (every prompt typed in the CLI since 2026-01; the desktop app doesn't write it):

   ```bash
   rg -i '<topic>' ~/.claude/history.jsonl |
     jq -r '"\(.timestamp/1000 | strftime("%Y-%m-%d")) \(.project) \(.display[0:200])"'
   ```

4. **Claude Code transcripts** in `~/.claude/projects/*/*.jsonl`. CLI sessions are kept for `cleanupPeriodDays`; desktop sessions are kept indefinitely. Find candidate files first, then pull only the matching text, never whole transcripts:

   ```bash
   rg -l -i '<topic>' ~/.claude/projects/*/*.jsonl
   jq -r --arg q '<topic>' '
     select(.type == "user" or .type == "assistant")
     | (.message.content // "" | if type == "string" then . else (map(select(.type == "text") | .text) | join(" ")) end) as $t
     | select($t | test($q; "i"))
     | "\(.timestamp[0:10]) \(.type): \($t[0:300])"' <file>
   ```

   A session's title is its last `custom-title` or `ai-title` record: `jq -r 'select(.type == "custom-title" or .type == "ai-title") | .customTitle // .aiTitle' <file> | tail -1`.
5. **pi sessions**, if present: `rg -l -i '<topic>' ~/.pi/agent/sessions`.

## Report

For each hit: date, project, session title or file, and one line on what was said or decided, quoting where the wording matters. Name the sources that had nothing. If the hit is a decision still in force that lives only in a transcript, say where it belongs (AGENTS.md, a memory, a note) and offer to put it there.
