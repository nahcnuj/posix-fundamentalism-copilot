#!/bin/sh
# Print all IPv4 addresses of the current host, excluding localhost (127.x.x.x).
# shellcheck source=../lib.sh
case "$0" in
    */*) _script_path=$0 ;;
    *) _script_path=$(command -v "$0") || { printf 'error: cannot resolve path for %s\n' "$0" >&2; exit 1; } ;;
esac
_lib_sh_dir=$(dirname "$_script_path")/..
. "$_lib_sh_dir/lib.sh"
script_dir=$(resolve_script_dir "$0") || exit 1
if command -v ip > /dev/null 2>&1; then
    ip addr show | awk -f "$script_dir/ipv4_addrs.awk"
elif command -v ifconfig > /dev/null 2>&1; then
    ifconfig -a | awk -f "$script_dir/ipv4_addrs.awk"
else
    printf 'error: neither ip nor ifconfig found\n' >&2
    exit 1
fi
