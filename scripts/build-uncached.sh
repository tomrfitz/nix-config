#!/usr/bin/env bash
# Build the derivations of an installable that no configured cache has, keeping
# only those whose name matches an allowlist, without realising the installable
# itself. CI runs this for trfmbp (.github/workflows/check.yml, the darwin
# job) so the expensive, free builds land in Cachix:
#   - Not the whole system: realising trfmbp on a fresh runner fetches
#     ~19.5 GiB unpacked just to assemble it, while each allowlisted build
#     pulls in only its own inputs.
#   - An allowlist rather than everything uncached: unfree apps repackaged from
#     vendor downloads (Hydra builds no unfree packages) are uncached too, and
#     a public cache must not redistribute them. They are also just downloads,
#     so caching them saves the Mac nothing.
#
# Usage: build-uncached.sh [--list] <installable> <name-regex> [nix args...]
#   --list   print the selection and build nothing
set -euo pipefail

list_only=false
if [[ ${1-} == --list ]]; then
    list_only=true
    shift
fi
installable=${1:?usage: build-uncached.sh [--list] <installable> <name-regex> [nix args...]}
pattern=${2:?usage: build-uncached.sh [--list] <installable> <name-regex> [nix args...]}
shift 2

# A dry run asks the substituters what this store would have to build.
uncached=$(
    nix build --dry-run "$@" "$installable" 2>&1 |
        awk '/will be built:/ { f = 1; next } /will be fetched/ { f = 0 } f { print $1 }'
)
selected=$(
    printf '%s\n' "$uncached" |
        awk -v re="^(${pattern})" '{ n = $0; sub(/^\/nix\/store\/[a-z0-9]+-/, "", n); sub(/\.drv$/, "", n); if (n ~ re) print $0 }'
)
total=$(printf '%s\n' "$uncached" | grep -c . || true)
count=$(printf '%s\n' "$selected" | grep -c . || true)

echo "==> ${total} uncached derivations, ${count} allowlisted:"
printf '%s\n' "$selected" | sed -E 's|^/nix/store/[a-z0-9]+-|    |; s|\.drv$||'
if [[ -n ${GITHUB_STEP_SUMMARY-} ]]; then
    printf '%s uncached derivations, %s allowlisted and built.\n' "$total" "$count" >>"$GITHUB_STEP_SUMMARY"
fi

if $list_only || [[ $count -eq 0 ]]; then
    exit 0
fi
# --keep-going: one broken package shouldn't keep the rest out of the cache.
# shellcheck disable=SC2046 # one argument per derivation
nix build --no-link --keep-going "$@" $(printf '%s\n' "$selected" | sed 's/$/^*/')
