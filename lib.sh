# shellcheck source=./lib/resolve_script_dir.sh
[ -n "$script_dir" ] || { printf 'error: script_dir must be set before sourcing lib.sh\n' >&2; exit 1; }
. "$script_dir/../lib/resolve_script_dir.sh"
