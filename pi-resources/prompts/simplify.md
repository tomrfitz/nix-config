---
description: Three-angle review of the current diff (reuse, quality, efficiency); reports findings, does not auto-apply
argument-hint: "[target]"
---

# Simplify

Review the current changes for over-engineering and simplification opportunities.

**Target:** `$1` if provided, else staged changes (`git diff --cached`); fall back to the working tree (`git diff`) if nothing is staged.

Use the `subagent` tool in parallel mode to fan out three `reviewer` subagents over that diff. Each runs independently and reports findings without editing files:

1. **reuse** — Find existing code in this repo (functions, modules, patterns) that the diff duplicates or could call into. Propose consolidations.
2. **quality** — Flag readability, correctness, naming, and idiomatic issues. Include violations of the current repo's `AGENTS.md` conventions.
3. **efficiency** — Identify over-abstraction, unnecessary indirection, premature generalization, and shorter/simpler equivalents.

After the three reports return:

1. De-duplicate overlapping issues across the reports.
2. Group findings by severity: **must-fix**, **nice-to-have**, **matter of taste**.
3. Show the consolidated list as a short table or list.
4. **Stop and ask which findings to apply** — do not auto-apply any changes.
