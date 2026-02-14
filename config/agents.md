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

## Problem-solving

When implementing new features or restructuring, design for the final state from the start. Don't build incrementally toward a structure you can already foresee.
