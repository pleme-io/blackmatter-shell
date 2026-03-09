# fzf — minimal configuration for fzf-tab compatibility only.
#
# All keybindings (Ctrl+R, Ctrl+T, Ctrl+F, Alt+C) are handled by the
# skim plugin via dedicated Rust binaries. This file only provides:
#   1. FZF_DEFAULT_COMMAND for fzf-tab's file discovery fallback
#   2. fzf completion.zsh (** trigger for file completion)
#
# Do NOT source key-bindings.zsh — it would override skim's ZLE widgets.

# Use fd for file discovery (fzf-tab may use this for some completions)
if command -v fd &> /dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --strip-cwd-prefix'
fi

# Load fzf completion only (** trigger) — NOT keybindings
if [[ -z "$_BLZSH_FZF_KEYS_LOADED" ]] && command -v fzf &> /dev/null; then
  local fzf_bin fzf_real_path fzf_prefix
  fzf_bin="$(command -v fzf 2>/dev/null)"
  if [[ -n "$fzf_bin" ]]; then
    fzf_real_path="${fzf_bin:A}"
    fzf_prefix="${fzf_real_path:h:h}"

    local fzf_share=""
    if [[ "$fzf_prefix" == /nix/store/* && -d "$fzf_prefix/share/fzf" ]]; then
      fzf_share="$fzf_prefix/share/fzf"
    fi

    # Fallback locations
    if [[ -z "$fzf_share" ]]; then
      for path in /usr/share/fzf /usr/local/opt/fzf/shell "$HOME/.fzf/shell" /opt/homebrew/opt/fzf/shell; do
        if [[ -d "$path" ]]; then
          fzf_share="$path"
          break
        fi
      done
    fi

    # Only completion — NO key-bindings (skim handles those)
    if [[ -n "$fzf_share" && -f "$fzf_share/completion.zsh" ]]; then
      source "$fzf_share/completion.zsh"
    fi
  fi
fi
