#!/bin/sh
# Read a datetime string in YYYYMMDDhhmmss format from stdin (interpreted in local timezone)
# and print the corresponding UNIX timestamp.
# Note: only fixed-offset (DST-free) timezones are supported.
tz_offset=$(date +%z)
case "$tz_offset" in
    [+-][0-9][0-9][0-9][0-9]) : ;;
    *) printf 'error: date +%%z returned unexpected value: %s\n' "$tz_offset" >&2; exit 1 ;;
esac
resolve_script_dir() {
    case "$1" in
        */*) dirname -- "$1" ;;
        *)
            _p=$(command -v -- "$1") || {
                printf 'error: cannot resolve path for %s\n' "$1" >&2
                return 1
            }
            dirname -- "$_p"
            ;;
    esac
}
script_dir=$(resolve_script_dir "$0") || exit 1
awk -v tz_offset="$tz_offset" -f "$script_dir/to_unix_time.awk"
