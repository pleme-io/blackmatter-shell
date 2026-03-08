# skim — Rust fuzzy finder with Arinae algorithm and Nord theme

export SKIM_DEFAULT_OPTIONS="
  --algo=arinae
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

# Ctrl+F: Search file contents with ripgrep + bat preview
skim-file-content-widget() {
  local selected file line
  selected=$(rg --color=always --line-number --no-heading --smart-case "${*:-}" 2>/dev/null |
    sk --ansi \
        --delimiter : \
        --preview 'bat --color=always --style=numbers --highlight-line {2} {1}' \
        --preview-window 'up,60%,border-rounded,+{2}+3/3,~3' \
        --header 'Ctrl+F: Search in files | CTRL-/: Toggle Preview')
  if [[ -n "$selected" ]]; then
    file=$(echo "$selected" | cut -d: -f1)
    line=$(echo "$selected" | cut -d: -f2)
    ${EDITOR:-nvim} "+${line}" "$file"
  fi
}
zle -N skim-file-content-widget
bindkey '^F' skim-file-content-widget
