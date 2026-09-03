# pi-resources

Author-owned [pi](https://github.com/earendil-works/pi) skills and prompt templates managed declaratively in this repo. Wired into `~/.pi/agent/{skills,prompts}/` via out-of-store symlinks declared in `modules/shared/home/pi.nix` (darwin-only).

Pi reads through the symlinks live — edits here take effect on the next pi restart with no rebuild needed. Reverts are `git checkout pi-resources/...`. A rebuild is only required when the wiring itself changes (e.g. adding a new top-level skill folder requires a new `home.file` entry in `pi.nix`).

## Layout

```text
pi-resources/
    skills/
        obsidian-vault/   # author-owned
    prompts/
        simplify.md       # author-owned
```

Skill discovery follows pi's auto-discovery rule for `~/.pi/agent/skills/`: every `SKILL.md` file (recursively) registers its containing directory as a skill. Sibling `.md` files in a skill directory are supporting docs, not separate skills. Don't put top-level `.md` files directly under `skills/` — pi would load them as standalone skills.

## Author-owned content

- `skills/obsidian-vault/` — agent guidance for reading/writing the Obsidian vault at `$OBSD` (transitioning to `$NOTES`; see `TODO.md` Emacs migration plan), including the `author:` frontmatter convention for agent-written notes.
- `prompts/simplify.md` — `/simplify` slash command. Three-angle review of the current diff (reuse, quality, efficiency) via parallel `reviewer` subagents.

## Third-party skills (not vendored)

`mattpocock/skills` is consumed via the `mattpocock-skills` flake input declared in `flake.nix`, **not** vendored into this repo. `modules/shared/home/pi.nix` symlinks the upstream `skills/` tree to `~/.pi/agent/skills/mattpocock/`; pi's recursive `SKILL.md` discovery exposes the full upstream catalog (`engineering/`, `productivity/`, `personal/`, `misc/`, `in-progress/`).

Updates land via `nix flake update`; `flake.lock` pins the commit. License (MIT) is upstream at <https://github.com/mattpocock/skills/blob/main/LICENSE>.
