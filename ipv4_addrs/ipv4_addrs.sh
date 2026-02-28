#!/bin/sh
# Print all IPv4 addresses of the current host, excluding localhost (127.x.x.x).
case "$0" in
    */*) _lib_dir=$(dirname -- "$0") ;;
    *)
        _lib_dir=$(command -v -- "$0") || { printf 'error: cannot resolve path for %s\n' "$0" >&2; exit 1; }
        _lib_dir=$(dirname -- "$_lib_dir")
        ;;
esac
# shellcheck source=../lib.sh
. "$_lib_dir/../lib.sh"
script_dir=$(resolve_script_dir "$0") || exit 1
if command -v ip > /dev/null 2>&1; then
    ip addr show | awk -f "$script_dir/ipv4_addrs.awk"
elif command -v ifconfig > /dev/null 2>&1; then
    ifconfig -a | awk -f "$script_dir/ipv4_addrs.awk"
else
    printf 'error: neither ip nor ifconfig found\n' >&2
    exit 1
fi
