#!/usr/bin/env zsh
# skim-tab-complete regression tests
#
# Tests the trailing-space decision logic, metadata capture, and
# structural invariants of init.zsh. Run from the repo root:
#
#   zsh tests/completion-tests.zsh

typeset -gi _pass=0 _fail=0 _skip=0

# ── Helpers ──────────────────────────────────────────────────────────

_test_start() { printf '  %-55s ' "$1"; }
_test_pass()  { (( _pass++ )); print -P '%F{green}PASS%f'; }
_test_fail()  { (( _fail++ )); print -P "%F{red}FAIL%f: $1"; }
_test_skip()  { (( _skip++ )); print -P "%F{yellow}SKIP%f: $1"; }

# Evaluate the trailing-space condition with given inputs.
# Returns 0 (true) if a space SHOULD be added.
_should_add_space() {
  local -i is_dir=$1
  local suffix=$2 rbuffer=$3
  (( ! is_dir )) && [[ -z $suffix ]] && [[ $rbuffer != ' '* ]]
}

# ── Unit tests: trailing-space decision matrix ───────────────────────

echo "=== Unit Tests: trailing-space logic (8 cases) ==="

_test_start "end-of-word, no trailing text → add space"
_should_add_space 0 '' '' && _test_pass || _test_fail "expected space"

_test_start "end-of-word, trailing text → add space"
_should_add_space 0 '' '| grep foo' && _test_pass || _test_fail "expected space"

_test_start "end-of-word, RBUFFER starts with space → no space"
! _should_add_space 0 '' ' rest' && _test_pass || _test_fail "expected no space"

_test_start "directory selection → no space"
! _should_add_space 1 '' '' && _test_pass || _test_fail "expected no space"

_test_start "midword SUFFIX='.sh' → no space"
! _should_add_space 0 '.sh' '.sh more text' && _test_pass || _test_fail "expected no space"

_test_start "midword SUFFIX='mit' → no space"
! _should_add_space 0 'mit' 'mit' && _test_pass || _test_fail "expected no space"

_test_start "directory + midword → no space"
! _should_add_space 1 'rest' 'rest/' && _test_pass || _test_fail "expected no space"

_test_start "midword SUFFIX='space=default' (flag) → no space"
! _should_add_space 0 'space=default' 'space=default' && _test_pass || _test_fail "expected no space"

# ── Unit tests: field extraction ─────────────────────────────────────

echo ""
echo "=== Unit Tests: field extraction from response (5 cases) ==="

_test_start "sel_suffix from fields[3]"
local -a f1=("word" "prefix" "the_suffix" "ipre" "isuf" "args" "" "")
[[ ${f1[3]:-} == "the_suffix" ]] && _test_pass || _test_fail "got '${f1[3]:-}'"

_test_start "sel_suffix empty when 2 fields only"
local -a f2=("word" "prefix")
[[ -z ${f2[3]:-} ]] && _test_pass || _test_fail "expected empty"

_test_start "sel_word from fields[1]"
[[ ${f1[1]:-} == "word" ]] && _test_pass || _test_fail "got '${f1[1]:-}'"

_test_start "sel_is_dir from fields[7]"
local -a f3=("w" "p" "s" "ip" "is" "a" "d" "")
[[ ${f3[7]:-} == "d" ]] && _test_pass || _test_fail "got '${f3[7]:-}'"

_test_start "8 fields present in full response"
(( $#f3 == 8 )) && _test_pass || _test_fail "got $#f3 fields"

# ── Unit tests: cursor position edge cases ───────────────────────────

echo ""
echo "=== Unit Tests: cursor position edge cases (4 cases) ==="

_test_start "cursor at word start (empty PREFIX, SUFFIX='commit')"
! _should_add_space 0 'commit' 'commit' && _test_pass || _test_fail "expected no space"

_test_start "cursor at word end (PREFIX='commit', empty SUFFIX)"
_should_add_space 0 '' '' && _test_pass || _test_fail "expected space"

_test_start "cursor mid-path (SUFFIX='de/github')"
! _should_add_space 0 'de/github' 'de/github' && _test_pass || _test_fail "expected no space"

_test_start "cursor mid-flag (SUFFIX='space')"
! _should_add_space 0 'space' 'space' && _test_pass || _test_fail "expected no space"

# ── Structural tests: init.zsh invariants ────────────────────────────

echo ""
echo "=== Structural Tests: init.zsh invariants (8 checks) ==="

local init_file="${0:A:h}/../module/plugins/skim-rs/skim-tab-complete/config/init.zsh"

_test_start "init.zsh exists"
if [[ ! -f $init_file ]]; then
  _test_fail "not found at $init_file"
  init_file=''
else
  _test_pass
fi

if [[ -n $init_file ]]; then
  _test_start "sel_suffix guard in trailing-space logic"
  grep -q '\-z \$sel_suffix' "$init_file" && _test_pass \
    || _test_fail "missing '-z \$sel_suffix' guard (midword regression)"

  _test_start "SUFFIX in metadata capture keys"
  grep -q 'keys=.*SUFFIX' "$init_file" && _test_pass \
    || _test_fail "SUFFIX missing from metadata keys"

  _test_start "sel_suffix extracted from fields[3]"
  grep -q 'sel_suffix=.*fields\[3\]' "$init_file" && _test_pass \
    || _test_fail "sel_suffix not extracted from fields[3]"

  _test_start "guard checks is_dir AND sel_suffix AND RBUFFER"
  local guard
  guard=$(grep 'is_dir_selection.*sel_suffix\|sel_suffix.*is_dir_selection' "$init_file" 2>/dev/null | head -1)
  if [[ -n $guard && $guard == *is_dir_selection* && $guard == *sel_suffix* && $guard == *RBUFFER* ]]; then
    _test_pass
  else
    _test_fail "trailing-space guard incomplete"
  fi

  _test_start "IPREFIX/PREFIX/SUFFIX/ISUFFIX restored before compadd"
  grep -q 'IPREFIX=.*PREFIX=.*SUFFIX=.*ISUFFIX=' "$init_file" && _test_pass \
    || _test_fail "context not restored"

  _test_start "Path A descent guard present"
  grep -q 'LBUFFER.*\[^/\[:space:\]\]/\$' "$init_file" && _test_pass \
    || _test_fail "descent guard missing"

  _test_start "comment says 8 fields (not 7)"
  grep -q '8 fields per line' "$init_file" && _test_pass \
    || _test_fail "comment still says 7 fields"
fi

# ── Configuration tests: zsh options ─────────────────────────────────

echo ""
echo "=== Configuration Tests: zsh completion options (3 checks) ==="

local settings_file="${0:A:h}/../module/groups/common/settings.zsh"
local completion_file="${0:A:h}/../module/groups/completion/init.zsh"

_test_start "COMPLETE_IN_WORD enabled"
if [[ -f $settings_file ]]; then
  grep -q 'COMPLETE_IN_WORD' "$settings_file" && _test_pass \
    || _test_fail "not found in settings.zsh"
else
  _test_skip "settings.zsh not found"
fi

_test_start "ALWAYS_TO_END enabled"
if [[ -f $settings_file ]]; then
  grep -q 'ALWAYS_TO_END' "$settings_file" && _test_pass \
    || _test_fail "not found in settings.zsh"
else
  _test_skip "settings.zsh not found"
fi

_test_start "matcher-list includes substring matching"
if [[ -f $completion_file ]]; then
  grep -q 'l:|=\* r:|=\*' "$completion_file" && _test_pass \
    || _test_fail "'l:|=* r:|=*' not found"
else
  _test_skip "completion/init.zsh not found"
fi

# ── Summary ──────────────────────────────────────────────────────────

echo ""
echo "════════════════════════════════════════════════════"
printf "  Results: "
print -P "%F{green}$_pass passed%f, %F{red}$_fail failed%f, %F{yellow}$_skip skipped%f"
echo "════════════════════════════════════════════════════"

(( _fail == 0 )) && exit 0 || exit 1
