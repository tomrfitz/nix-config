---
name: handoff
description: Close out a working thread so a fresh session can pick it up. Writes what was done, what's next, what's unverified and what's blocked to the repo's TODO.md (or the org inbox outside a repo), prunes memory the thread made stale, then suggests a fresh session. Use when the user runs /handoff or asks to wrap up and continue later.
---

# Handoff

Leave the thread so that a fresh session, possibly in another harness or on another machine, can continue without this conversation.

## 1. Gather state

- In a repo: `git status --short`, `git log --oneline '@{upstream}..HEAD'` (unpushed), `git stash list`.
- From the conversation: what was decided, what changed, what was verified and how, what's next, what's blocked and on whom.

## 2. Write it down

In a repo with a `TODO.md`, add one section near the top, or replace the previous handoff for the same topic rather than stacking another:

```markdown
## Handoff: <topic> (<YYYY-MM-DD>)

- **State:** what's done; commits by short SHA, or "uncommitted: <files>".
- **Next:** the first concrete step, then the rest in order.
- **Unverified:** claims not checked against live state or source, and how to check each.
- **Blocked on:** decisions or actions only the user can take.
```

Outside a repo, append the same content as an org heading (`* Handoff: <topic>` with an inactive timestamp) to `$NOTES/inbox.org` (`~/Documents/notes/inbox.org`). Append; never overwrite it.

Write for a reader with no access to this conversation: name files, hosts and commands, not "the thing we tried earlier".

## 3. Prune memory

If this harness keeps memory, correct the entries this thread made stale and delete the ones it resolved. Add a memory only for something a future session would get wrong without it. The handoff itself belongs in the file above, not in memory.

## 4. Close

Say in one line where the handoff went, then suggest starting a fresh session (`/clear` in Claude Code) whose first step is reading it.
