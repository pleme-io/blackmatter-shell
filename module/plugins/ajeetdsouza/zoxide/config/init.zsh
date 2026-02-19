# zoxide - Smarter cd command

# Initialize zoxide (only in interactive shells where it's available)
if [[ -o interactive ]] && command -v zoxide &> /dev/null; then
  # Use --cmd cd to make cd use zoxide with proper tab completion
  # This replaces cd with zoxide's smart navigation while maintaining autocomplete
  eval "$(zoxide init zsh --cmd cd)"

  # zi: interactive directory selection via fzf (conventional zoxide name)
  alias zi='__zoxide_zi'
fi
