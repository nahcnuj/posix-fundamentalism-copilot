#!/bin/sh
# Read a UNIX timestamp from stdin
# and print the corresponding datetime string in YYYYMMDDhhmmss format in the local timezone.
# Note: only fixed-offset (DST-free) timezones are supported.
tz_offset=$(date +%z)
case "$tz_offset" in
    [+-][0-9][0-9][0-9][0-9]) ;;
    *) printf 'error: date +%%z returned unexpected value: %s\n' "$tz_offset" >&2; exit 1 ;;
esac
awk -v tz_offset="$tz_offset" '
BEGIN {
    split("31 28 31 30 31 30 31 31 30 31 30 31", days_in_month)
    sign = (substr(tz_offset, 1, 1) == "-") ? -1 : 1
    hh = substr(tz_offset, 2, 2) + 0
    mm = substr(tz_offset, 4, 2) + 0
    offset_sec = sign * (hh * 3600 + mm * 60)
}
{
    t = $0 + 0 + offset_sec

    remaining  = t % 86400
    total_days = (t - remaining) / 86400
    if (remaining < 0) {
        remaining += 86400
        total_days--
    }

    hour = int(remaining / 3600)
    remaining = remaining % 3600
    min  = int(remaining / 60)
    sec  = remaining % 60

    year = 1970
    while (1) {
        if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0)
            days_in_year = 366
        else
            days_in_year = 365
        if (total_days >= 0 && total_days < days_in_year) break
        if (total_days < 0) {
            year--
            if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0)
                days_in_year = 366
            else
                days_in_year = 365
            total_days += days_in_year
        } else {
            total_days -= days_in_year
            year++
        }
    }

    is_leap = ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0)
    month = 1
    while (1) {
        dim = days_in_month[month]
        if (month == 2 && is_leap) dim++
        if (total_days < dim) break
        total_days -= dim
        month++
    }

    day = total_days + 1

    printf "%04d%02d%02d%02d%02d%02d\n", year, month, day, hour, min, sec
}
'
