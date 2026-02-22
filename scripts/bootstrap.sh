#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/tomrfitz/nix-config.git}"
REPO_DIR="${REPO_DIR:-$HOME/nix-config}"
NIX_INSTALL_URL="${NIX_INSTALL_URL:-https://install.lix.systems/lix}"

platform="$(uname -s)"

info() { printf '\033[1;34m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m==> %s\033[0m\n' "$*"; }
ok() { printf '\033[1;32m==> %s\033[0m\n' "$*"; }
die() {
    printf '\033[1;31m==> %s\033[0m\n' "$*" >&2
    exit 1
}

usage() {
    cat <<EOF
Usage: $(basename "$0") [hostname]

Bootstrap this nix-config on macOS (nix-darwin) or NixOS/NixOS-WSL.

Optional args:
  hostname    Flake host to activate (defaults to local hostname)

Environment overrides:
  REPO_URL          Git URL to clone/pull (default: $REPO_URL)
  REPO_DIR          Local checkout path (default: $REPO_DIR)
  NIX_INSTALL_URL   Lix installer URL (default: $NIX_INSTALL_URL)
EOF
}

have_cmd() {
    command -v "$1" >/dev/null 2>&1
}

is_nixos() {
    [[ -f /etc/NIXOS ]]
}

is_wsl() {
    [[ -n ${WSL_DISTRO_NAME:-} ]] || grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null
}

nix_cmd() {
    nix --extra-experimental-features "nix-command flakes" "$@"
}

source_nix_profile() {
    local nix_profile_script
    for nix_profile_script in \
        /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh \
        /nix/var/nix/profiles/default/etc/profile.d/nix.sh \
        /etc/profile.d/nix.sh; do
        if [[ -e $nix_profile_script ]]; then
            # shellcheck disable=SC1090
            . "$nix_profile_script"
            return 0
        fi
    done
    return 1
}

ensure_platform_supported() {
    case "$platform" in
    Darwin)
        return 0
        ;;
    Linux)
        if is_nixos; then
            return 0
        fi
        if is_wsl; then
            die "Detected WSL without NixOS. Install NixOS-WSL first: https://nix-community.github.io/NixOS-WSL/install.html"
        fi
        die "Detected non-NixOS Linux. This bootstrap targets nix-darwin and NixOS/NixOS-WSL hosts."
        ;;
    *)
        die "Unsupported platform: $platform"
        ;;
    esac
}

ensure_xcode_clt() {
    [[ $platform == "Darwin" ]] || return 0
    if xcode-select -p >/dev/null 2>&1; then
        return 0
    fi

    info "Requesting Xcode Command Line Tools installation..."
    xcode-select --install || true
    die "Finish Xcode Command Line Tools installation, then rerun this script."
}

ensure_nix() {
    if have_cmd nix; then
        return 0
    fi

    if [[ $platform == "Linux" ]] && is_nixos; then
        warn "NixOS detected but nix is not in PATH; attempting to source shell profile."
        source_nix_profile || true
        if have_cmd nix; then
            return 0
        fi
    fi

    if [[ $platform != "Darwin" ]]; then
        die "Nix is missing. On Linux, use this bootstrap only from NixOS/NixOS-WSL."
    fi

    have_cmd curl || die "curl is required to install Nix."
    info "Installing Lix..."
    curl -sSfL "$NIX_INSTALL_URL" | sh -s -- install

    source_nix_profile || true
    have_cmd nix || die "Lix installed but is not in PATH yet. Start a new shell and rerun."
}

sync_repo() {
    have_cmd git || die "git is required."

    if [[ -d $REPO_DIR/.git ]]; then
        if git -C "$REPO_DIR" diff --quiet && git -C "$REPO_DIR" diff --cached --quiet; then
            info "Updating existing nix-config checkout (fast-forward only)..."
            git -C "$REPO_DIR" pull --ff-only
        else
            warn "Repository at $REPO_DIR has local changes; skipping git pull."
        fi
        return 0
    fi

    if [[ -e $REPO_DIR ]]; then
        die "$REPO_DIR exists but is not a git repository."
    fi

    info "Cloning nix-config..."
    git clone "$REPO_URL" "$REPO_DIR"
    ok "Repository cloned to $REPO_DIR"
}

default_hostname() {
    if [[ $platform == "Darwin" ]]; then
        scutil --get LocalHostName 2>/dev/null || hostname -s
    else
        hostname -s
    fi
}

list_hosts() {
    local attrset="$1"
    nix_cmd eval ".#${attrset}" --apply builtins.attrNames --json 2>/dev/null || echo "[]"
}

apply_darwin() {
    local host="$1"
    local tmp_dir out_link
    tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/nix-config-bootstrap.XXXXXX")"
    out_link="$tmp_dir/system"
    trap 'rm -rf "$tmp_dir"' EXIT

    info "Building nix-darwin system for host: $host"
    nix_cmd build ".#darwinConfigurations.${host}.system" --out-link "$out_link"

    info "Activating nix-darwin system..."
    sudo "$out_link/sw/bin/darwin-rebuild" switch --flake ".#${host}"

    rm -rf "$tmp_dir"
    trap - EXIT
}

apply_nixos() {
    local host="$1"
    info "Applying NixOS system for host: $host"
    sudo nixos-rebuild switch --flake ".#${host}"
}

main() {
    if [[ ${1:-} == "--help" || ${1:-} == "-h" ]]; then
        usage
        exit 0
    fi
    [[ $# -le 1 ]] || die "Too many arguments. Use --help for usage."

    ensure_platform_supported
    ensure_xcode_clt
    ensure_nix

    nix_cmd --version >/dev/null || die "Nix is installed but not functional."

    sync_repo
    mkdir -p "$HOME/.ssh"

    cd "$REPO_DIR"

    local host
    host="${1:-$(default_hostname)}"
    [[ $host =~ ^[A-Za-z0-9._-]+$ ]] || die "Invalid hostname: $host"

    if [[ $platform == "Darwin" ]]; then
        if ! nix_cmd eval --raw ".#darwinConfigurations.${host}.config.networking.hostName" >/dev/null 2>&1; then
            warn "Darwin host '$host' not found in flake."
            warn "Available darwin hosts: $(list_hosts darwinConfigurations)"
            die "Pick a listed host or pass one explicitly: $(basename "$0") <hostname>"
        fi
        apply_darwin "$host"
    else
        if ! nix_cmd eval --raw ".#nixosConfigurations.${host}.config.system.build.toplevel.drvPath" >/dev/null 2>&1; then
            warn "NixOS host '$host' not found in flake."
            warn "Available nixos hosts: $(list_hosts nixosConfigurations)"
            die "Pick a listed host or pass one explicitly: $(basename "$0") <hostname>"
        fi
        apply_nixos "$host"
    fi

    echo ""
    ok "Bootstrap finished for host: $host"
    echo ""
    echo "Remaining manual steps:"
    echo "  1. Sign into 1Password (SSH agent + git signing)"

    if [[ $platform == "Darwin" ]]; then
        echo "  2. Sign into Apple ID for Mac App Store apps"
        echo "  3. Run: gh auth login"
        echo "  4. Install Xcode app: xcodes install --latest"
    else
        echo "  2. Run: gh auth login"
    fi
}

main "$@"
