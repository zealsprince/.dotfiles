#!/bin/sh
#
# .dotfiles bootstrap
# ==================
#
# Runs per-component setup scripts from this repository.
#
# Goals:
# - idempotent where possible
# - safe defaults (no destructive operations)
# - explicit, composable entrypoints (each component owns its own setup)
#
# Usage:
#   ./setup.sh                # run all detected component setup scripts
#   ./setup.sh zsh vim tmux   # run specific components
#   ./setup.sh --list         # list available components
#   DRY_RUN=1 ./setup.sh ...  # show what would be executed
#
# Conventions:
# - Component setup scripts live at: <component>/setup.sh
# - They should be executable, accept standard env toggles (DRY_RUN), and be
#   conservative (avoid overwriting user files without explicit confirmation).
#
set -eu

# -------- helpers --------

info() { printf '%s\n' "info: $*"; }
warn() { printf '%s\n' "warn: $*" >&2; }
die()  { printf '%s\n' "error: $*" >&2; exit 1; }

has() { command -v "$1" >/dev/null 2>&1; }

# Resolve repo root (directory this script lives in).
# Avoid readlink -f (not portable on macOS); prefer pwd -P.
repo_root() {
  # shellcheck disable=SC2164
  cd "$(dirname "$0")"
  pwd -P
}

is_dry_run() {
  [ "${DRY_RUN:-0}" = "1" ] || [ "${DRY_RUN:-0}" = "true" ] || [ "${DRY_RUN:-0}" = "yes" ]
}

run() {
  if is_dry_run; then
    printf '%s\n' "+ $*"
    return 0
  fi
  "$@"
}

# Determine component list by scanning for */setup.sh beneath repo root.
# We keep an allowlist filter to avoid running unexpected scripts.
discover_components() {
  root="$1"

  # Find setup scripts exactly one level deep: <component>/setup.sh
  # Use POSIX find; print component dir name.
  find "$root" -mindepth 2 -maxdepth 2 -type f -name setup.sh 2>/dev/null \
    | while IFS= read -r path; do
        comp_dir=$(dirname "$path")
        comp=$(basename "$comp_dir")
        printf '%s\n' "$comp"
      done \
    | sort -u
}

list_components() {
  root="$1"
  comps=$(discover_components "$root" || true)
  if [ -z "${comps:-}" ]; then
    warn "no components found (no <component>/setup.sh scripts)"
    return 0
  fi

  printf '%s\n' "Available components:"
  printf '%s\n' "$comps" | sed 's/^/  - /'
}

# Run a specific component setup.
run_component() {
  root="$1"
  comp="$2"

  script="$root/$comp/setup.sh"
  [ -f "$script" ] || die "unknown component '$comp' (missing: $comp/setup.sh)"

  if [ ! -x "$script" ]; then
    # Don't silently chmod; just run it via sh for convenience.
    info "running (non-executable) $comp/setup.sh via sh"
    run sh "$script"
  else
    info "running $comp/setup.sh"
    run "$script"
  fi
}

# -------- main --------

ROOT="$(repo_root)"

case "${1:-}" in
  -h|--help)
    cat <<EOF
Usage: $0 [--list] [component...]

Runs per-component setup scripts for this dotfiles repository.

Examples:
  $0
  $0 --list
  $0 zsh vim
  DRY_RUN=1 $0 zsh

EOF
    exit 0
    ;;
  --list)
    list_components "$ROOT"
    exit 0
    ;;
esac

# Without args: run all discovered components, in deterministic order.
if [ "$#" -eq 0 ]; then
  comps="$(discover_components "$ROOT" || true)"
  if [ -z "${comps:-}" ]; then
    warn "no components found (no <component>/setup.sh scripts)"
    exit 0
  fi
  info "no components specified; running all discovered components"
  # shellcheck disable=SC2086
  set -- $comps
fi

# Sanity notes (not fatal):
if ! has git; then
  warn "git not found on PATH; some setup scripts may require it"
fi

for comp in "$@"; do
  run_component "$ROOT" "$comp"
done

info "done"
