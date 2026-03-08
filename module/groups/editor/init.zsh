# Editor Integration — Vim mode, cursor shape, clipboard, pager

# ===== CURSOR SHAPE =====
# Block cursor in normal mode, beam in insert mode
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
echo -ne '\e[5 q'
_blzsh_preexec() { echo -ne '\e[5 q' }
add-zsh-hook preexec _blzsh_preexec

# ===== KEY BINDINGS =====
bindkey -M vicmd 'k' up-line-or-history
bindkey -M vicmd 'j' down-line-or-history
bindkey -M vicmd '^A' beginning-of-line
bindkey -M vicmd '^E' end-of-line
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line
bindkey -M vicmd '/' history-incremental-search-backward
bindkey -M vicmd '?' history-incremental-search-forward

# Edit command in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line

# Backspace and delete
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^H' backward-delete-char
bindkey -M viins '^[[3~' delete-char
bindkey -M vicmd '^[[3~' delete-char

# Word movement (Ctrl+Arrow and Alt+Arrow)
bindkey -M viins '^[[1;5C' forward-word
bindkey -M viins '^[[1;5D' backward-word
bindkey -M viins '^[[1;3C' forward-word
bindkey -M viins '^[[1;3D' backward-word

# History navigation with prefix matching
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey -M viins '^[[A' up-line-or-beginning-search
bindkey -M viins '^[[B' down-line-or-beginning-search
bindkey -M vicmd '^[[A' up-line-or-beginning-search
bindkey -M vicmd '^[[B' down-line-or-beginning-search
bindkey -M viins '^P' up-line-or-beginning-search
bindkey -M viins '^N' down-line-or-beginning-search

# ===== ENVIRONMENT =====
export EDITOR='blnvim'
export VISUAL='blnvim'
export PAGER='less'
export LESS='-R -i -w -M -z-4 -x4'
export LESSHISTFILE='-'
export BAT_THEME="ansi"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT='-c'

# ===== CLIPBOARD =====
# Yank to system clipboard (platform-adaptive)
function vi-yank-clip {
    zle vi-yank
    if [[ "$(uname)" == "Darwin" ]]; then
        echo "$CUTBUFFER" | pbcopy
    elif [[ -n "$WAYLAND_DISPLAY" ]]; then
        echo "$CUTBUFFER" | wl-copy
    elif [[ -n "$DISPLAY" ]]; then
        echo "$CUTBUFFER" | xsel --clipboard
    fi
}
zle -N vi-yank-clip
bindkey -M vicmd 'y' vi-yank-clip
