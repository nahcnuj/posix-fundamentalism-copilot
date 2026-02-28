#!/bin/sh
# Read a UNIX timestamp from stdin
# and print the corresponding datetime string in YYYYMMDDhhmmss format in the local timezone.
# Note: only fixed-offset (DST-free) timezones are supported.
tz_offset=$(date +%z)
case "$tz_offset" in
    [+-][0-9][0-9][0-9][0-9]) : ;;
    *) printf 'error: date +%%z returned unexpected value: %s\n' "$tz_offset" >&2; exit 1 ;;
esac
# shellcheck source=../lib.sh
_lib_sh_dir=$(dirname -- "$0")/..
. "$_lib_sh_dir/lib.sh"
script_dir=$(resolve_script_dir "$0") || exit 1
awk -v tz_offset="$tz_offset" -f "$script_dir/from_unix_time.awk"
