#!/bin/sh
# Read a UTC datetime string in YYYYMMDDhhmmss format from stdin
# and print the corresponding UNIX timestamp.
awk -f "$(dirname "$0")/to_unix_time.awk"
