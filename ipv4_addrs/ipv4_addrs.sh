#!/bin/sh
# Print all IPv4 addresses of the current host, excluding localhost (127.x.x.x).
awk_prog='/inet / {
    for (i = 1; i <= NF; i++) {
        if ($i == "inet") {
            addr = $(i+1)
            sub(/^addr:/, "", addr)
            sub(/\/.*/, "", addr)
            if (addr !~ /^127\./) {
                print addr
            }
        }
    }
}'
if command -v ip > /dev/null 2>&1; then
    ip addr show | awk "$awk_prog"
elif command -v ifconfig > /dev/null 2>&1; then
    ifconfig -a | awk "$awk_prog"
else
    printf 'error: neither ip nor ifconfig found\n' >&2
    exit 1
fi
