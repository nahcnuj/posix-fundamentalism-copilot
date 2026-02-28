BEGIN {
    split("31 28 31 30 31 30 31 31 30 31 30 31", days_in_month)
}
{
    t = $0 + 0

    total_days = int(t / 86400)
    remaining  = t % 86400

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
        if (total_days < days_in_year) break
        total_days -= days_in_year
        year++
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
