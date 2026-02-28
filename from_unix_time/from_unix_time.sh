#!/bin/sh
# Read a UNIX timestamp from stdin
# and print the corresponding UTC datetime string in YYYYMMDDhhmmss format.
awk -f "$(dirname "$0")/from_unix_time.awk"
