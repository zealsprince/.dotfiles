#!/bin/sh
set -eu

# ------------------------------------------------------------------------------
# .dotfiles/zsh/setup.sh
#
# Purpose:
#   Lightweight, repeatable setup for Zsh-related dotfiles.
#
# What it does (by default):
#   - Prints what it would do (safe / non-destructive by default).
#   - Can optionally install/symlink Zsh dotfiles into $HOME.
#   - Can optionally install Oh My Zsh + common plugins/themes used by this repo.
#
# Philosophy:
#   - Keep "what to install" here; keep "how it's deployed on NixOS" in .nixos.
#   - Never overwrite files unless explicitly asked.
#
# Usage:
#   ./setup.sh
#   ./setup.sh --help
#   ./setup.sh --install-dotfiles
#   ./setup.sh --install-omz
#   ./setup.sh --install-plugins
#   ./setup.sh --all
#
# Notes:
#   - On NixOS/Home Manager you likely DON'T need --install-dotfiles because
#     ~/.zshrc and friends are symlinked by Home Manager already.
#   - This script is intended to be portable to non-Nix systems.
# ------------------------------------------------------------------------------

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"
DOTFILES_ROOT="$(CDPATH= cd -- "${SCRIPT_DIR}/.." && pwd -P)"

log()  { printf '%s\n' "$*" >&2; }
die()  { log "error: $*"; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

usage() {
  cat <<'EOF'
zsh/setup.sh - bootstrap Zsh dotfiles and optional Oh My Zsh dependencies

Options:
  --install-dotfiles   Symlink .zshrc/.p10k.zsh/.dircolors/.osxcolors into $HOME
                       (safe: refuses to overwrite existing files)
  --install-omz        Install Oh My Zsh (unattended) to ~/.oh-my-zsh if missing
  --install-plugins    Install plugins/themes used by this repo (powerlevel10k,
                       zsh-autosuggestions) into Oh My Zsh custom dirs
  --all                Equivalent to: --install-dotfiles --install-omz --install-plugins
  --force              Allow overwriting existing target files/symlinks
  --dry-run            Print actions without making changes (default)
  --apply              Actually perform changes
  -h, --help           Show this help

Environment:
  HOME                 Target home directory (defaults to current user HOME)
  ZSH_CUSTOM           Oh My Zsh custom directory override
  DOTFILES_ROOT        Dotfiles repo root override (defaults to repo root)

Examples:
  # Preview actions:
  ./setup.sh --all

  # Install OMZ + plugins (no dotfile symlinks) on a non-Nix system:
  ./setup.sh --install-omz --install-plugins --apply

  # Force update symlinks (dangerous):
  ./setup.sh --install-dotfiles --force --apply
EOF
}

MODE="dry-run"
FORCE="0"
DO_DOTFILES="0"
DO_OMZ="0"
DO_PLUGINS="0"

while [ "${1:-}" != "" ]; do
  case "$1" in
    --install-dotfiles) DO_DOTFILES="1" ;;
    --install-omz)      DO_OMZ="1" ;;
    --install-plugins)  DO_PLUGINS="1" ;;
    --all)              DO_DOTFILES="1"; DO_OMZ="1"; DO_PLUGINS="1" ;;
    --force)            FORCE="1" ;;
    --dry-run)          MODE="dry-run" ;;
    --apply)            MODE="apply" ;;
    -h|--help)          usage; exit 0 ;;
    *)                  die "unknown argument: $1" ;;
  esac
  shift
done

# Default behavior: if you run without flags, just show help-ish summary.
if [ "$DO_DOTFILES" = "0" ] && [ "$DO_OMZ" = "0" ] && [ "$DO_PLUGINS" = "0" ]; then
  log "No actions selected. Use --help for options."
  log "Tip: try --all (dry-run by default), then add --apply."
  exit 0
fi

run() {
  if [ "$MODE" = "dry-run" ]; then
    log "[dry-run] $*"
    return 0
  fi
  log "[run] $*"
  # shellcheck disable=SC2086
  sh -c "$*"
}

symlink_safe() {
  src="$1"
  dst="$2"

  [ -e "$src" ] || die "source does not exist: $src"

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if [ "$FORCE" = "1" ]; then
      run "rm -rf -- \"$dst\""
    else
      die "target exists (use --force to overwrite): $dst"
    fi
  fi

  run "ln -s -- \"$src\" \"$dst\""
}

install_dotfiles() {
  log "==> Installing Zsh dotfiles symlinks into \$HOME"
  symlink_safe "${DOTFILES_ROOT}/zsh/.zshrc"      "${HOME}/.zshrc"
  symlink_safe "${DOTFILES_ROOT}/zsh/.p10k.zsh"   "${HOME}/.p10k.zsh"
  symlink_safe "${DOTFILES_ROOT}/zsh/.dircolors"  "${HOME}/.dircolors"

  # This file name suggests macOS-specific colors; okay to symlink everywhere.
  # If you don't want it on Linux, just skip this step locally.
  symlink_safe "${DOTFILES_ROOT}/zsh/.osxcolors"  "${HOME}/.osxcolors"
}

install_omz() {
  log "==> Ensuring Oh My Zsh is installed"
  if [ -d "${HOME}/.oh-my-zsh" ]; then
    log "Oh My Zsh already present at ${HOME}/.oh-my-zsh"
    return 0
  fi

  have git || die "git is required to install Oh My Zsh"
  have zsh || log "warning: zsh not found in PATH (install it via your package manager)"

  # Unattended install; does not auto-switch shells.
  run "git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git \"${HOME}/.oh-my-zsh\""
}

install_plugins() {
  log "==> Installing Zsh plugins/themes used by this repo"
  have git || die "git is required to install plugins"

  OMZ_DIR="${HOME}/.oh-my-zsh"
  if [ ! -d "$OMZ_DIR" ]; then
    die "Oh My Zsh not found at ${OMZ_DIR}. Run with --install-omz first."
  fi

  # Determine custom dir
  ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-${OMZ_DIR}/custom}"
  run "mkdir -p \"${ZSH_CUSTOM_DIR}/themes\" \"${ZSH_CUSTOM_DIR}/plugins\""

  # Powerlevel10k theme
  if [ ! -d "${ZSH_CUSTOM_DIR}/themes/powerlevel10k" ]; then
    run "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \"${ZSH_CUSTOM_DIR}/themes/powerlevel10k\""
  else
    log "powerlevel10k already present"
  fi

  # zsh-autosuggestions plugin
  if [ ! -d "${ZSH_CUSTOM_DIR}/plugins/zsh-autosuggestions" ]; then
    run "git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git \"${ZSH_CUSTOM_DIR}/plugins/zsh-autosuggestions\""
  else
    log "zsh-autosuggestions already present"
  fi

  log "Note: this repo also contains zsh/plugins.sh. If you prefer that exact behavior,"
  log "      review it and run it manually."
}

log "DOTFILES_ROOT=${DOTFILES_ROOT}"
log "MODE=${MODE}"
log "FORCE=${FORCE}"

if [ "$DO_OMZ" = "1" ]; then
  install_omz
fi

if [ "$DO_PLUGINS" = "1" ]; then
  install_plugins
fi

if [ "$DO_DOTFILES" = "1" ]; then
  install_dotfiles
fi

log "Done."
