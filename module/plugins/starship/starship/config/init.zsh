# Starship Prompt - Initialize
# NOTE: STARSHIP_CONFIG is set in ~/.zshenv (loaded before this file)

# Initialize starship (only if available)
if command -v starship &> /dev/null; then
  # Initialize starship (must be last to take full control of prompt)
  eval "$(starship init zsh)"
fi
