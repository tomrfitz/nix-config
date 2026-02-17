# Global AGENTS.md

Project-agnostic guidance for AI coding agents. Deployed to `~/.config/AGENTS.md` and `~/.claude/CLAUDE.md` by home-manager.

## Git

- Subject line: imperative mood, ~50 chars, no trailing punctuation
- Atomic commits grouped by function
- Body only when it adds useful context beyond the subject
- Avoid parallelizing git operations — run sequentially to avoid race conditions

## Tools

- Prefer modern CLI tools: `rg` over `grep`, `fd` over `find`, `bat` over `cat`, `dust`/`duf` over `du`/`df`
- Pay attention to LSP and linter output — trust tools like clangd, ruff, nixd
- Prefer recording your findings in open-standard style documents, then you can symlink to somewhere you prefer if necessary. ie create AGENTS.md in project root, then link to GEIMINI.md or CLAUDE.md.
- Capture full command output to temp files rather than piping through `head`/`tail`:

    ```sh
    cmd > /tmp/out.txt 2>&1; ec=$?
    if [ $ec -ne 0 ]; then cat /tmp/out.txt; fi
    ```

### Language-specific

- **Nix:** format with `nixfmt`, use `nixd` as LSP
- **Python:** use astral's suite (`uv`, `ruff`, `ty`)

## Validation & side effects

- Prefer dry-run/check before apply; never mutate live systems without explicit request
- Understand which commands are idempotent (read-only queries, formatting checks) vs stateful (installs, deployments, database migrations)
- When a validation step exists, run it before and after changes

## Code organization

- Maximize shared/common code; platform- or environment-specific only for genuine differences
- Entry points (hosts, main files, routers) wire things together — they don't contain logic
- Prefer framework-native modules over manual file/config management

## Problem-solving

- When implementing new features or restructuring, design for the final state from the start. Don't build incrementally toward a structure you can already foresee.
- Distinguish "not implemented yet" from "doesn't exist" when exploring APIs/options
- Check official docs first; save significant research findings for future reference
- Document assumptions when information is incomplete

## Communication

- When multiple valid approaches exist, present tradeoffs rather than choosing silently
- Keep explanations concise — body/detail only when it adds context beyond the obvious
- Be direct and critical when asked for feedback — don't soften or hedge when the user asks you to find flaws
- The user thinks architecturally; engage at the design level rather than jumping to implementation details
- When the user is thinking out loud or spitballing, participate in the thinking rather than immediately structuring it into action items

## Continuity

- Treat AGENTS.md, memory files, and project docs as imperfect but valuable persistence — update them when you learn something that would save a future agent real orientation time
- Distinguish facts (test status, file paths) from understanding (why a design decision was made, what the user's goals are) — both matter, but understanding is harder to capture and more valuable to try
- The user's Obsidian vault at `$OBSD` is their primary knowledge base — when producing research or notes for later use, write there in their frontmatter style (`date created`, `date modified`, wikilinks)
- The user values long-term collaboration patterns over per-session efficiency — don't optimize for "get this task done fast" at the expense of leaving good context for next time
