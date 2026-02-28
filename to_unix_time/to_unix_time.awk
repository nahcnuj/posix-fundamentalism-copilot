BEGIN {
    split("31 28 31 30 31 30 31 31 30 31 30 31", days_in_month)
}
{
    year  = substr($0, 1, 4) + 0
    month = substr($0, 5, 2) + 0
    day   = substr($0, 7, 2) + 0
    hour  = substr($0, 9, 2) + 0
    min   = substr($0, 11, 2) + 0
    sec   = substr($0, 13, 2) + 0

    total_days = 0
    for (y = 1970; y < year; y++) {
        if ((y % 4 == 0 && y % 100 != 0) || y % 400 == 0)
            total_days += 366
        else
            total_days += 365
    }

    is_leap = ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0)
    for (m = 1; m < month; m++) {
        total_days += days_in_month[m]
        if (m == 2 && is_leap) total_days += 1
    }

    total_days += day - 1

    print total_days * 86400 + hour * 3600 + min * 60 + sec
}
