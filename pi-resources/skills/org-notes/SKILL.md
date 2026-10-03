---
name: org-notes
description: Search, create, and append to the user's org notes at $NOTES (~/Documents/notes, Emacs's org-directory). Use when the user wants to find, create, or organize notes; when you produce research worth persisting; or when you need context about the user that may live in their notes. Older notes live read-only in the Obsidian vault at $OBSD.
---

# Org notes

## Location

Notes live in `$NOTES` (`~/Documents/notes`), a flat directory that is also Emacs's `org-directory`. Resolve it before any file operation:

```bash
test -n "$NOTES" && test -d "$NOTES" || { echo "NOTES unset or missing"; exit 1; }
```

Every top-level `.org` file there is an agenda file (`CS7637.org`, `todo.org` and `inbox.org` included), so headings you add reach the user's agenda and refile targets.

The Obsidian vault at `$OBSD` is an archive of older notes. Search it when recalling past research; never write to it.

## File conventions

- One topic per file, plain kebab-case names: `attic-vs-harmonia.org`. No denote-style `YYYYMMDDTHHMMSS--title__tags.org` names; the few in the directory came from the user's own workflow.
- A new file starts with:

  ```org
  #+title:    Attic vs Harmonia
  #+date:     [2026-03-19]
  #+filetags: :nix:homelab:
  #+author:   pi
  ```

- `#+author:` marks agent-written notes. Use a stable, self-chosen name (the harness name such as `pi` or `claude`, not a model id, which changes every release) and reuse it so the user can grep their notes by source. Omit it on the user's own notes, and never add or remove it on an existing file.
- Org markup, not Markdown: `* Heading`, `=code=`, `*bold*`, `#+begin_src` blocks, links as `[[file:other-note.org][Other note]]` or `[[https://example.com][label]]`.
- No `TODO` keywords, deadlines or scheduled dates unless the user asks: they land in the agenda.

This convention is also documented in the global `AGENTS.md` (source of truth: `config/agents.md` in the nix-config repo).

## Workflows

### Look before writing

```bash
ls "$NOTES"
rg -l -i "keyword" "$NOTES" -g '*.org'
```

Append to an existing topic file when one fits; create a new file only for a new topic.

### Search

```bash
rg -n -i "keyword" "$NOTES" -g '*.org'   # org notes
rg -l -i "keyword" "$OBSD" --type md     # older Obsidian notes (read-only)
```

### Append

Capture files (`inbox.org`, `todo.org`, course files like `CS7637.org`) accumulate entries: append under the right heading with an edit, never overwrite them with a full-file write.

## Pitfalls

- Don't write outside `$NOTES` unless the user says so, and never into `$OBSD`.
- Don't rename or move the user's files: links and refile paths depend on them.
- If `$NOTES` is unset, ask rather than guessing a path.
