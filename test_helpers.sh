#!/bin/sh
# Shared test helpers for unix time tests

# unix_to_local: convert a UNIX timestamp to a local datetime string using the system date command.
# Tries BSD date (-r) first, then GNU date (-d @).
unix_to_local() {
    date -r "$1" +%Y%m%d%H%M%S 2>/dev/null || date -d "@$1" +%Y%m%d%H%M%S
}
