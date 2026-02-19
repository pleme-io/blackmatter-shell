# direnv - Load/unload environment variables based on directory
# Standard integration following direnv + starship best practices
# https://direnv.net/docs/hook.html

# Only initialize if direnv is available
if command -v direnv &> /dev/null; then
  # Silent direnv output (no log spam)
  export DIRENV_LOG_FORMAT=""

  # Initialize direnv hook
  # NOTE: This adds _direnv_hook to precmd_functions automatically
  eval "$(direnv hook zsh)"

  # Enable nix-direnv integration for faster flake loading
  # https://github.com/nix-community/nix-direnv
  export DIRENV_WARN_TIMEOUT=10s
fi

# IMPORTANT: No custom wrapping needed!
# - Starship initializes AFTER direnv (priority 99 > 90)
# - Both use add-zsh-hook which handles precmd ordering automatically
# - STARSHIP_CONFIG is preserved via ~/.direnvrc
# - FZF keybindings are handled by FZF plugin initialization
