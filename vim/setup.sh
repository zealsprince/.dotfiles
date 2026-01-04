#!/bin/sh
set -eu

# Vim setup for this dotfiles repo.
#
# What this does:
#  - installs Vim plugin manager (vim-plug) to ~/.vim/autoload/plug.vim if missing
#  - symlinks ~/.vimrc -> <repo>/vim/.vimrc  (backs up existing file first)
#  - optionally links base16 color asset into ~/.vim/colors/base16-neko.vim
#  - prints next steps for plugin install
#
# Usage:
#   ./setup.sh
#
# Optional env vars:
#   VIMRC_SOURCE   Path to vimrc to link (default: <repo>/vim/.vimrc)
#   INSTALL_PLUG   Set to "0" to skip vim-plug install (default: 1)
#   INSTALL_COLORS Set to "0" to skip colors link (default: 1)

INSTALL_PLUG="${INSTALL_PLUG:-1}"
INSTALL_COLORS="${INSTALL_COLORS:-1}"

repo_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"
vimrc_src="${VIMRC_SOURCE:-$repo_dir/.vimrc}"

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "error: required command not found: $1" >&2
    exit 1
  fi
}

timestamp() {
  # Portable-ish timestamp for backups
  date +"%Y%m%d-%H%M%S"
}

backup_if_exists() {
  path="$1"
  if [ -e "$path" ] || [ -L "$path" ]; then
    # If it already points to our desired target, nothing to do.
    if [ -L "$path" ] && [ "$(readlink "$path")" = "$2" ]; then
      return 0
    fi
    bak="${path}.backup.$(timestamp)"
    echo "Backing up $path -> $bak"
    mv "$path" "$bak"
  fi
}

link_file() {
  src="$1"
  dst="$2"
  if [ ! -e "$src" ]; then
    echo "error: source file does not exist: $src" >&2
    exit 1
  fi

  backup_if_exists "$dst" "$src"
  echo "Linking $dst -> $src"
  ln -s "$src" "$dst"
}

ensure_dir() {
  d="$1"
  if [ ! -d "$d" ]; then
    mkdir -p "$d"
  fi
}

install_plug() {
  if [ "$INSTALL_PLUG" = "0" ]; then
    echo "Skipping vim-plug install (INSTALL_PLUG=0)"
    return 0
  fi

  need_cmd curl
  plug_path="$HOME/.vim/autoload/plug.vim"
  if [ -f "$plug_path" ]; then
    echo "vim-plug already installed at $plug_path"
    return 0
  fi

  ensure_dir "$HOME/.vim/autoload"
  echo "Installing vim-plug to $plug_path"
  curl -fLo "$plug_path" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

install_colors() {
  if [ "$INSTALL_COLORS" = "0" ]; then
    echo "Skipping colors link (INSTALL_COLORS=0)"
    return 0
  fi

  colors_src="$repo_dir/base16-neko.vim"
  if [ -f "$colors_src" ]; then
    ensure_dir "$HOME/.vim/colors"
    colors_dst="$HOME/.vim/colors/base16-neko.vim"
    if [ -L "$colors_dst" ] && [ "$(readlink "$colors_dst")" = "$colors_src" ]; then
      echo "Colors already linked at $colors_dst"
    else
      backup_if_exists "$colors_dst" "$colors_src"
      echo "Linking $colors_dst -> $colors_src"
      ln -s "$colors_src" "$colors_dst"
    fi
  else
    echo "Note: colors source not found at $colors_src (skipping)"
  fi
}

main() {
  install_plug
  link_file "$vimrc_src" "$HOME/.vimrc"
  install_colors

  cat <<'EOF'

Done.

Next steps:
  1) Launch vim and run:
       :PlugInstall

Notes:
  - If you want the minimal config instead, set:
      VIMRC_SOURCE=<repo>/vim/.vimrc.min ./setup.sh
EOF
}

main "$@"
