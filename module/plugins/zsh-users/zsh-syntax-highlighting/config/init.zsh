# zsh-syntax-highlighting - Syntax highlighting for Zsh with Nord colors

# Plugin path
ZSH_HIGHLIGHT_PLUGIN_PATH="$HOME/.local/share/shell/plugins/zsh-users/zsh-syntax-highlighting"

# Declare associative array for ZSH highlighting styles
typeset -gA ZSH_HIGHLIGHT_STYLES

# Nord-themed syntax highlighting colors
# Commands
ZSH_HIGHLIGHT_STYLES[default]='none'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#BF616A,bold'              # Nord red - unknown/error
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#81A1C1,bold'              # Nord frost - keywords
ZSH_HIGHLIGHT_STYLES[alias]='fg=#A3BE8C'                           # Nord green - found command
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#A3BE8C'                    # Nord green - found command
ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#A3BE8C'                    # Nord green - found command
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#A3BE8C'                         # Nord green - found command
ZSH_HIGHLIGHT_STYLES[function]='fg=#88C0D0'                        # Nord frost - functions
ZSH_HIGHLIGHT_STYLES[command]='fg=#A3BE8C'                         # Nord green - found command
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#A3BE8C,underline'            # Nord green - precommand
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#ECEFF4'                # Nord snow - separators
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#A3BE8C'                  # Nord green - found command
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=#EBCB8B,underline'         # Nord yellow - directory

# Paths and arguments
ZSH_HIGHLIGHT_STYLES[path]='fg=#EBCB8B'                            # Nord yellow - paths
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=#D08770'              # Nord orange - separators
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#EBCB8B'                     # Nord yellow - path prefix
ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]='fg=#D08770'       # Nord orange - separators
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#B48EAD'                        # Nord purple - globs
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#88C0D0'               # Nord frost - history

# Options and arguments
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#D08770'            # Nord orange - options
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#D08770'            # Nord orange - options
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#B48EAD'            # Nord purple - backticks
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#EBCB8B'          # Nord yellow - strings
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#EBCB8B'          # Nord yellow - strings
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#EBCB8B'          # Nord yellow - strings
ZSH_HIGHLIGHT_STYLES[rc-quote]='fg=#EBCB8B'                        # Nord yellow - strings
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#8FBCBB'   # Nord frost - variables
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=#8FBCBB'     # Nord frost - escapes
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=#8FBCBB'     # Nord frost - escapes
ZSH_HIGHLIGHT_STYLES[assign]='fg=#D8DEE9'                          # Nord snow - assignment
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#81A1C1'                     # Nord frost - redirects
ZSH_HIGHLIGHT_STYLES[comment]='fg=#4C566A,italic'                  # Nord polar night - comments
ZSH_HIGHLIGHT_STYLES[named-fd]='fg=#81A1C1'                        # Nord frost - fd
ZSH_HIGHLIGHT_STYLES[numeric-fd]='fg=#81A1C1'                      # Nord frost - fd

# Argument modifiers
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#A3BE8C'                            # Nord green - command found

# Brackets and delimiters
ZSH_HIGHLIGHT_STYLES[bracket-error]='fg=#BF616A,bold'              # Nord red - errors
ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=#88C0D0'                 # Nord frost
ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg=#8FBCBB'                 # Nord frost
ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=#81A1C1'                 # Nord frost
ZSH_HIGHLIGHT_STYLES[bracket-level-4]='fg=#5E81AC'                 # Nord frost
ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]='fg=#A3BE8C,bold'     # Nord green

# CRITICAL: Command not found - RED
ZSH_HIGHLIGHT_STYLES[command-not-found]='fg=#BF616A,bold'          # Nord red - NOT FOUND

# Load plugin (must be last to highlight all commands)
[[ -f "$ZSH_HIGHLIGHT_PLUGIN_PATH/zsh-syntax-highlighting.zsh" ]] && \
  source "$ZSH_HIGHLIGHT_PLUGIN_PATH/zsh-syntax-highlighting.zsh"
