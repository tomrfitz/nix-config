---
name: recall
description: Find where something was discussed or decided before, across past Claude Code, omp and pi sessions, the CLI prompt histories, agent memory, repo docs and the user's org notes. Use when the user asks "where did we discuss X", "what did we decide about X", or refers to an earlier conversation or session.
---

# Recall

Search past work for a topic and report what was found,
with dates and where it lives.
Run the cheap sources first and stop once the question is answered.

## Sources

1. **Docs and memory.**
   `rg -n -i '<topic>' AGENTS.md TODO.md` in the current repo,
   then the project's memory directory
   (`${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects/<cwd with / replaced by ->/memory/`;
   `~/.config/claude` here).
   In omp, also its `recall` tool (Mnemopi; project plus global bank).
2. **Org notes.**
   `rg -n -i '<topic>' "${NOTES:-$HOME/Documents/notes}" -g '*.org'`.
   Older notes sit read-only in the Obsidian vault:
   `rg -l -i '<topic>' "$OBSD" --type md`.
3. **Claude Code CLI prompt history**
   (every prompt typed in the CLI since 2026-01;
   the desktop app doesn't write it):

   ```bash
   rg -i '<topic>' "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/history.jsonl" |
     jq -r '"\(.timestamp/1000 | strftime("%Y-%m-%d")) \(.project) \(.display[0:200])"'
   ```

4. **Claude Code transcripts** in
   `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects/*/*.jsonl`.
   CLI sessions are kept for `cleanupPeriodDays`;
   desktop sessions are kept indefinitely.
   Find candidate files first, then pull only the matching text,
   never whole transcripts:

   ```bash
   rg -l -i '<topic>' "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"/projects/*/*.jsonl
   jq -r --arg q '<topic>' '
     select(.type == "user" or .type == "assistant")
     | (.message.content // "" | if type == "string" then . else (map(select(.type == "text") | .text) | join(" ")) end) as $t
     | select($t | test($q; "i"))
     | "\(.timestamp[0:10]) \(.type): \($t[0:300])"' <file>
   ```

   A session's title is its last `custom-title` or `ai-title` record:
   `jq -r 'select(.type == "custom-title" or .type == "ai-title") | .customTitle // .aiTitle' <file> | tail -1`.
5. **omp** (macOS).
   Prompt history, every prompt typed into omp, with full-text search:

   ```bash
   sqlite3 ~/.omp/agent/history.db "select date(h.created_at,'unixepoch'), h.cwd, substr(h.prompt,1,200)
     from history_fts f join history h on h.id = f.rowid where history_fts match '<topic>' order by h.created_at desc"
   ```

   Transcripts are in
   `~/.omp/agent/sessions/<cwd with / replaced by ->/*.jsonl`; find them with
   `rg -l -i`, then pull matching text (the title is the last `title_change`
   record's `.title`):

   ```bash
   jq -r --arg q '<topic>' '
     select(.type == "message" and (.message.role == "user" or .message.role == "assistant"))
     | (.message.content | map(select(.type == "text") | .text) | join(" ")) as $t
     | select($t | test($q; "i"))
     | "\(.timestamp[0:10]) \(.message.role): \($t[0:300])"' <file>
   ```

6. **pi sessions**, if present: `rg -l -i '<topic>' ~/.pi/agent/sessions`.

## Report

For each hit: date, project, session title or file,
and one line on what was said or decided, quoting where the wording matters.
Name the sources that had nothing.
If the hit is a decision still in force that lives only in a transcript,
say where it belongs (AGENTS.md, a memory, a note) and offer to put it there.
