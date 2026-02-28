#!/bin/sh
# Read a datetime string in YYYYMMDDhhmmss format from stdin (interpreted in local timezone)
# and print the corresponding UNIX timestamp.
# Note: only fixed-offset (DST-free) timezones are supported.
tz_offset=$(date +%z)
case "$tz_offset" in
    [+-][0-9][0-9][0-9][0-9]) : ;;
    *) printf 'error: date +%%z returned unexpected value: %s\n' "$tz_offset" >&2; exit 1 ;;
esac
# shellcheck source=../lib.sh
case "$0" in
    */*) _script_path=$0 ;;
    *) _script_path=$(command -v "$0") || { printf 'error: cannot resolve path for %s\n' "$0" >&2; exit 1; } ;;
esac
_lib_sh_dir=$(dirname "$_script_path")/..
. "$_lib_sh_dir/lib.sh"
script_dir=$(resolve_script_dir "$0") || exit 1
awk -v tz_offset="$tz_offset" -f "$script_dir/to_unix_time.awk"
