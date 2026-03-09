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

# Previews — all delegated to Rust binaries (blx-preview-* symlinks)
zstyle ':fzf-tab:complete:(cd|pushd|z):*' fzf-preview \
  'blx-preview-dir ${realpath:-$word}'
zstyle ':fzf-tab:complete:*:*' fzf-preview \
  'blx-preview ${realpath:-$word}'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
  'blx-preview-proc $group $word'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview \
  'echo ${(P)word} 2>/dev/null'
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview \
  'blx-preview-git diff $word'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview \
  'blx-preview-git log $word'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
  'blx-preview-git checkout $word $group'
