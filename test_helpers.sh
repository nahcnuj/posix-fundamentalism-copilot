#!/bin/sh
# Shared test helpers for unix time tests
# Note: these helpers are only consistent with the scripts under fixed-offset (DST-free) timezones.

# unix_to_local: convert a UNIX timestamp to a local datetime string using the system date command.
# Tries BSD date (-r) first, then GNU date (-d @).
# Note: the system date command is DST-aware, while the scripts use a single fixed offset
# (date +%z at runtime). Results agree only when the timezone has no DST transitions.
unix_to_local() {
    date -r "$1" +%Y%m%d%H%M%S 2>/dev/null || date -d "@$1" +%Y%m%d%H%M%S
}
