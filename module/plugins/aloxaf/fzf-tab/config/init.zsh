# fzf-tab — fuzzy completion with skim-tab backend

FZF_TAB_PLUGIN_PATH="$HOME/.local/share/shell/plugins/aloxaf/fzf-tab"
[[ -f "$FZF_TAB_PLUGIN_PATH/fzf-tab.plugin.zsh" ]] && \
  source "$FZF_TAB_PLUGIN_PATH/fzf-tab.plugin.zsh"

# Backend: skim-tab (Rust bridge that fixes skim's --expect protocol for fzf-tab)
zstyle ':fzf-tab:*' fzf-command skim-tab
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' fzf-flags --no-sort

# Path-aware matching for navigation commands
zstyle ':fzf-tab:complete:(cd|pushd|z):*' fzf-flags --no-sort --scheme=path

# Previews — inline shell commands (matches blx init zsh output)
zstyle ':fzf-tab:complete:(cd|pushd|z):*' fzf-preview \
  'eza -1 --color=always --icons --group-directories-first ${realpath:-$word} 2>/dev/null'
zstyle ':fzf-tab:complete:*:*' fzf-preview \
  'if [[ -d ${realpath:-$word} ]]; then eza -1 --color=always --icons ${realpath:-$word}; elif [[ -f ${realpath:-$word} ]]; then bat --color=always --style=numbers --line-range=:200 ${realpath:-$word} 2>/dev/null; else echo ${realpath:-$word}; fi'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
  '[[ $group == "[process ID]" ]] && ps -p $word -o comm,pid,ppid,%cpu,%mem,start,time,command'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview \
  'echo ${(P)word}'
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
