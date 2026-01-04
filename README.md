# .dotfiles

This repository contains my **dotfiles** (CLI-focused configuration) such as:

- `zsh/` - Zsh configuration (`.zshrc`, `p10k`, themes, plugins/scripts, dircolors)
- `tmux/` - tmux configuration (`.tmux.conf`)
- `vim/` - vim configuration (`.vimrc` + related assets)
- `bin/` - personal scripts intended to be on `$PATH`
- `base16-shell/` - theme assets + setup helper

## Setup entrypoints

Each component can provide a `setup.sh` so there’s a consistent entrypoint when bootstrapping on non-Nix systems (or when you want to reinitialize dependencies like plugin managers).

- Top-level bootstrap (runs component setup scripts):
  - `./setup.sh --list`
  - `./setup.sh zsh vim tmux bin base16-shell`
  - `DRY_RUN=1 ./setup.sh …`

Component scripts (examples):
- `zsh/setup.sh` - optional Oh My Zsh + plugin install, optional dotfile linking
- `vim/setup.sh` - installs vim-plug and links `~/.vimrc`
- `tmux/setup.sh` - installs TPM and links `~/.tmux.conf`
- `bin/setup.sh` - installs scripts into `~/.local/bin` (symlink or copy)
- `base16-shell/setup.sh` - installs base16-shell and theme assets

## How I apply these (Nix/Home Manager)

These files are deployed via my Nix/Home Manager configuration in the `.nixos` repository.

- `.zshrc`, `.p10k.zsh`, `.dircolors`, `.osxcolors` are linked into `$HOME`
- `.tmux.conf` is linked into `$HOME`
- `.vimrc` is linked into `$HOME`
- scripts under `bin/` are installed to `~/.local/bin`

In other words: this repo is the **source of truth** for the dotfiles, and Home Manager is the **deployment layer** that keeps them consistently installed.

## Relationship to `neko-config`

If you're looking for just application configuration [neko-config](https://github.com/zealsprince/neko-config) is the place to go.
