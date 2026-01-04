
# Vim Configuration #

This is my primary setup for Vim on both my local machines as well as my
servers.

## Installation ##

The recommended entrypoint is the component setup script:

- `./setup.sh` (from this `vim/` directory)

What it does:

- Installs vim-plug to `~/.vim/autoload/plug.vim` (if missing)
- Symlinks `~/.vimrc` to the repo version (`vim/.vimrc`)
- Optionally links `base16-neko.vim` into `~/.vim/colors/base16-neko.vim`

Then launch Vim and run:

- `:PluginInstall`

### Minimal / server config

The minimal server configuration is available as `.vimrc.min`.

To use it with the setup script:

- `VIMRC_SOURCE=<repo>/vim/.vimrc.min ./setup.sh`

## Notes ##

If you are using gvim on Windows replace the corresponding `_vimrc` file.
