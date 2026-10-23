#!/usr/bin/env bash
# Build, cache and switch trfwsl from origin/main. Lock bumps come from the
# Update flake.lock workflow's PRs (.github/workflows/update-flake-lock.yml),
# so this only follows main.
set -euo pipefail

WORK_DIR="/var/lib/auto-update"
REPO_DIR="${WORK_DIR}/nix-config"
DEPLOY_KEY="${DEPLOY_KEY_PATH:?DEPLOY_KEY_PATH must be set}"
REPO_URL="git@github.com:tomrfitz/nix-config.git"
ATTIC_CACHE="local:$(cat /etc/attic/cache-name)"

# ── Phase 0: Setup ──────────────────────────────────────────────────────
echo "==> Phase 0: Configuring deploy key from sops (fetch only)"
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

# ── Phase 2: Build trfwsl ───────────────────────────────────────────────
echo "==> Phase 2: Building trfwsl closure"
# The out-link is a GC root: the nightly nix-gc keeps this build even if the
# switch below fails, and the next run fetches only what changed.
TRFWSL_PATH=$(nix build .#nixosConfigurations.trfwsl.config.system.build.toplevel --print-out-paths --out-link "${WORK_DIR}/result-trfwsl")
echo "    trfwsl: ${TRFWSL_PATH}"

# ── Phase 3: Push to Attic ──────────────────────────────────────────────
echo "==> Phase 3: Pushing to Attic cache"
attic push "${ATTIC_CACHE}" "${TRFWSL_PATH}"

# ── Phase 4: Switch trfwsl ──────────────────────────────────────────────
echo "==> Phase 4: Switching trfwsl"
nixos-rebuild switch --flake .#trfwsl

echo "==> Done"
