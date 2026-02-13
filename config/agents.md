# Global AGENTS.md

## Git

You are an expert at writing Git commits. Your job is to write a short clear commit message that summarizes the changes.

If you can accurately express the change in just the subject line, don't include anything in the message body. Only use the body when it is providing _useful_ information.

Don't repeat information from the subject line in the message body.

Only return the commit message in your response. Do not include any additional meta-commentary about the task. Do not include the raw diff output in the commit message.

Follow good Git style:

- Separate the subject from the body with a blank line
- Try to limit the subject line to 50 characters
- Capitalize the subject line
- Do not end the subject line with any punctuation
- Use the imperative mood in the subject line
- Wrap the body at 72 characters
- Keep the body short and concise (omit it entirely if not useful)

### Atomic commits

Make atomic commits as you go with clear commit messages. If several changes happen at once, try to group them by function such that the worktree is more or less 'complete' at any given hash.

### Git pager

use GIT_PAGER=cat since it is token efficient and 'delta' doesn't always work for agent usage.

### Keep it simple

Avoid parallelizing git operations to avoid race conditions. Just run them sequentially to keep things simple and working as expected.

## Tools

Pay attention to the outputs of tools like lsps and linters. I like to make sure things like clangd, ruff, etc are configured such that their output is helpful and trustworthy

### Prefer modern CLI tools

Use faster, modern alternatives when available: `rg` over `grep`, `fd` over `find`, `bat` over `cat`, `dust`/`duf` over `du`/`df`, etc.

### Command output handling

When running commands, prefer capturing full output to a temp file and inspecting it based on the exit code, rather than preemptively piping through `head` or `tail` and hoping the relevant information is at the expected end. For example:

```sh
cmd > /tmp/out.txt 2>&1; ec=$?
if [ $ec -ne 0 ]; then cat /tmp/out.txt; fi
```

This avoids silently discarding errors or missing context buried in truncated output.

### Python

Use tools from astral's suite: uv, ruff, ty

## Problem-Solving Approach

When implementing new features or restructuring, **design for the final state from the start**. Don't build incrementally toward a structure you can already foresee — lay the foundation correctly and fill it in.
