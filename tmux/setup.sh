#!/bin/sh
set -eu

# -----------------------------------------------------------------------------
# tmux/setup.sh
#
# Installs the Tmux Plugin Manager (TPM) and links the repo tmux config into
# $HOME as ~/.tmux.conf.
#
# Usage:
#   ./setup.sh
#
# Optional env:
#   DOTFILES_ROOT  Path to dotfiles repo root (default: parent of this script)
#   FORCE=1        Overwrite existing ~/.tmux.conf (backs up first)
# -----------------------------------------------------------------------------

msg() { printf '%s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
DOTFILES_ROOT="${DOTFILES_ROOT:-"$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"}"

TMUX_CONF_SRC="$DOTFILES_ROOT/tmux/.tmux.conf"
TMUX_CONF_DST="$HOME/.tmux.conf"

TPM_DIR="$HOME/.tmux/plugins/tpm"
TPM_REPO="https://github.com/tmux-plugins/tpm"

[ -f "$TMUX_CONF_SRC" ] || die "missing source tmux config: $TMUX_CONF_SRC"

# Ensure plugin directory exists
mkdir -p "$(dirname "$TPM_DIR")"

# Install / update TPM
if [ -d "$TPM_DIR/.git" ]; then
  msg "TPM already present at: $TPM_DIR"
  # Best-effort update
  if command -v git >/dev/null 2>&1; then
    (cd "$TPM_DIR" && git pull --ff-only) || warn "could not update TPM (continuing)"
  else
    warn "git not found; cannot update TPM (continuing)"
  fi
else
  command -v git >/dev/null 2>&1 || die "git is required to install TPM"
  msg "Installing TPM into: $TPM_DIR"
  git clone --depth=1 "$TPM_REPO" "$TPM_DIR"
fi

# Link ~/.tmux.conf
if [ -e "$TMUX_CONF_DST" ] || [ -L "$TMUX_CONF_DST" ]; then
  if [ "${FORCE:-0}" = "1" ]; then
    TS="$(date +%Y%m%d%H%M%S 2>/dev/null || printf 'backup')"
    BK="${TMUX_CONF_DST}.backup.${TS}"
    msg "Backing up existing $TMUX_CONF_DST -> $BK"
    mv -f "$TMUX_CONF_DST" "$BK"
  else
    if [ -L "$TMUX_CONF_DST" ] && [ "$(readlink "$TMUX_CONF_DST" 2>/dev/null || true)" = "$TMUX_CONF_SRC" ]; then
      msg "tmux config already linked: $TMUX_CONF_DST -> $TMUX_CONF_SRC"
      msg "Done."
      exit 0
    fi
    die "$TMUX_CONF_DST already exists. Re-run with FORCE=1 to replace it."
  fi
fi

ln -s "$TMUX_CONF_SRC" "$TMUX_CONF_DST"
msg "Linked: $TMUX_CONF_DST -> $TMUX_CONF_SRC"

msg "Done."
msg "Next: start tmux and press prefix + I to install plugins (TPM)."
