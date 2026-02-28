#!/bin/sh
# Read a UNIX timestamp from stdin
# and print the corresponding datetime string in YYYYMMDDhhmmss format in the local timezone.
# Note: only fixed-offset (DST-free) timezones are supported.
tz_offset=$(date +%z)
case "$tz_offset" in
    [+-][0-9][0-9][0-9][0-9]) : ;;
    *) printf 'error: date +%%z returned unexpected value: %s\n' "$tz_offset" >&2; exit 1 ;;
esac
script_path=$0
case "$script_path" in
    */*) ;;
    *)
        script_path=$(command -v -- "$0") || {
            printf 'error: cannot resolve path for %s\n' "$0" >&2
            exit 1
        }
        ;;
esac
script_dir=$(dirname -- "$script_path")
awk -v tz_offset="$tz_offset" -f "$script_dir/from_unix_time.awk"
