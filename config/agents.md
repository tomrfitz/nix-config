# Global AGENTS.md

Project-agnostic guidance for AI coding agents. Deployed to `~/.config/AGENTS.md`, `~/.claude/CLAUDE.md`, and `~/.config/opencode/AGENTS.md` by home-manager.

## Git

- Subject line: imperative mood, ~50 chars, no trailing punctuation
- Atomic commits grouped by function
- Body only when it adds useful context beyond the subject
- Avoid parallelizing git operations — run sequentially to avoid race conditions

## Tools

- Available in dev shells: `rg`, `fd`, `bat`, `dust`/`duf`, `nixfmt`, `nixd`, `nvd`
- Pay attention to LSP and linter output — trust tools like clangd, ruff, nixd
- Record findings in open-standard docs (AGENTS.md in project root), then symlink to tool-specific paths if needed (CLAUDE.md, GEMINI.md, etc.)
- Don't guess at command output — never truncate with `head`/`tail` before reading the result. Check the exit code and full output before deciding what's relevant.
- Don't dump large output directly into context. Use targeted tools (grep, read with offset/limit) to extract the relevant section.

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

- Design for the final state from the start. Don't build incrementally toward a structure you can already foresee.
- Distinguish "not implemented yet" from "doesn't exist" when exploring APIs/options
- Check official docs first; save significant research findings for future reference
- When a decision has lasting consequences (naming, architecture, file placement), ask rather than assume. When the path forward is clear or easily reversible, just do it.

## Communication

- When multiple valid approaches exist, present tradeoffs rather than choosing silently
- Keep explanations concise — body/detail only when it adds context beyond the obvious
- Be direct and critical when asked for feedback — don't soften or hedge
- The user thinks architecturally; engage at the design level rather than jumping to implementation details
- When the user is thinking out loud, participate in the thinking rather than immediately structuring it into action items

## Continuity

- Treat AGENTS.md, memory files, and project docs as imperfect but valuable persistence — update them when you learn something that would save a future agent real orientation time
- Distinguish facts (test status, file paths) from understanding (why a design decision was made, what the user's goals are) — both matter, but understanding is harder to capture and more valuable to try
- The user's Obsidian vault at `$OBSD` is their primary knowledge base. When producing research or notes for later use, write there using this frontmatter style:

    ```yaml
    ---
    date created: 2025-09-21, 18:42:24
    date modified: 2025-09-21, 18:42:48
    ---
    ```

    Use `[[wikilinks]]` for internal references.
- The user values long-term collaboration patterns over per-session efficiency — leave good context for next time
