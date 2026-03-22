# bm-guard — Pre-execution command guardian
#
# Hooks into zsh preexec to validate commands before execution.
# Exit codes: 0=allow, 1=warn (proceed), 2=block (abort).
#
# Safe commands: ~50ns (prefilter fast path, zero allocation)
# Dangerous commands: ~1-5µs (RegexSet DFA, zero allocation)

# Skip if bm-guard binary not found
(( $+commands[bm-guard] )) || return

_bm_guard_preexec() {
  # Skip empty commands, comments, and builtins that can't be dangerous
  [[ -z "$1" || "$1" == \#* ]] && return

  # Run bm-guard — exit 0=allow, 1=warn, 2=block
  bm-guard check "$1" 2>&1
  local ret=$?

  if (( ret == 2 )); then
    # Block: kill the command line, don't execute
    # We can't truly abort from preexec, but we can warn loudly.
    # The actual blocking happens via the zle accept-line wrapper below.
    return 1
  fi
  # ret==1 (warn) or ret==0 (allow): proceed
}

# Accept-line wrapper: validates before execution
_bm_guard_accept_line() {
  local cmd=$BUFFER

  # Skip empty
  [[ -z "$cmd" ]] && { zle .accept-line; return; }

  # Check the command
  bm-guard check "$cmd" 2>&1 >/dev/null
  local ret=$?

  if (( ret == 2 )); then
    # Blocked — show the message (bm-guard already printed to stderr)
    bm-guard check "$cmd" 2>&1 >/dev/tty
    zle -M "Command blocked by guardrail. Edit and retry."
    return 1
  fi

  if (( ret == 1 )); then
    # Warn — show warning, ask for confirmation
    bm-guard check "$cmd" 2>&1 >/dev/tty
    echo -n "Proceed? [y/N] " >/dev/tty
    read -rk1 reply </dev/tty
    echo >/dev/tty
    [[ "$reply" == [yY] ]] || return 1
  fi

  zle .accept-line
}

zle -N accept-line _bm_guard_accept_line
