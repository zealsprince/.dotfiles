#!/bin/zsh
# Nix plugin loader shim for Zsh
# ==============================
#
# Goal:
#   Allow this dotfiles repo to work well on BOTH:
#     1) Nix / Home Manager systems (plugins/themes provided declaratively)
#     2) Non-Nix systems (Oh My Zsh fallback / manual installations)
#
# How it works:
#   - If a manager (Home Manager/Nix/etc.) sets environment variables pointing at
#     plugin/theme entrypoints, this file will source them.
#   - If those vars are not set, this file becomes a no-op and your existing
#     Oh My Zsh configuration can continue to work unchanged.
#
# Recommended usage in ~/.zshrc (early, before sourcing oh-my-zsh.sh):
#   [[ -r "$HOME/.dotfiles/zsh/nix.zsh" ]] && source "$HOME/.dotfiles/zsh/nix.zsh"
#
# Conventions:
#   - This file never hardcodes /nix/store paths.
#   - It only consumes environment variables if present.
#
# Environment variables (optional):
#   ZDOTFILES_NIX_DISABLE=1            Disable this shim entirely.
#
# Standardized ZDOTFILES variables (preferred):
#   ZDOTFILES_ZSH_P10K_THEME             Path to powerlevel10k theme file (optional)
#   ZDOTFILES_ZSH_AUTOSUGGESTIONS        Path to zsh-autosuggestions init file
#   ZDOTFILES_ZSH_SYNTAX_HIGHLIGHTING    Path to zsh-syntax-highlighting init file
#   ZDOTFILES_ZSH_256COLOR               Path to zsh-256color init file
#   ZDOTFILES_ZSH_GITHUB_COPILOT         Path to zsh-github-copilot init file (optional)
#   ZDOTFILES_ZSH_CODEX                  Path to zsh_codex init file (optional)
#
# Back-compat variables (accepted but deprecated):
#   ZSH_NIX_THEME_P10K
#   ZSH_NIX_PLUGIN_AUTOSUGGESTIONS
#   ZSH_NIX_PLUGIN_SYNTAX_HIGHLIGHTING
#   ZSH_NIX_PLUGIN_256COLOR
#   ZSH_NIX_PLUGIN_GH_COPILOT
#   ZSH_NIX_PLUGIN_CODEX
#
# Notes:
#   - Some plugins must be sourced at the end (notably syntax-highlighting).
#   - This shim tries to avoid breaking interactive shells if a file is missing.

# Only run in interactive shells.
[[ -o interactive ]] || return 0

# Allow opt-out.
if [[ "${ZDOTFILES_NIX_DISABLE:-0}" == "1" || "${ZDOTFILES_NIX_DISABLE:-0}" == "true" ]]; then
  return 0
fi

# Small helper: source a file if it exists, otherwise no-op.
__zdot_source_if_readable() {
  local label="$1"
  local path="$2"

  [[ -n "$path" ]] || return 0
  if [[ -r "$path" ]]; then
    source "$path"
    return 0
  fi

  # Don't spam on every shell start; just warn once per session.
  if [[ -z "${__ZDOTFILES_NIX_WARNED:-}" ]]; then
    __ZDOTFILES_NIX_WARNED=1
    print -u2 -- "warning: nix.zsh: expected ${label} at '$path' but it is not readable"
  fi
  return 0
}

# Resolve standardized variables first, fall back to legacy names.
__zdot_var() {
  local preferred="$1"
  local legacy="$2"

  if [[ -n "${(P)preferred:-}" ]]; then
    print -r -- "${(P)preferred}"
    return 0
  fi

  if [[ -n "${(P)legacy:-}" ]]; then
    print -r -- "${(P)legacy}"
    return 0
  fi

  print -r -- ""
  return 0
}

# Theme: powerlevel10k
# If a Nix-provided theme path is supplied, source it (this can replace OMZ theme lookup).
__zdot_source_if_readable "powerlevel10k theme (ZDOTFILES_ZSH_P10K_THEME)" "$(__zdot_var ZDOTFILES_ZSH_P10K_THEME ZSH_NIX_THEME_P10K)"

# Plugins that can be sourced early/mid:
__zdot_source_if_readable "zsh-autosuggestions (ZDOTFILES_ZSH_AUTOSUGGESTIONS)" "$(__zdot_var ZDOTFILES_ZSH_AUTOSUGGESTIONS ZSH_NIX_PLUGIN_AUTOSUGGESTIONS)"
__zdot_source_if_readable "zsh-256color (ZDOTFILES_ZSH_256COLOR)" "$(__zdot_var ZDOTFILES_ZSH_256COLOR ZSH_NIX_PLUGIN_256COLOR)"
__zdot_source_if_readable "zsh-github-copilot (ZDOTFILES_ZSH_GITHUB_COPILOT)" "$(__zdot_var ZDOTFILES_ZSH_GITHUB_COPILOT ZSH_NIX_PLUGIN_GH_COPILOT)"
__zdot_source_if_readable "zsh_codex (ZDOTFILES_ZSH_CODEX)" "$(__zdot_var ZDOTFILES_ZSH_CODEX ZSH_NIX_PLUGIN_CODEX)"

# Syntax highlighting should generally be loaded after other plugins and completion setup.
# This is still "early enough" if you source nix.zsh before oh-my-zsh.sh, because OMZ may
# later load its own copy if it's also present. If that becomes an issue, we can move this
# to a "late" hook in your .zshrc.
__zdot_source_if_readable "zsh-syntax-highlighting (ZDOTFILES_ZSH_SYNTAX_HIGHLIGHTING)" "$(__zdot_var ZDOTFILES_ZSH_SYNTAX_HIGHLIGHTING ZSH_NIX_PLUGIN_SYNTAX_HIGHLIGHTING)"

unset -f __zdot_var

# End of nix shim.
return 0
