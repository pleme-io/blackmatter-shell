# skim - Fuzzy finder for command-line (Rust replacement for fzf)

# Nord-themed skim configuration
# Uses Arinae algorithm for typo-resistant fuzzy matching
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

# Bridge for fzf-tab compatibility (reads FZF_DEFAULT_OPTS)
export FZF_DEFAULT_OPTS="$SKIM_DEFAULT_OPTIONS"

# Use fd/rg for faster file finding (fallback to find if not available)
if command -v fd &> /dev/null; then
  export SKIM_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --strip-cwd-prefix'
elif command -v rg &> /dev/null; then
  export SKIM_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
fi

# Load skim keybindings — skipped when already loaded (e.g. blzsh sources from store path directly)
if [[ -z "$_BLZSH_SKIM_KEYS_LOADED" ]] && command -v sk &> /dev/null; then
  local sk_base=""
  local sk_bin="$(command -v sk 2>/dev/null)"
  if [[ -n "$sk_bin" ]]; then
    local sk_real_path="${sk_bin:A}"
    local sk_prefix="${sk_real_path:h:h}"
    if [[ "$sk_prefix" == /nix/store/* ]]; then
      sk_base="$sk_prefix/share/skim"
    fi
  fi

  # Fallback to common locations
  if [[ -z "$sk_base" ]] || [[ ! -d "$sk_base" ]]; then
    local sk_common_paths=(
      "/usr/share/skim"
      "/usr/local/share/skim"
      "$HOME/.skim/shell"
    )
    for path in "${sk_common_paths[@]}"; do
      if [[ -d "$path" ]]; then
        sk_base="$path"
        break
      fi
    done
  fi

  if [[ -n "$sk_base" ]]; then
    [[ -f "$sk_base/key-bindings.zsh" ]] && source "$sk_base/key-bindings.zsh"
    [[ -f "$sk_base/completion.zsh" ]] && source "$sk_base/completion.zsh"
  fi
fi

# Ctrl+T: File/directory search with preview (path-aware matching)
export SKIM_CTRL_T_COMMAND="${SKIM_DEFAULT_COMMAND:-fd --type f --type d --hidden --follow --exclude .git --strip-cwd-prefix}"
export SKIM_CTRL_T_OPTS="
  --scheme=path
  --preview 'if [ -d {} ]; then eza --tree --level=2 --icons --color=always {} 2>/dev/null || ls -la {}; else bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || cat {}; fi'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'
  --header 'CTRL-T: Files/Dirs | CTRL-/: Toggle Preview'
"

# Alt+C: Directory search with tree preview
if command -v fd &> /dev/null; then
  export SKIM_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git --strip-cwd-prefix'
fi
export SKIM_ALT_C_OPTS="
  --scheme=path
  --preview 'eza --tree --level=2 --icons --color=always {} 2>/dev/null || ls -la {}'
  --header 'ALT-C: Change Directory'
"

# Custom keybinding: Ctrl+F for file content search (uses skim)
skim-file-content-widget() {
  local selected file line
  if command -v rg &> /dev/null; then
    selected=$(rg --color=always --line-number --no-heading --smart-case "${*:-}" 2>/dev/null |
      sk --ansi \
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

zle -N skim-file-content-widget
bindkey '^F' skim-file-content-widget
