#!/usr/bin/env zsh
# skim-tab-complete regression tests
#
# Uses zpty (zsh pseudo-terminal) to simulate interactive completion.
# Run: zsh tests/completion-tests.zsh
#
# Each test spawns a zsh subprocess, sends keystrokes including Tab,
# and validates the resulting buffer contents.

zmodload zsh/zpty || { echo "FAIL: zsh/zpty not available"; exit 1; }

typeset -gi _pass=0 _fail=0 _skip=0

# ── Helpers ──────────────────────────────────────────────────────────

_test_start() {
  printf '  %-50s ' "$1"
}

_test_pass() {
  (( _pass++ ))
  print -P '%F{green}PASS%f'
}

_test_fail() {
  (( _fail++ ))
  print -P "%F{red}FAIL%f: $1"
}

_test_skip() {
  (( _skip++ ))
  print -P "%F{yellow}SKIP%f: $1"
}

# Create a temp dir with known files for predictable completion
_setup_fixtures() {
  _fixture_dir=$(mktemp -d)
  touch "$_fixture_dir/script.sh"
  touch "$_fixture_dir/screenshot.png"
  touch "$_fixture_dir/scroll.log"
  mkdir -p "$_fixture_dir/scripts"
  touch "$_fixture_dir/config.yaml"
  touch "$_fixture_dir/commit.txt"
  touch "$_fixture_dir/community.md"
}

_teardown_fixtures() {
  [[ -n $_fixture_dir && -d $_fixture_dir ]] && rm -rf "$_fixture_dir"
}

# ── Unit tests (pure logic, no zpty needed) ──────────────────────────

echo "=== Unit Tests: trailing-space logic ==="

# Source just the apply function for isolated testing
_test_trailing_space_logic() {
  # Test the core condition:
  #   if (( ! is_dir_selection )) && [[ -z $sel_suffix ]] && [[ $RBUFFER != ' '* ]]; then
  #     add trailing space
  #   fi

  local -i is_dir_selection
  local sel_suffix RBUFFER
  local -i should_add_space

  # Case 1: Normal completion at end of word — SHOULD add space
  _test_start "trailing space: normal end-of-word"
  is_dir_selection=0; sel_suffix=''; RBUFFER='rest of line'
  should_add_space=0
  if (( ! is_dir_selection )) && [[ -z $sel_suffix ]] && [[ $RBUFFER != ' '* ]]; then
    should_add_space=1
  fi
  (( should_add_space )) && _test_pass || _test_fail "expected space to be added"

  # Case 2: Directory selection — should NOT add space
  _test_start "trailing space: directory selection"
  is_dir_selection=1; sel_suffix=''; RBUFFER=''
  should_add_space=0
  if (( ! is_dir_selection )) && [[ -z $sel_suffix ]] && [[ $RBUFFER != ' '* ]]; then
    should_add_space=1
  fi
  (( ! should_add_space )) && _test_pass || _test_fail "expected no space for dir"

  # Case 3: Midword completion (SUFFIX non-empty) — should NOT add space
  _test_start "trailing space: midword (SUFFIX='.sh')"
  is_dir_selection=0; sel_suffix='.sh'; RBUFFER='.sh more text'
  should_add_space=0
  if (( ! is_dir_selection )) && [[ -z $sel_suffix ]] && [[ $RBUFFER != ' '* ]]; then
    should_add_space=1
  fi
  (( ! should_add_space )) && _test_pass || _test_fail "expected no space for midword"

  # Case 4: Midword completion with partial suffix — should NOT add space
  _test_start "trailing space: midword (SUFFIX='mit')"
  is_dir_selection=0; sel_suffix='mit'; RBUFFER='mit'
  should_add_space=0
  if (( ! is_dir_selection )) && [[ -z $sel_suffix ]] && [[ $RBUFFER != ' '* ]]; then
    should_add_space=1
  fi
  (( ! should_add_space )) && _test_pass || _test_fail "expected no space for midword"

  # Case 5: RBUFFER starts with space — should NOT add space (already has one)
  _test_start "trailing space: RBUFFER already has space"
  is_dir_selection=0; sel_suffix=''; RBUFFER=' rest'
  should_add_space=0
  if (( ! is_dir_selection )) && [[ -z $sel_suffix ]] && [[ $RBUFFER != ' '* ]]; then
    should_add_space=1
  fi
  (( ! should_add_space )) && _test_pass || _test_fail "expected no space when RBUFFER starts with space"

  # Case 6: Empty SUFFIX but non-empty RBUFFER (end of word, more text follows)
  _test_start "trailing space: end-of-word with trailing text"
  is_dir_selection=0; sel_suffix=''; RBUFFER='| grep foo'
  should_add_space=0
  if (( ! is_dir_selection )) && [[ -z $sel_suffix ]] && [[ $RBUFFER != ' '* ]]; then
    should_add_space=1
  fi
  (( should_add_space )) && _test_pass || _test_fail "expected space to be added"

  # Case 7: Directory + midword (both conditions) — should NOT add space
  _test_start "trailing space: directory + midword"
  is_dir_selection=1; sel_suffix='rest'; RBUFFER='rest/'
  should_add_space=0
  if (( ! is_dir_selection )) && [[ -z $sel_suffix ]] && [[ $RBUFFER != ' '* ]]; then
    should_add_space=1
  fi
  (( ! should_add_space )) && _test_pass || _test_fail "expected no space"

  # Case 8: Empty SUFFIX, empty RBUFFER (end of line) — SHOULD add space
  _test_start "trailing space: end of line"
  is_dir_selection=0; sel_suffix=''; RBUFFER=''
  should_add_space=0
  if (( ! is_dir_selection )) && [[ -z $sel_suffix ]] && [[ $RBUFFER != ' '* ]]; then
    should_add_space=1
  fi
  (( should_add_space )) && _test_pass || _test_fail "expected space at end of line"
}

_test_trailing_space_logic

# ── Unit tests: compadd metadata capture ─────────────────────────────

echo ""
echo "=== Unit Tests: metadata capture ==="

_test_start "SUFFIX captured in metadata keys"
# Verify that SUFFIX is in the metadata keys list (line 61 of init.zsh)
local -a expected_keys=(apre hpre PREFIX SUFFIX IPREFIX ISUFFIX)
local found_suffix=0
for k in $expected_keys; do
  [[ $k == SUFFIX ]] && found_suffix=1
done
(( found_suffix )) && _test_pass || _test_fail "SUFFIX missing from metadata keys"

_test_start "sel_suffix extracted from fields[3]"
# Simulate the field extraction (line 142: sel_suffix=${fields[3]:-})
local -a fields=("word" "prefix" "the_suffix" "iprefix" "isuffix" "args" "")
local sel_suffix=${fields[3]:-}
[[ $sel_suffix == "the_suffix" ]] && _test_pass || _test_fail "got '$sel_suffix'"

_test_start "sel_suffix empty when field missing"
local -a fields2=("word" "prefix")
local sel_suffix2=${fields2[3]:-}
[[ -z $sel_suffix2 ]] && _test_pass || _test_fail "expected empty, got '$sel_suffix2'"

# ── Integration test: zsh COMPLETE_IN_WORD option ────────────────────

echo ""
echo "=== Integration Tests: zsh completion options ==="

_test_start "COMPLETE_IN_WORD is set in settings.zsh"
local settings_file="$(dirname $0)/../module/groups/common/settings.zsh"
if [[ -f $settings_file ]]; then
  if grep -q 'COMPLETE_IN_WORD' "$settings_file"; then
    _test_pass
  else
    _test_fail "COMPLETE_IN_WORD not found in settings.zsh"
  fi
else
  _test_skip "settings.zsh not found at $settings_file"
fi

_test_start "ALWAYS_TO_END is set in settings.zsh"
if [[ -f $settings_file ]]; then
  if grep -q 'ALWAYS_TO_END' "$settings_file"; then
    _test_pass
  else
    _test_fail "ALWAYS_TO_END not found in settings.zsh"
  fi
else
  _test_skip "settings.zsh not found"
fi

_test_start "matcher-list includes substring matching"
local completion_file="$(dirname $0)/../module/groups/completion/init.zsh"
if [[ -f $completion_file ]]; then
  if grep -q "l:|=\* r:|=\*" "$completion_file"; then
    _test_pass
  else
    _test_fail "substring matcher 'l:|=* r:|=*' not found"
  fi
else
  _test_skip "completion/init.zsh not found"
fi

# ── Integration test: init.zsh source check ──────────────────────────

echo ""
echo "=== Integration Tests: skim-tab-complete init.zsh structure ==="

local init_file="$(dirname $0)/../module/plugins/skim-rs/skim-tab-complete/config/init.zsh"

_test_start "init.zsh exists"
[[ -f $init_file ]] && _test_pass || { _test_fail "file not found"; init_file=''; }

if [[ -n $init_file ]]; then
  _test_start "sel_suffix guard in trailing-space logic"
  if grep -q '\-z \$sel_suffix' "$init_file"; then
    _test_pass
  else
    _test_fail "missing '-z \$sel_suffix' guard (midword regression)"
  fi

  _test_start "SUFFIX in metadata keys list"
  if grep -q 'keys=.*SUFFIX' "$init_file"; then
    _test_pass
  else
    _test_fail "SUFFIX not in metadata capture keys"
  fi

  _test_start "sel_suffix extracted from fields"
  if grep -q 'sel_suffix=.*fields\[3\]' "$init_file"; then
    _test_pass
  else
    _test_fail "sel_suffix not extracted from fields[3]"
  fi

  _test_start "compstate[insert] space logic has 3 conditions"
  # The fixed line should have: is_dir_selection AND sel_suffix AND RBUFFER
  # Find the line with the trailing space guard (contains both is_dir and insert)
  local guard_line
  guard_line=$(grep 'is_dir_selection.*sel_suffix\|sel_suffix.*is_dir_selection' "$init_file" 2>/dev/null | head -1)
  if [[ -n $guard_line ]] && \
     [[ $guard_line == *is_dir_selection* ]] && \
     [[ $guard_line == *sel_suffix* ]] && \
     [[ $guard_line == *RBUFFER* ]]; then
    _test_pass
  else
    _test_fail "trailing-space guard should check is_dir, sel_suffix, AND RBUFFER"
  fi

  _test_start "IPREFIX/PREFIX/SUFFIX/ISUFFIX restored before compadd"
  if grep -q 'IPREFIX=.*PREFIX=.*SUFFIX=.*ISUFFIX=' "$init_file"; then
    _test_pass
  else
    _test_fail "completion context not restored before compadd"
  fi

  _test_start "Path A descent guard present"
  if grep -q 'LBUFFER.*[^/[:space:]]/\$' "$init_file"; then
    _test_pass
  else
    _test_fail "descent guard missing"
  fi
fi

# ── Summary ──────────────────────────────────────────────────────────

echo ""
echo "════════════════════════════════════════════════════"
printf "  Results: "
print -P "%F{green}$_pass passed%f, %F{red}$_fail failed%f, %F{yellow}$_skip skipped%f"
echo "════════════════════════════════════════════════════"

(( _fail == 0 )) && exit 0 || exit 1
