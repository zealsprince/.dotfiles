#!/bin/sh
# Install scripts from this repo's bin/ into ~/.local/bin
#
# Goals:
# - Be safe to run multiple times (idempotent)
# - Prefer symlinks so updates to the repo are picked up immediately
# - Fall back to copying if symlinks are not possible
#
# Usage:
#   sh setup.sh
#
# Optional env vars:
#   DOTFILES_BIN_MODE=symlink|copy   (default: symlink)
#   DOTFILES_BIN_DEST=/some/path     (default: ~/.local/bin)

set -eu

MODE="${DOTFILES_BIN_MODE:-symlink}"
DEST="${DOTFILES_BIN_DEST:-$HOME/.local/bin}"

# Resolve the directory this script lives in (portable).
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"

# This setup script is intended to live in the repo's bin/ directory.
SRC_DIR="$SCRIPT_DIR"

mkdir -p "$DEST"
chmod 755 "$DEST" 2>/dev/null || true

is_executable() {
  [ -f "$1" ] && [ -x "$1" ]
}

install_symlink() {
  src="$1"
  dst="$2"

  # Replace existing file/symlink if it exists.
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    rm -f "$dst"
  fi

  ln -s "$src" "$dst"
}

install_copy() {
  src="$1"
  dst="$2"

  # Copy and preserve mode; ensure executable.
  cp -f "$src" "$dst"
  chmod 755 "$dst" 2>/dev/null || true
}

echo "Installing scripts from: $SRC_DIR"
echo "Into: $DEST"
echo "Mode: $MODE"
echo

case "$MODE" in
  symlink|copy) : ;;
  *)
    echo "ERROR: DOTFILES_BIN_MODE must be 'symlink' or 'copy' (got: $MODE)" >&2
    exit 2
    ;;
esac

# Iterate over all regular files in bin/ (excluding this setup script).
# Install only executables by default so we don't pollute PATH with docs/assets.
installed=0
skipped=0

for src in "$SRC_DIR"/*; do
  name="$(basename -- "$src")"

  # Skip non-files
  [ -f "$src" ] || continue

  # Skip this script
  if [ "$name" = "setup.sh" ]; then
    continue
  fi

  if ! is_executable "$src"; then
    echo "skip  (not executable): $name"
    skipped=$((skipped + 1))
    continue
  fi

  dst="$DEST/$name"

  if [ "$MODE" = "symlink" ]; then
    # If symlink fails (e.g. no permissions, filesystem limitations), fall back to copy.
    if install_symlink "$src" "$dst" 2>/dev/null; then
      echo "link  $name -> $dst"
    else
      install_copy "$src" "$dst"
      echo "copy  $name -> $dst (symlink failed)"
    fi
  else
    install_copy "$src" "$dst"
    echo "copy  $name -> $dst"
  fi

  installed=$((installed + 1))
done

echo
echo "Done. Installed: $installed, Skipped: $skipped"
echo "Ensure '$HOME/.local/bin' is on your PATH."
