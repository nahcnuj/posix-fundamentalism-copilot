#!/bin/sh
# Print all IPv4 addresses of the current host, excluding localhost (127.x.x.x).
if command -v ip > /dev/null 2>&1; then
    ip addr show | awk -f "${0%/*}/ipv4_addrs.awk"
elif command -v ifconfig > /dev/null 2>&1; then
    ifconfig -a | awk -f "${0%/*}/ipv4_addrs.awk"
else
    printf 'error: neither ip nor ifconfig found\n' >&2
    exit 1
fi
