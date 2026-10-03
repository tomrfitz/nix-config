---
name: land
description: Shape the dirty working tree into topic commits built from hunks, gate each commit on exactly the staged tree, and push only when asked. Run only when the user asks to commit or land work.
disable-model-invocation: true
---

# Land

Turn the dirty tree into a short series of topic-coherent commits on `main`. No landing branches: the reflog is the rollback, and CI runs only on `main` pushes. Amending unpushed commits is fine.

## 1. Survey and propose

- `git status --short`, `git diff --stat`, `git stash list`, `git log --oneline '@{upstream}..HEAD'`.
- Group the changes by topic: one module, feature or fix per commit. A file can span topics; split it by hunk.
- Propose the commit list (subjects in the repo's `area: summary` style, files and hunks for each) and wait for the user's OK.

## 2. Stage one commit

- Start from a clean index: `git reset -q` (keeps the working tree). Stale pre-staged snapshots must not leak into a commit.
- Don't use intent-to-add (`git add -N`): it trips the pre-commit hook's stash/restore. New files stay untracked until their commit.
- Whole files when a file is one topic: `git add <file>`.
- One topic's hunks from a mixed file: `git diff -U0 <file> > <scratch>/f.patch`, keep only that topic's hunks, then `git apply --cached --unidiff-zero <scratch>/f.patch`. Check that the remaining hunks still apply to the working tree.
- Never `git add .` or `-A` while scratch files sit in the tree.

## 3. Gate exactly the staged tree

The working tree still holds later commits' changes, so gate the index, not the worktree:

```bash
gate=$(mktemp -d)
git checkout-index -a --prefix="$gate/"
for h in trfmbp; do nix eval --raw "path:$gate#darwinConfigurations.$h.system" >/dev/null; done
for h in trfnix trfwsl; do nix eval --raw "path:$gate#nixosConfigurations.$h.config.system.build.toplevel" >/dev/null; done
nix build --no-link "path:$gate#checks.aarch64-darwin.formatting"
```

Fix and restage until it passes.

## 4. Commit, then repeat

- Commit with an imperative subject of about 50 characters, adding a body only when it explains why. Signing goes through 1Password's `op-ssh-sign` without a prompt. If it fails because 1Password is locked ("failed to fill whole buffer"), ask the user to unlock it; don't commit with `--no-gpg-sign`.
- Before the first commit, back up the worktree (`rsync -a --exclude .git ./ <scratch>/tree/`). After each commit, `rsync -nrc --exclude .git ./ <scratch>/tree/` must list only files that commit changed: proof that the pre-commit hook's stash and restore lost nothing.
- Back to step 2 for the next topic. The last commit leaves the tree clean, apart from deliberately uncommitted files.

## 5. Push only if asked

Push when the user asked for it: `git push`. Then watch CI with `gh run list --branch main --limit 3`. Report the commits (short SHA and subject) and CI status.
