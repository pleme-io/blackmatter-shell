# Shell Functions - Autoloaded on first call
# Each function lives in its own file under autoload/
# Zero startup cost: functions are loaded only when first invoked

local fn_dir="$HOME/.config/shell/groups/functions/autoload"

if [[ -d "$fn_dir" ]]; then
  fpath=("$fn_dir" ${fpath[@]})
  # Auto-discover all functions in the directory — no manual list to maintain
  autoload -Uz $fn_dir/*(:t)
fi
