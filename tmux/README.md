
# Tmux #

This is my setup for Tmux including the Tmux Plugin Manager (TPM).

## Installation ##

Preferred:

- Run `./setup.sh` in this directory.

This will:

- install (or update) TPM into `~/.tmux/plugins/tpm`
- symlink `~/.tmux.conf` to the repo version (`tmux/.tmux.conf`)

If `~/.tmux.conf` already exists, `setup.sh` will refuse to overwrite it unless you re-run with:

- `FORCE=1 ./setup.sh`

## Next steps ##

After running setup:

- start tmux
- press `prefix` + `I` (capital i) to install plugins via TPM

## Nix machines ##

Home Manager links the conf and writes `~/.tmux/nix-plugins.conf` with the same
plugin list built from nixpkgs, so there is no TPM and no `prefix` + `I` step.
That list lives in `home.nix` in the `.nixos` repo and has to stay in step with
the `set -g @plugin` lines here.
