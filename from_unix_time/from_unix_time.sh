#!/bin/sh
# Read a UNIX timestamp from stdin
# and print the corresponding datetime string in YYYYMMDDhhmmss format in the local timezone.
# Note: only fixed-offset (DST-free) timezones are supported.
tz_offset=$(date +%z)
case "$tz_offset" in
    [+-][0-9][0-9][0-9][0-9]) : ;;
    *) printf 'error: date +%%z returned unexpected value: %s\n' "$tz_offset" >&2; exit 1 ;;
esac
script_dir=${0%/*}
[ "$script_dir" = "$0" ] && script_dir=.
awk -v tz_offset="$tz_offset" -f "$script_dir/from_unix_time.awk"
