#!/bin/sh
# Print all IPv4 addresses of the current host, excluding localhost (127.x.x.x).
resolve_script_dir() {
    case "$1" in
        */*) dirname -- "$1" ;;
        *)
            _p=$(command -v -- "$1") || {
                printf 'error: cannot resolve path for %s\n' "$1" >&2
                return 1
            }
            dirname -- "$_p"
            ;;
    esac
}
script_dir=$(resolve_script_dir "$0") || exit 1
if command -v ip > /dev/null 2>&1; then
    ip addr show | awk -f "$script_dir/ipv4_addrs.awk"
elif command -v ifconfig > /dev/null 2>&1; then
    ifconfig -a | awk -f "$script_dir/ipv4_addrs.awk"
else
    printf 'error: neither ip nor ifconfig found\n' >&2
    exit 1
fi
