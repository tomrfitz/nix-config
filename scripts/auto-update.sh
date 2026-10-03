#!/usr/bin/env bash
set -euo pipefail

WORK_DIR="/var/lib/auto-update"
REPO_DIR="${WORK_DIR}/nix-config"
DEPLOY_KEY="${DEPLOY_KEY_PATH:?DEPLOY_KEY_PATH must be set}"
REPO_URL="git@github.com:tomrfitz/nix-config.git"
ATTIC_CACHE="local:$(cat /etc/attic/cache-name)"

# ── Phase 0: Setup ──────────────────────────────────────────────────────
echo "==> Phase 0: Configuring deploy key from sops"
export GIT_SSH_COMMAND="ssh -i ${DEPLOY_KEY} -o StrictHostKeyChecking=accept-new"

# ── Phase 1: Repo sync ──────────────────────────────────────────────────
echo "==> Phase 1: Syncing repo"
if [[ -d "${REPO_DIR}/.git" ]]; then
    git -C "${REPO_DIR}" fetch origin main
    git -C "${REPO_DIR}" reset --hard origin/main
else
    git clone "${REPO_URL}" "${REPO_DIR}"
fi
cd "${REPO_DIR}"

# ── Phase 2: Update flake.lock ──────────────────────────────────────────
echo "==> Phase 2: Updating flake inputs"
nix flake update

# ── Phase 3: Eval hosts not built here ──────────────────────────────────
# trfmbp can't build on linux. trfnix has been powered off since ~2026-03, so
# its ~6 GiB closure would feed a cache nothing pulls from; build and push it
# again once it's back in use, with an out-link of its own (see Phase 4).
echo "==> Phase 3: Evaluating trfmbp and trfnix"
nix eval .#darwinConfigurations.trfmbp.system --raw
echo
nix eval .#nixosConfigurations.trfnix.config.system.build.toplevel --raw
echo

# ── Phase 4: Build trfwsl ───────────────────────────────────────────────
echo "==> Phase 4: Building trfwsl closure"
# The out-link is a GC root: the nightly nix-gc keeps this build even if the
# switch below fails, and the next run fetches only what changed.
TRFWSL_PATH=$(nix build .#nixosConfigurations.trfwsl.config.system.build.toplevel --print-out-paths --out-link "${WORK_DIR}/result-trfwsl")
echo "    trfwsl: ${TRFWSL_PATH}"

# ── Phase 5: Push to Attic ──────────────────────────────────────────────
echo "==> Phase 5: Pushing to Attic cache"
attic push "${ATTIC_CACHE}" "${TRFWSL_PATH}"

# ── Phase 6: Switch trfwsl ──────────────────────────────────────────────
echo "==> Phase 6: Switching trfwsl"
nixos-rebuild switch --flake .#trfwsl

# ── Phase 7: Push if changed ────────────────────────────────────────────
if ! git diff --quiet flake.lock; then
    echo "==> Phase 7: Committing and pushing flake.lock"
    git add flake.lock
    git -c user.name="trfwsl auto-update" -c user.email="tomrfitz@gmail.com" \
        commit -m "Update flake.lock"
    git push origin HEAD:main
else
    echo "==> Phase 7: No changes to push"
fi

echo "==> Done"
