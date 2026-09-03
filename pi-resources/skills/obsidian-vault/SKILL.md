---
name: obsidian-vault
description: Search, create, and manage notes in the user's Obsidian vault at $OBSD. Use when the user wants to find, create, or organize notes; when you produce research worth persisting; or when you need context about the user that may live in their vault.
---

# Obsidian Vault

## Vault location

The vault path lives in the `$OBSD` environment variable. Resolve it before any file operation:

```bash
test -n "$OBSD" && test -d "$OBSD" || { echo "OBSD unset or vault missing"; exit 1; }
```

Agent-written notes go to **`$OBSD/Notes/`**. The rest of the vault is the user's own organizational space — don't restructure it.

## Frontmatter convention

Every note in this vault uses YAML frontmatter with creation and modification timestamps. Agent-authored notes add an `author` field so they're easy to distinguish from the user's own.

```yaml
---
date created: 2026-05-24, 02:30:00
date modified: 2026-05-24, 02:30:00
author: <agent-name>  # ONLY when written by an agent; omit for user's own notes
---
```

- **Absent `author`** → written by the user.
- **Present `author`** → written by an agent. Pick a stable, self-chosen name (the model id, a project persona, anything consistent) and reuse it across sessions so the user can grep their notes by source.
- Timestamps are local time, format `YYYY-MM-DD, HH:MM:SS`. Generate with `date '+%Y-%m-%d, %H:%M:%S'`.

This convention is also documented in the global `AGENTS.md` (the source of truth — `config/agents.md` in the nix-config repo).

## Linking

Use Obsidian `[[wikilinks]]` for cross-references. Wikilinks resolve by filename across the whole vault regardless of folder.

## Workflows

### Look before writing

Before writing a note, scan the vault to understand its existing organization (folders, naming, tags). The user's conventions may evolve; don't assume.

```bash
fd -e md . "$OBSD" | head -30
ls "$OBSD/Notes/" 2>/dev/null
```

### Search notes

```bash
# Filename search
fd -e md . "$OBSD" | rg -i "keyword"

# Content search
rg "keyword" "$OBSD" --type md -l

# Find backlinks to a specific note
rg '\[\[Note Title\]\]' "$OBSD" --type md -l
```

### Create a new note (agent-authored)

1. Save under `$OBSD/Notes/`.
2. Include the frontmatter above with `author: <your-name>` set.
3. Add `[[wikilinks]]` to related notes at the bottom when relevant.
4. Use a filename style consistent with neighboring notes in the same folder.

### Update an existing note

1. Preserve existing frontmatter; update `date modified` only.
2. If the note has no `author` field, do not add one — that note was written by the user. Edits by an agent to a user note shouldn't change its authorship marker.

## Pitfalls

- Don't write outside `$OBSD/Notes/` unless the user explicitly says so.
- Don't add or remove the `author` field on existing user notes.
- Don't rename or move user notes — wikilinks can break silently.
- If `$OBSD` is unset, ask the user rather than guessing a path.
