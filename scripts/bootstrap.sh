#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/tomrfitz/nix-config.git"
REPO_DIR="$HOME/nix-config"
AGENIX_KEY="$HOME/.ssh/id_ed25519_agenix"

platform="$(uname -s)"

info() { printf '\033[1;34m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m==> %s\033[0m\n' "$*"; }
ok() { printf '\033[1;32m==> %s\033[0m\n' "$*"; }

# ── Phase 1: Prerequisites ──────────────────────────────────────────

if [[ $platform == "Darwin" ]]; then
    if ! xcode-select -p &>/dev/null; then
        info "Installing Xcode Command Line Tools..."
        xcode-select --install
        info "Waiting for CLT installation to complete..."
        until xcode-select -p &>/dev/null; do sleep 5; done
        ok "Xcode CLT installed"
    fi
fi

if ! command -v nix &>/dev/null; then
    if [[ $platform == "Linux" ]] && [[ -f /etc/NIXOS ]]; then
        # NixOS already has Nix — just need it in PATH
        warn "On NixOS but nix not in PATH. Sourcing profile..."
        # shellcheck disable=SC1091
        . /etc/profile
    else
        info "Installing Nix..."
        sh <(curl -L https://nixos.org/nix/install) --daemon
        # Source nix in current shell
        if [[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
            # shellcheck disable=SC1091
            . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        fi
        ok "Nix installed"
    fi
fi

# Enable flakes if not already configured (vanilla installer doesn't enable them)
if ! nix --version 2>/dev/null | grep -q "nix"; then
    warn "Nix not available after install. You may need to restart your shell and re-run this script."
    exit 1
fi

# ── Phase 2: Clone & prepare ────────────────────────────────────────

if [[ -d $REPO_DIR ]]; then
    warn "Repository already exists at $REPO_DIR — pulling latest"
    git -C "$REPO_DIR" pull
else
    info "Cloning nix-config..."
    git clone "$REPO_URL" "$REPO_DIR"
    ok "Repository cloned to $REPO_DIR"
fi

mkdir -p "$HOME/.ssh"

if [[ -f $AGENIX_KEY ]]; then
    warn "Agenix key already exists at $AGENIX_KEY"
else
    info "Generating agenix identity key..."
    ssh-keygen -t ed25519 -N "" -f "$AGENIX_KEY" -C "agenix@$(hostname -s)"
    ok "Agenix key generated"
    echo ""
    warn "Add this public key to secrets/secrets.nix on an existing machine,"
    warn "then run 'just rekey' and push to grant this machine access to secrets:"
    echo ""
    cat "${AGENIX_KEY}.pub"
    echo ""
fi

# ── Phase 3: First build ────────────────────────────────────────────

cd "$REPO_DIR"

# Accept a hostname argument, or auto-detect
hostname="${1:-$(scutil --get LocalHostName 2>/dev/null || hostname -s)}"

if [[ $platform == "Darwin" ]]; then
    info "Building darwin configuration for: $hostname"
    nix run nix-darwin -- switch --flake ".#${hostname}"
else
    info "Building NixOS configuration for: $hostname"
    sudo nixos-rebuild switch --flake ".#${hostname}"
fi

ok "Build complete"

# ── Phase 4: Post-build guidance ─────────────────────────────────────

echo ""
ok "Bootstrap finished. Remaining manual steps:"
echo ""
echo "  1. Sign into 1Password (enables SSH agent + git signing)"

if [[ $platform == "Darwin" ]]; then
    echo "  2. Sign into Apple ID for Mac App Store apps"
    echo "  3. Run: gh auth login"
    echo "  4. Install Xcode: xcodes install --latest"
else
    echo "  2. Run: gh auth login"
fi

echo ""
echo "  If this is a new machine, grant it access to agenix secrets:"
echo "    - Add the pubkey above to secrets/secrets.nix"
echo "    - Run: just rekey  (from a machine that can already decrypt)"
echo "    - Push, pull on this machine, and rebuild"
