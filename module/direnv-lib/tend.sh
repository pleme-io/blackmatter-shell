# use_tend [config_path]
#
# Ensures all repos in the tend workspace config are cloned.
# Runs tend sync silently; shows summary only if repos were cloned.
#
# Usage in .envrc:
#   use_tend                        # default config (~/.config/tend/config.yaml)
#   use_tend /path/to/config.yaml   # custom config path
use_tend() {
  local config="${1:-}"
  local args=("sync" "--quiet")
  [[ -n "$config" ]] && args+=("--config" "$config")

  if has tend; then
    local output
    output=$(tend "${args[@]}" 2>&1) || true
    if [[ -n "$output" ]]; then
      log_status "tend" "$output"
    fi
  fi
}
