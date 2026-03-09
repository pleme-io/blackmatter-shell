# skim — Rust fuzzy finder keybindings
#
# All logic lives in Rust binaries (skim-history, skim-files, skim-content,
# skim-cd). Shell is ZLE glue only — save buffer, call binary, restore on abort.

# Nord theme for fzf-tab (the only consumer of these env vars)
export SKIM_DEFAULT_OPTIONS="--height 30% --layout=reverse --ansi --color=fg:#D8DEE9,bg:#2E3440,hl:#88C0D0:bold:underlined,fg+:#ECEFF4:bold,bg+:#3B4252,hl+:#8FBCBB:bold:underlined,info:#4C566A,prompt:#A3BE8C,pointer:#88C0D0,marker:#B48EAD,spinner:#81A1C1,header:#5E81AC,border:#4C566A,query:#ECEFF4:bold"
export FZF_DEFAULT_OPTS="$SKIM_DEFAULT_OPTIONS"

# ── ZLE widgets ─────────────────────────────────────────────────────────

skim-history-widget() {
  local sb="$BUFFER" sc="$CURSOR"; zle -I
  local r; r=$(skim-history --query "${LBUFFER}")
  if [[ -n "$r" ]]; then BUFFER="$r"; CURSOR=${#BUFFER}
  else BUFFER="$sb"; CURSOR="$sc"; fi; zle reset-prompt
}
zle -N skim-history-widget; bindkey '^R' skim-history-widget

skim-files-widget() {
  local sb="$BUFFER" sc="$CURSOR"; zle -I
  local r; r=$(skim-files)
  if [[ -n "$r" ]]; then
    [[ -n "$LBUFFER" && "${LBUFFER: -1}" != " " ]] && LBUFFER+=" "
    LBUFFER+="$r"
  else BUFFER="$sb"; CURSOR="$sc"; fi; zle reset-prompt
}
zle -N skim-files-widget; bindkey '^T' skim-files-widget

skim-content-widget() {
  local sb="$BUFFER" sc="$CURSOR"; zle -I
  local r; r=$(skim-content --query "${LBUFFER}")
  if [[ -n "$r" ]]; then BUFFER="$r"; zle accept-line
  else BUFFER="$sb"; CURSOR="$sc"; fi; zle reset-prompt
}
zle -N skim-content-widget; bindkey '^F' skim-content-widget

skim-cd-widget() {
  local sb="$BUFFER" sc="$CURSOR"; zle -I
  local r; r=$(skim-cd)
  if [[ -n "$r" ]]; then BUFFER="cd $r"; zle accept-line
  else BUFFER="$sb"; CURSOR="$sc"; fi; zle reset-prompt
}
zle -N skim-cd-widget; bindkey '\ec' skim-cd-widget
