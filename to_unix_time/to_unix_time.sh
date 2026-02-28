#!/bin/sh
# Read a datetime string in YYYYMMDDhhmmss format from stdin (interpreted in local timezone)
# and print the corresponding UNIX timestamp.
# Note: only fixed-offset (DST-free) timezones are supported.
tz_offset=$(date +%z)
case "$tz_offset" in
    [+-][0-9][0-9][0-9][0-9]) : ;;
    *) printf 'error: date +%%z returned unexpected value: %s\n' "$tz_offset" >&2; exit 1 ;;
esac
script_path=$0; case $0 in */*) ;; *) script_path=$(command -v -- "$0") || { printf 'error: cannot resolve path to %s\n' "$0" >&2; exit 1; } ;; esac
script_dir=${script_path%/*}
awk_prog=$script_dir/to_unix_time.awk
[ -r "$awk_prog" ] || { printf 'error: cannot find AWK program: %s\n' "$awk_prog" >&2; exit 1; }
awk -v tz_offset="$tz_offset" -f "$awk_prog"
