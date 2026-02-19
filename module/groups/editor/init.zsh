# Editor Integration - Vim mode and keybindings

# ===== VIM MODE =====
# Enable vim keybindings
bindkey -v

# ===== CURSOR SHAPE =====
# Change cursor shape for different vi modes
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'  # Block cursor for normal mode
  elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'  # Beam cursor for insert mode
  fi
}
zle -N zle-keymap-select

# Start with beam cursor on zsh init
echo -ne '\e[5 q'

# Beam cursor for each new prompt (via hook — avoids clobbering other preexec hooks)
_blzsh_preexec() { echo -ne '\e[5 q' }
add-zsh-hook preexec _blzsh_preexec

# ===== KEY BINDINGS =====
# Vim-like keybindings in command mode
bindkey -M vicmd 'k' up-line-or-history
bindkey -M vicmd 'j' down-line-or-history

# Beginning/end of line
bindkey -M vicmd '^A' beginning-of-line
bindkey -M vicmd '^E' end-of-line
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line

# History search
bindkey -M vicmd '/' history-incremental-search-backward
bindkey -M vicmd '?' history-incremental-search-forward

# Edit command in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line

# ===== BACKSPACE AND DELETE =====
# Make backspace work as expected
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^H' backward-delete-char

# Delete key
bindkey -M viins '^[[3~' delete-char
bindkey -M vicmd '^[[3~' delete-char

# ===== WORD MOVEMENT =====
# Ctrl+Arrow keys for word movement
bindkey -M viins '^[[1;5C' forward-word      # Ctrl+Right
bindkey -M viins '^[[1;5D' backward-word     # Ctrl+Left

# Alt+Arrow keys as alternative
bindkey -M viins '^[[1;3C' forward-word      # Alt+Right
bindkey -M viins '^[[1;3D' backward-word     # Alt+Left

# ===== HISTORY NAVIGATION =====
# Up/Down arrows for history search
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey -M viins '^[[A' up-line-or-beginning-search      # Up arrow
bindkey -M viins '^[[B' down-line-or-beginning-search    # Down arrow
bindkey -M vicmd '^[[A' up-line-or-beginning-search      # Up arrow
bindkey -M vicmd '^[[B' down-line-or-beginning-search    # Down arrow

# Ctrl+P/N for history navigation (emacs-style)
bindkey -M viins '^P' up-line-or-beginning-search
bindkey -M viins '^N' down-line-or-beginning-search

# ===== CTRL+R FOR HISTORY SEARCH =====
# NOTE: Ctrl+R is bound by fzf plugin (fzf-history-widget)
# Don't rebind it here as that would override fzf's fuzzy history search

# ===== EDITOR VARIABLES =====
# Prefer blnvim (blackmatter neovim) when available
if command -v blnvim &> /dev/null; then
  export EDITOR='blnvim'
  export VISUAL='blnvim'
else
  export EDITOR='nvim'
  export VISUAL='nvim'
fi
export PAGER='less'

# Less configuration
export LESS='-R -i -w -M -z-4 -x4'
export LESSHISTFILE='-'  # Disable less history file

# bat configuration
export BAT_THEME="ansi"   # Use terminal's Nord ANSI colors — consistent everywhere

# Man pages via bat (syntax-highlighted, Nord-themed)
if command -v bat &> /dev/null; then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export MANROFFOPT='-c'  # Fixes bold/underline rendering on macOS
fi

# ===== YO-YANK =====
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
