# atuin — SQLite-backed shell history with fuzzy search and cross-machine sync
# --disable-up-arrow: we handle up-arrow in editor/init.zsh for prefix search
# --disable-ctrl-r: skim provides the fuzzy history search UI via ctrl-r
eval "$(atuin init zsh --disable-up-arrow --disable-ctrl-r)"
