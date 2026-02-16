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
