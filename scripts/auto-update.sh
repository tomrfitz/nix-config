#!/usr/bin/env bash
set -euo pipefail

WORK_DIR="/var/lib/auto-update"
REPO_DIR="${WORK_DIR}/nix-config"
DEPLOY_KEY="${DEPLOY_KEY_PATH:?DEPLOY_KEY_PATH must be set}"
REPO_URL="git@github.com:tomrfitz/nix-config.git"
ATTIC_CACHE=$(cat /etc/attic/cache-name)

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

# ── Phase 3: Eval darwin (can't build on linux) ─────────────────────────
echo "==> Phase 3: Evaluating trfmbp (cross-platform eval check)"
nix eval .#darwinConfigurations.trfmbp.system --raw
echo

# ── Phase 4: Build x86 closures (implicitly evals trfwsl + trfnix) ─────
echo "==> Phase 4: Building trfwsl and trfnix closures"
TRFWSL_PATH=$(nix build .#nixosConfigurations.trfwsl.config.system.build.toplevel --print-out-paths --no-link)
TRFNIX_PATH=$(nix build .#nixosConfigurations.trfnix.config.system.build.toplevel --print-out-paths --no-link)
echo "    trfwsl: ${TRFWSL_PATH}"
echo "    trfnix: ${TRFNIX_PATH}"

# ── Phase 5: Push to Attic ──────────────────────────────────────────────
echo "==> Phase 5: Pushing to Attic cache"
attic push "${ATTIC_CACHE}" "${TRFWSL_PATH}" "${TRFNIX_PATH}"

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
