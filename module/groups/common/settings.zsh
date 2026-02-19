# Core Shell Settings - History, options, basic functionality

# ===== HISTORY (XDG-compliant) =====
export HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
[[ -d "${HISTFILE:h}" ]] || mkdir -p "${HISTFILE:h}"
export HISTSIZE=1000000
export SAVEHIST=1000000
setopt EXTENDED_HISTORY           # Record timestamp of command
setopt HIST_EXPIRE_DUPS_FIRST     # Delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt HIST_IGNORE_ALL_DUPS       # Remove older duplicate when new duplicate is added
setopt HIST_FIND_NO_DUPS          # Don't show duplicates in history search
setopt HIST_IGNORE_SPACE          # Ignore commands that start with space
setopt HIST_VERIFY                # Show command with history expansion before running it
setopt SHARE_HISTORY              # Share history between all sessions
setopt INC_APPEND_HISTORY         # Write to history file immediately, not on shell exit
setopt HIST_REDUCE_BLANKS         # Remove superfluous blanks

# ===== DIRECTORY NAVIGATION =====
setopt AUTO_CD                    # cd by typing directory name if it's not a command
setopt AUTO_PUSHD                 # Make cd push the old directory onto the directory stack
setopt PUSHD_IGNORE_DUPS          # Don't push multiple copies of the same directory onto the directory stack
setopt PUSHD_MINUS                # Exchanges the meanings of '+' and '-' when specifying a directory in the stack

# ===== COMPLETION =====
setopt ALWAYS_TO_END              # Move cursor to the end of a completed word
setopt AUTO_MENU                  # Show completion menu on a successive tab press
setopt AUTO_LIST                  # Automatically list choices on ambiguous completion
setopt COMPLETE_IN_WORD           # Complete from both ends of a word
unsetopt MENU_COMPLETE            # Do not autoselect the first completion entry

# ===== GLOBBING =====
setopt EXTENDED_GLOB              # Use extended globbing syntax
setopt GLOB_DOTS                  # Do not require a leading '.' in a filename to be matched explicitly
setopt NO_CASE_GLOB               # Case insensitive globbing
setopt NUMERIC_GLOB_SORT          # Sort numeric filenames numerically
setopt NO_NOMATCH                 # Pass unmatched globs to command (fixes nix flake .#syntax)

# ===== INPUT/OUTPUT =====
setopt INTERACTIVE_COMMENTS       # Allow comments even in interactive shells
setopt RC_QUOTES                  # Allow 'Henry''s Garage' instead of 'Henry'\''s Garage'
setopt COMBINING_CHARS             # Proper Unicode combining character support (macOS)

# ===== JOB CONTROL =====
setopt LONG_LIST_JOBS             # List jobs in long format by default
setopt AUTO_RESUME                # Attempt to resume existing job before creating a new process
setopt NOTIFY                     # Report status of background jobs immediately
unsetopt BG_NICE                  # Don't run all background jobs at a lower priority
unsetopt HUP                      # Don't kill jobs on shell exit
unsetopt CHECK_JOBS               # Don't report on jobs when shell exit

# ===== PERFORMANCE =====
setopt NO_BEEP                    # Don't beep on error
setopt NO_FLOW_CONTROL            # Disable start/stop characters in shell editor

# ===== FUNCTION NESTING =====
# Increase function nesting limit to prevent errors with complex plugin hooks
# Default is 500, we increase to 1000 for safety with direnv/starship/fzf wrappers
export FUNCNEST=1000

# ===== KEY TIMEOUT =====
export KEYTIMEOUT=20              # 200ms for key sequences (reliable vim mode switching)

# ===== COLORS =====
# Enable colors in ls and completion
export CLICOLOR=1
export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"  # BSD/macOS format

# GNU format for zsh completion colors and GNU ls
# Nord-themed: dir=frost blue, link=frost, exec=green, archive=red
export LS_COLORS="di=1;34:ln=36:so=32:pi=33:ex=1;32:bd=34;46:cd=34;43:su=1;31:sg=1;33:tw=34;42:ow=34;43:*.tar=31:*.tgz=31:*.zip=31:*.gz=31:*.bz2=31:*.7z=31:*.rar=31:*.xz=31:*.zst=31"

# Nord color palette for terminal
export NORD0="#2E3440"
export NORD1="#3B4252"
export NORD2="#434C5E"
export NORD3="#4C566A"
export NORD4="#D8DEE9"
export NORD5="#E5E9F0"
export NORD6="#ECEFF4"
export NORD7="#8FBCBB"
export NORD8="#88C0D0"
export NORD9="#81A1C1"
export NORD10="#5E81AC"
export NORD11="#BF616A"
export NORD12="#D08770"
export NORD13="#EBCB8B"
export NORD14="#A3BE8C"
export NORD15="#B48EAD"
