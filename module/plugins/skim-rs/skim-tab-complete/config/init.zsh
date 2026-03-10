# skim-tab-complete — fuzzy tab completion powered by skim-tab (Rust)
#
# Replaces fzf-tab. Hooks zsh's compadd to capture candidates in compcap
# format, pipes binary data to skim-tab --complete --compcap (Rust),
# reads eval-friendly output, applies. All logic is in Rust — zsh is
# just the compadd hook + ZLE glue (~90 lines).

zmodload zsh/zutil

typeset -ga _stc_compcap=()
typeset -ga _stc_groups=()
typeset -g  _stc_curcontext=''
typeset -g  _stc_response=''
typeset -gi IN_SKIM_TAB=0

# ── compadd hook (must be zsh — zparseopts is a zsh builtin) ───────────

-stc-compadd() {
  local -A apre hpre dscrs _oad
  local -a isfile _opts __ expl
  zparseopts -a _opts P:=apre p:=hpre d:=dscrs X+:=expl O:=_oad A:=_oad D:=_oad f=isfile \
             i: S: s: I: x: r: R: W: F: M+: E: q e Q n U C \
             J:=__ V:=__ a=__ l=__ k=__ o::=__ 1=__ 2=__

  _stc_curcontext=${curcontext#:}

  if (( $#_oad != 0 || ! IN_SKIM_TAB )); then
    builtin compadd "$@"
    return
  fi

  local -a __hits __dscr
  if (( $#dscrs == 1 )); then
    __dscr=( "${(@P)${(v)dscrs}}" )
  fi
  builtin compadd -A __hits -D __dscr "$@"
  local ret=$?
  (( $#__hits )) || return $ret

  expl=$expl[2]
  [[ -n $expl ]] && _stc_groups+=$expl

  local -a keys=(apre hpre PREFIX SUFFIX IPREFIX ISUFFIX)
  local key expanded meta=$'<\0>'
  for key in $keys; do
    expanded=${(P)key}
    [[ -n $expanded ]] && meta+=$'\0'$key$'\0'$expanded
  done
  [[ -n $expl ]] && meta+=$'\0group\0'$_stc_groups[(ie)$expl]
  if [[ -n $isfile ]]; then
    meta+=$'\0realdir\0'${${(Qe)~${:-$IPREFIX$hpre}}}
  fi
  _opts+=("${(@kv)apre}" "${(@kv)hpre}" $isfile)
  meta+=$'\0args\0'${(pj:\1:)_opts}

  local word dscr i
  for i in {1..$#__hits}; do
    word=$__hits[i] dscr=$__dscr[i]
    [[ -z $dscr ]] && dscr=$word
    dscr=${dscr//$'\n'}
    _stc_compcap+=$dscr$'\2'$meta$'\0word\0'$word
  done

  builtin compadd "$@"
}

# ── Completion (hooks _main_complete, calls Rust) ──────────────────────

-stc-complete() {
  local -Ua _stc_groups
  _stc_compcap=()

  COLUMNS=500 _stc__main_complete "$@"

  emulate -L zsh -o extended_glob
  (( $#_stc_compcap )) || return 1

  local cmd=${_stc_curcontext%%:*}

  # Pipe compcap binary data to Rust. Output format:
  #   Line 1: "select" or "abort"
  #   Lines 2+: word\x1fprefix\x1fsuffix\x1fiprefix\x1fisuffix\x1fargs
  _stc_response=$(
    printf '%s\x03' "${_stc_compcap[@]}" | \
    skim-tab --complete --compcap --command "$cmd" --query "${PREFIX:-}" 2>/dev/null
  )

  compstate[list]=
  compstate[insert]=
}

# ── Apply widget (reads Rust output, calls builtin compadd) ────────────

_skim-tab-apply() {
  [[ -n $_stc_response ]] || return 1

  local -a lines=("${(@f)_stc_response}")
  local action=$lines[1]
  [[ $action == select ]] || { unset _stc_response; return 1; }

  local -i count=$(( $#lines - 1 ))
  (( count > 0 )) || { unset _stc_response; return 1; }

  local -i idx
  for idx in {2..$#lines}; do
    # Split on unit separator (\x1f): word prefix suffix iprefix isuffix args
    local -a fields=("${(@ps:\x1f:)lines[$idx]}")
    (( $#fields >= 1 )) || continue

    local sel_word=$fields[1]
    local sel_prefix=${fields[2]:-}
    local sel_suffix=${fields[3]:-}
    local sel_iprefix=${fields[4]:-}
    local sel_isuffix=${fields[5]:-}
    local sel_args=${fields[6]:-}

    local -a compadd_args=("${(@ps:\1:)sel_args}")
    [[ -z $compadd_args[1] ]] && compadd_args=()
    IPREFIX=$sel_iprefix PREFIX=$sel_prefix SUFFIX=$sel_suffix ISUFFIX=$sel_isuffix
    builtin compadd "${compadd_args[@]:--Q}" -Q -- "$sel_word"
  done

  compstate[list]=
  if (( count == 1 )); then
    compstate[insert]='1'
    [[ $RBUFFER == ' '* ]] || compstate[insert]+=' '
  elif (( count > 1 )); then
    compstate[insert]='all'
  fi

  unset _stc_response
}

# ── ZLE widget ─────────────────────────────────────────────────────────

skim-tab-complete() {
  local -i ret=0
  IN_SKIM_TAB=1
  echoti civis >/dev/tty 2>/dev/null
  {
    zle .skim-tab-orig-$_stc_orig_widget || ret=$?
    if (( ! ret )) && [[ -n $_stc_response ]]; then
      zle _skim-tab-apply || ret=$?
    fi
  } always {
    IN_SKIM_TAB=0
  }
  echoti cnorm >/dev/tty 2>/dev/null
  zle .redisplay
  return $ret
}

# ── Enable/disable ────────────────────────────────────────────────────

enable-skim-tab() {
  emulate -L zsh -o extended_glob
  [[ -n $_stc_orig_widget ]] && disable-skim-tab

  typeset -g _stc_orig_widget="${${$(builtin bindkey '^I')##* }:-expand-or-complete}"
  if (( ! $+widgets[.skim-tab-orig-$_stc_orig_widget] )); then
    local compinit_widgets=(
      complete-word delete-char-or-list expand-or-complete
      expand-or-complete-prefix list-choices menu-complete
      menu-expand-or-complete reverse-menu-complete
    )
    if [[ $widgets[$_stc_orig_widget] == builtin &&
            $compinit_widgets[(Ie)$_stc_orig_widget] != 0 ]]; then
      zle -C .skim-tab-orig-$_stc_orig_widget .$_stc_orig_widget _main_complete
    else
      zle -A $_stc_orig_widget .skim-tab-orig-$_stc_orig_widget
    fi
  fi

  zstyle ':completion:*' list-grouped false
  bindkey -M emacs '^I' skim-tab-complete
  bindkey -M viins '^I' skim-tab-complete

  autoload +X -Uz _main_complete _approximate

  functions[compadd]=$functions[-stc-compadd]

  functions[_stc__main_complete]=$functions[_main_complete]
  function _main_complete() { -stc-complete "$@" }

  functions[_stc__approximate]=$functions[_approximate]
  function _approximate() {
    (( ! IN_SKIM_TAB )) || unfunction compadd
    _stc__approximate
    (( ! IN_SKIM_TAB )) || functions[compadd]=$functions[-stc-compadd]
  }
}

disable-skim-tab() {
  emulate -L zsh -o extended_glob
  (( $+_stc_orig_widget )) || return 0
  bindkey '^I' $_stc_orig_widget
  unset _stc_orig_widget
  unfunction compadd 2>/dev/null
  functions[_main_complete]=$functions[_stc__main_complete]
  functions[_approximate]=$functions[_stc__approximate]
}

# ── Register ───────────────────────────────────────────────────────────

zle -N skim-tab-complete
zle -C _skim-tab-apply complete-word _skim-tab-apply

enable-skim-tab
