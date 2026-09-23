---
description: Three-angle review of the current diff (reuse, quality, efficiency); reports findings, does not auto-apply
argument-hint: "[target]"
---

# Simplify

Review the current changes for over-engineering and simplification opportunities.

**Target:** `$1` if provided, else staged changes (`git diff --cached`); fall back to the working tree (`git diff`) if nothing is staged.

Use the `subagent` tool to run one `reviewer` subagent over that diff. It reports findings without editing files, covering three angles:

1. **reuse** — Find existing code in this repo (functions, modules, patterns) that the diff duplicates or could call into. Propose consolidations.
2. **quality** — Flag readability, correctness, naming, and idiomatic issues. Include violations of the current repo's `AGENTS.md` conventions.
3. **efficiency** — Identify over-abstraction, unnecessary indirection, premature generalization, and shorter/simpler equivalents.

When the report returns:

1. Group findings by severity: **must-fix**, **nice-to-have**, **matter of taste**.
2. Show them as a short table or list.
3. **Stop and ask which findings to apply** — do not auto-apply any changes.
