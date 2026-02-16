---
name: nix-check
description: Dry-run rebuild to catch errors without applying
user-invocable: true
disable-model-invocation: true
---

# nix-check

Run `just check` to perform a dry-run rebuild. Report the result clearly:

- On success: confirm the build succeeded with no errors
- On failure: show the relevant error output and suggest fixes
