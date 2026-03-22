# bm-guard — Pre-execution command guardian
#
# Hooks into zsh accept-line to validate commands before execution.
# Exit codes: 0=allow, 1=warn (confirm), 2=block (abort).
#
# Performance: ~50ns safe commands (prefilter), ~1-5µs dangerous (DFA).
# The engine builds once per invocation from compiled cache (~1ms).

# Skip if bm-guard binary not found
(( $+commands[bm-guard] )) || return

# Accept-line wrapper: validates before execution (single invocation)
_bm_guard_accept_line() {
  local cmd=$BUFFER

  # Skip empty and comments
  [[ -z "$cmd" || "$cmd" == \#* ]] && { zle .accept-line; return; }

  # Single check — capture both exit code and stderr output
  local guard_msg
  guard_msg=$(bm-guard check "$cmd" 2>&1)
  local ret=$?

  if (( ret == 2 )); then
    # Block — show message, prevent execution
    print -u2 "$guard_msg"
    zle -M "Command blocked by guardrail. Edit and retry."
    return 1
  fi

  if (( ret == 1 )); then
    # Warn — show message, ask for confirmation
    print -u2 "$guard_msg"
    print -nu2 "Proceed? [y/N] "
    local reply
    read -rk1 reply
    print -u2
    [[ "$reply" == [yY] ]] || return 1
  fi

  zle .accept-line
}

zle -N accept-line _bm_guard_accept_line
