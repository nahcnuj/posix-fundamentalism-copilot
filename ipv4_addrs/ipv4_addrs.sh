#!/bin/sh
# Print all IPv4 addresses of the current host, excluding localhost (127.x.x.x).
script_path=$0; case $0 in */*) ;; *) script_path=$(command -v -- "$0") || { printf 'error: cannot resolve path to %s\n' "$0" >&2; exit 1; } ;; esac
script_dir=${script_path%/*}
awk_prog=$script_dir/ipv4_addrs.awk
[ -r "$awk_prog" ] || { printf 'error: cannot find AWK program: %s\n' "$awk_prog" >&2; exit 1; }
if command -v ip > /dev/null 2>&1; then
    ip addr show | awk -f "$awk_prog"
elif command -v ifconfig > /dev/null 2>&1; then
    ifconfig -a | awk -f "$awk_prog"
else
    printf 'error: neither ip nor ifconfig found\n' >&2
    exit 1
fi
