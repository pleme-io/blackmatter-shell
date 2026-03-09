# skim — Rust fuzzy finder with Nord theme

export SKIM_DEFAULT_OPTIONS="
  --height 30%
  --layout=reverse
  --border=rounded
  --info=inline
  --prompt='❄ '
  --ansi
  --bind='ctrl-/:toggle-preview'
  --bind='ctrl-u:preview-half-page-up'
  --bind='ctrl-d:preview-half-page-down'
  --preview-window='right:50%:hidden:wrap'
  --color=fg:#D8DEE9,bg:#2E3440,hl:#88C0D0
  --color=fg+:#ECEFF4,bg+:#3B4252,hl+:#8FBCBB
  --color=info:#81A1C1,prompt:#A3BE8C,pointer:#BF616A
  --color=marker:#B48EAD,spinner:#81A1C1,header:#5E81AC
  --color=border:#4C566A,query:#ECEFF4
"

# Bridge for fzf-tab compatibility
export FZF_DEFAULT_OPTS="$SKIM_DEFAULT_OPTIONS"

# Use fd for file discovery
export SKIM_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --strip-cwd-prefix'

# Ctrl+T: File/directory search with preview (path-aware matching)
export SKIM_CTRL_T_COMMAND="fd --type f --type d --hidden --follow --exclude .git --strip-cwd-prefix"
export SKIM_CTRL_T_OPTS="
  --scheme=path
  --preview 'if [ -d {} ]; then eza --tree --level=2 --icons --color=always {} 2>/dev/null; else bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null; fi'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'
  --header 'CTRL-T: Files/Dirs | CTRL-/: Toggle Preview'
"

# Alt+C: Directory search with tree preview
export SKIM_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git --strip-cwd-prefix'
export SKIM_ALT_C_OPTS="
  --scheme=path
  --preview 'eza --tree --level=2 --icons --color=always {}'
  --header 'ALT-C: Change Directory'
"

# Ctrl+R: Fuzzy history search (via skim-history Rust binary)
skim-history-widget() {
  local selected
  zle -I
  selected=$(skim-history --query "${LBUFFER}")
  if [[ -n "$selected" ]]; then
    LBUFFER="$selected"
    RBUFFER=""
  fi
  zle reset-prompt
}
zle -N skim-history-widget
bindkey '^R' skim-history-widget

# Ctrl+T: Fuzzy file/directory picker (via skim-files Rust binary)
skim-files-widget() {
  local selected
  zle -I
  selected=$(skim-files --query "${LBUFFER}")
  if [[ -n "$selected" ]]; then
    LBUFFER="${LBUFFER}${selected}"
  fi
  zle reset-prompt
}
zle -N skim-files-widget
bindkey '^T' skim-files-widget

# Ctrl+F: Search file contents (via skim-content Rust binary)
# skim-content outputs a ready-to-eval editor command or nothing on abort.
skim-content-widget() {
  local saved_buffer="$BUFFER" saved_cursor="$CURSOR"
  zle -I
  local cmd
  cmd=$(skim-content --query "${LBUFFER}")
  if [[ -n "$cmd" ]]; then
    BUFFER="$cmd"
    zle accept-line
  else
    BUFFER="$saved_buffer"
    CURSOR="$saved_cursor"
  fi
  zle reset-prompt
}
zle -N skim-content-widget
bindkey '^F' skim-content-widget
