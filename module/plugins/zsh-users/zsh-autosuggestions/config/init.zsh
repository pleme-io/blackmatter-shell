# zsh-autosuggestions - Fish-like autosuggestions for Zsh

# Plugin path
ZSH_AUTOSUGGEST_PLUGIN_PATH="$HOME/.local/share/shell/plugins/zsh-users/zsh-autosuggestions"

# Configuration
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#5E81AC" # Nord frost blue
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_USE_ASYNC=1

# Load plugin
[[ -f "$ZSH_AUTOSUGGEST_PLUGIN_PATH/zsh-autosuggestions.zsh" ]] && \
  source "$ZSH_AUTOSUGGEST_PLUGIN_PATH/zsh-autosuggestions.zsh"
