# atuin - Magical shell history (Rust replacement for zsh-autosuggestions + history search)
# Provides: SQLite-backed history, fuzzy search, cross-machine sync, statistics

# Initialize atuin (only if available)
if command -v atuin &> /dev/null; then
  # Initialize atuin with zsh integration
  # --disable-up-arrow: we handle up-arrow ourselves in editor/init.zsh for prefix search
  # --disable-ctrl-r: skim provides the fuzzy history search UI via ctrl-r
  eval "$(atuin init zsh --disable-up-arrow --disable-ctrl-r)"
fi
