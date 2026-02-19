# fzf-tab - Replace zsh completion menu with fzf

# Plugin path
FZF_TAB_PLUGIN_PATH="$HOME/.local/share/shell/plugins/aloxaf/fzf-tab"

# Load plugin (must be after compinit)
[[ -f "$FZF_TAB_PLUGIN_PATH/fzf-tab.plugin.zsh" ]] && \
  source "$FZF_TAB_PLUGIN_PATH/fzf-tab.plugin.zsh"

# ===== NORD-THEMED FZF-TAB CONFIGURATION =====

# Use fzf's default opts (inherits our Nord colors from FZF_DEFAULT_OPTS)
zstyle ':fzf-tab:*' use-fzf-default-opts yes

# Switch group with < and >
zstyle ':fzf-tab:*' switch-group '<' '>'

# Disable sort for completion results (preserve zsh's native ordering)
zstyle ':fzf-tab:*' fzf-flags --no-sort

# ===== PREVIEW CONFIGURATION =====

# Directory preview with eza tree
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --level=2 --icons --color=always $realpath 2>/dev/null'
zstyle ':fzf-tab:complete:pushd:*' fzf-preview 'eza --tree --level=2 --icons --color=always $realpath 2>/dev/null'
zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza --tree --level=2 --icons --color=always $realpath 2>/dev/null'

# File preview with bat
zstyle ':fzf-tab:complete:*:*' fzf-preview \
  'if [[ -d $realpath ]]; then eza --tree --level=2 --icons --color=always $realpath 2>/dev/null; elif [[ -f $realpath ]]; then bat --color=always --style=numbers --line-range=:200 $realpath 2>/dev/null; fi'

# Process preview
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
  '[[ $group == "[process ID]" ]] && ps -p $word -o comm,pid,ppid,%cpu,%mem,start,time,command'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap

# Environment variable preview
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview \
  'echo ${(P)word}'

# Git preview
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview \
  'git diff $word | delta --width=${FZF_PREVIEW_COLUMNS:-80} 2>/dev/null'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview \
  'git log --oneline --graph --color=always $word 2>/dev/null'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
  'case "$group" in
    "modified file") git diff $word | delta --width=${FZF_PREVIEW_COLUMNS:-80} 2>/dev/null ;;
    "recent commit object name") git log --oneline --graph --color=always $word 2>/dev/null ;;
    *) git log --oneline --graph --color=always $word 2>/dev/null ;;
  esac'

# systemctl preview (Linux)
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word 2>/dev/null'
