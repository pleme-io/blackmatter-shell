# use_workspace <name>
#
# Syncs a specific named workspace from the tend config.
# Useful when a project .envrc only needs one workspace.
#
# Usage in .envrc:
#   use_workspace pleme-io
use_workspace() {
  local name="${1:?use_workspace requires a workspace name}"
  local args=("sync" "--quiet" "--workspace" "$name")

  if has tend; then
    local output
    output=$(tend "${args[@]}" 2>&1) || true
    if [[ -n "$output" ]]; then
      log_status "tend" "$output"
    fi
  fi
}
