# fzf - Fuzzy finder for command-line

# Nord-themed fzf configuration - Beautiful, performant, and Arctic
export FZF_DEFAULT_OPTS="
  --height 30%
  --layout=reverse
  --border=rounded
  --info=inline
  --prompt='❄ '
  --pointer='▶'
  --marker='✓'
  --ansi
  --bind='ctrl-/:toggle-preview'
  --bind='ctrl-u:preview-half-page-up'
  --bind='ctrl-d:preview-half-page-down'
  --preview-window='right:50%:hidden:wrap'
  --color=fg:#D8DEE9,bg:#2E3440,hl:#88C0D0
  --color=fg+:#ECEFF4,bg+:#3B4252,hl+:#8FBCBB
  --color=info:#81A1C1,prompt:#A3BE8C,pointer:#BF616A
  --color=marker:#B48EAD,spinner:#81A1C1,header:#5E81AC
  --color=border:#4C566A,label:#D8DEE9,query:#ECEFF4
  --color=gutter:#2E3440
  --separator='─'
  --scrollbar='│'
  --border-label-pos=2
"

# Use fd/rg for faster file finding (fallback to find if not available)
if command -v fd &> /dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --strip-cwd-prefix'
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git --strip-cwd-prefix'
  export FZF_CTRL_T_COMMAND='fd --type f --type d --hidden --follow --exclude .git --strip-cwd-prefix'
elif command -v rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
fi

# Ctrl+T: File/directory search with preview
export FZF_CTRL_T_OPTS="
  --preview 'if [ -d {} ]; then eza --tree --level=2 --icons --color=always {} 2>/dev/null || ls -la {}; else bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || cat {}; fi'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'
  --header 'CTRL-T: Files/Dirs | CTRL-/: Toggle Preview'
"

# Ctrl+R: Command history search with preview
export FZF_CTRL_R_OPTS="
  --preview 'echo {}'
  --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --header 'CTRL-R: History | CTRL-Y: Copy | CTRL-/: Toggle Preview'
  --color header:italic
"

# Alt+C: Directory search with tree preview
export FZF_ALT_C_OPTS="
  --preview 'eza --tree --level=2 --icons --color=always {} 2>/dev/null || ls -la {}'
  --header 'ALT-C: Change Directory'
"

# Load fzf keybindings — skipped when already loaded (e.g. blzsh sources from store path directly)
if [[ -z "$_BLZSH_FZF_KEYS_LOADED" ]] && command -v fzf &> /dev/null; then
  # Determine fzf installation directory
  local fzf_base=""

  # Try to find fzf base directory (works for nix-installed fzf)
  # Use zsh built-ins to avoid depending on external commands
  local fzf_bin="$(command -v fzf 2>/dev/null)"
  if [[ -n "$fzf_bin" ]]; then
    # Use zsh's :A to resolve symlinks, :h to get parent dir
    local fzf_real_path="${fzf_bin:A}"
    local fzf_prefix="${fzf_real_path:h:h}"  # Go up two directories

    # Check if this is a nix store path
    if [[ "$fzf_prefix" == /nix/store/* ]]; then
      fzf_base="$fzf_prefix/share/fzf"
    fi
  fi

  # Fallback to common locations if nix path not found
  if [[ -z "$fzf_base" ]] || [[ ! -d "$fzf_base" ]]; then
    local fzf_common_paths=(
      "/usr/share/fzf"
      "/usr/local/opt/fzf/shell"
      "$HOME/.fzf/shell"
      "/opt/homebrew/opt/fzf/shell"
    )
    for path in "${fzf_common_paths[@]}"; do
      if [[ -d "$path" ]]; then
        fzf_base="$path"
        break
      fi
    done
  fi

  # Source keybindings and completion if found
  if [[ -n "$fzf_base" ]]; then
    if [[ -f "$fzf_base/key-bindings.zsh" ]]; then
      source "$fzf_base/key-bindings.zsh"
    fi
    if [[ -f "$fzf_base/completion.zsh" ]]; then
      source "$fzf_base/completion.zsh"
    fi
  else
    # Fallback: try to source directly from nix store if fzf is available
    # Use zsh built-ins to avoid depending on external commands
    local fzf_bin fzf_real_path fzf_pkg_path
    fzf_bin="$(command -v fzf 2>/dev/null)"
    if [[ -n "$fzf_bin" ]]; then
      # Use zsh's :A modifier to resolve symlinks (like readlink -f)
      fzf_real_path="${fzf_bin:A}"
      # Use parameter expansion to get parent directories (like dirname)
      fzf_pkg_path="${fzf_real_path:h:h}"

      if [[ -f "$fzf_pkg_path/share/fzf/key-bindings.zsh" ]]; then
        source "$fzf_pkg_path/share/fzf/key-bindings.zsh"
      fi
      if [[ -f "$fzf_pkg_path/share/fzf/completion.zsh" ]]; then
        source "$fzf_pkg_path/share/fzf/completion.zsh"
      fi
    fi
  fi
fi

# Custom keybinding: Ctrl+F for file content search
fzf-file-content-widget() {
  local selected file line
  if command -v rg &> /dev/null; then
    selected=$(rg --color=always --line-number --no-heading --smart-case "${*:-}" 2>/dev/null |
      fzf --ansi \
          --delimiter : \
          --preview 'bat --color=always --style=numbers --highlight-line {2} {1}' \
          --preview-window 'up,60%,border-rounded,+{2}+3/3,~3' \
          --header 'Ctrl+F: Search in files | CTRL-/: Toggle Preview')
    if [[ -n "$selected" ]]; then
      file=$(echo "$selected" | cut -d: -f1)
      line=$(echo "$selected" | cut -d: -f2)
      ${EDITOR:-vim} "+${line}" "$file"
    fi
  else
    echo "rg (ripgrep) not found. Install it for file content search."
  fi
}

zle -N fzf-file-content-widget
bindkey '^F' fzf-file-content-widget
