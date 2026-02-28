#!/bin/sh
# Unit tests for ipv4_addrs.sh

PASS=0
FAIL=0
SCRIPT_DIR=$(dirname "$0")

# assert_addrs: runs ipv4_addrs.sh with a fake ip/ifconfig command producing the given output,
# and verifies the result matches the expected newline-separated list of addresses.
assert_addrs() {
    description=$1
    fake_ip_output=$2
    expected=$3

    fake_dir=$(mktemp -d "${TMPDIR:-/tmp}/test_ipv4_addrs.XXXXXX") || return 1
    printf '#!/bin/sh\ncat <<'"'"'EOF'"'"'\n%s\nEOF\n' "$fake_ip_output" > "$fake_dir/ip"
    chmod +x "$fake_dir/ip"
    actual=$(PATH="$fake_dir:$PATH" "$SHELL" "$SCRIPT_DIR/ipv4_addrs.sh")
    rc=$?
    rm -rf "$fake_dir"
    if [ "$rc" -eq 0 ] && [ "$actual" = "$expected" ]; then
        printf 'PASS: %s\n' "$description"
        PASS=$((PASS + 1))
    else
        printf 'FAIL: %s -> expected %s, got %s (exit %d)\n' "$description" "$expected" "$actual" "$rc"
        FAIL=$((FAIL + 1))
    fi
}

# assert_addrs_ifconfig: runs ipv4_addrs.sh with a fake ifconfig command in a PATH where
# ip is not available, to exercise the ifconfig fallback branch.
# awk and cat wrappers are placed in fake_dir because on many systems (e.g. Linux) awk, cat,
# and ip all live in the same directory (/usr/bin or /bin), so simply excluding ip's directory
# from PATH would also remove awk and cat. The wrappers proxy to the real binaries.
assert_addrs_ifconfig() {
    description=$1
    fake_ifconfig_output=$2
    expected=$3

    sh_cmd=$(command -v "$SHELL")
    real_awk=$(command -v awk)
    real_cat=$(command -v cat)
    real_dirname=$(command -v dirname)
    fake_dir=$(mktemp -d "${TMPDIR:-/tmp}/test_ipv4_addrs.XXXXXX") || return 1
    printf '#!/bin/sh\ncat <<'"'"'EOF'"'"'\n%s\nEOF\n' "$fake_ifconfig_output" > "$fake_dir/ifconfig"
    chmod +x "$fake_dir/ifconfig"
    printf '#!/bin/sh\nexec "%s" "$@"\n' "$real_awk" > "$fake_dir/awk"
    chmod +x "$fake_dir/awk"
    printf '#!/bin/sh\nexec "%s" "$@"\n' "$real_cat" > "$fake_dir/cat"
    chmod +x "$fake_dir/cat"
    printf '#!/bin/sh\nexec "%s" "$@"\n' "$real_dirname" > "$fake_dir/dirname"
    chmod +x "$fake_dir/dirname"
    actual=$(PATH="$fake_dir" "$sh_cmd" "$SCRIPT_DIR/ipv4_addrs.sh")
    rc=$?
    rm -rf "$fake_dir"
    if [ "$rc" -eq 0 ] && [ "$actual" = "$expected" ]; then
        printf 'PASS: %s\n' "$description"
        PASS=$((PASS + 1))
    else
        printf 'FAIL: %s -> expected %s, got %s (exit %d)\n' "$description" "$expected" "$actual" "$rc"
        FAIL=$((FAIL + 1))
    fi
}

# ip addr show format (Linux)
assert_addrs "ip: single address" \
    "2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500
    link/ether 00:11:22:33:44:55 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.100/24 brd 192.168.1.255 scope global eth0
    inet6 fe80::1/64 scope link" \
    "192.168.1.100"

assert_addrs "ip: multiple addresses" \
    "2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500
    inet 10.0.0.1/8 scope global eth0
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500
    inet 172.16.0.1/16 scope global eth1" \
    "10.0.0.1
172.16.0.1"

assert_addrs "ip: localhost excluded" \
    "1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536
    inet 127.0.0.1/8 scope host lo
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500
    inet 192.168.1.100/24 scope global eth0" \
    "192.168.1.100"

assert_addrs "ip: only localhost yields empty output" \
    "1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536
    inet 127.0.0.1/8 scope host lo" \
    ""

# ifconfig format (BSD/macOS)
assert_addrs_ifconfig "ifconfig: single address" \
    "eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.1.100  netmask 255.255.255.0  broadcast 192.168.1.255
        inet6 fe80::1  prefixlen 64  scopeid 0x20<link>" \
    "192.168.1.100"

assert_addrs_ifconfig "ifconfig: multiple addresses" \
    "eth0: flags=4163<UP>  mtu 1500
        inet 10.0.0.1  netmask 255.0.0.0
eth1: flags=4163<UP>  mtu 1500
        inet 172.16.0.1  netmask 255.255.0.0" \
    "10.0.0.1
172.16.0.1"

assert_addrs_ifconfig "ifconfig: localhost excluded" \
    "lo0: flags=8049<UP,LOOPBACK,RUNNING>
        inet 127.0.0.1 netmask 0xff000000
eth0: flags=4163<UP>
        inet 192.168.1.100 netmask 255.255.255.0" \
    "192.168.1.100"

assert_addrs_ifconfig "ifconfig: inet addr: prefix stripped" \
    "eth0: flags=4163<UP>  mtu 1500
        inet addr:192.168.1.100  Bcast:192.168.1.255  Mask:255.255.255.0" \
    "192.168.1.100"

# assert_no_ip_no_ifconfig: verifies that the script exits non-zero and prints an error
# when neither ip nor ifconfig is available.
assert_no_ip_no_ifconfig() {
    sh_cmd=$(command -v "$SHELL")
    real_dirname=$(command -v dirname)
    fake_dir=$(mktemp -d "${TMPDIR:-/tmp}/test_ipv4_addrs.XXXXXX") || return 1
    printf '#!/bin/sh\nexec "%s" "$@"\n' "$real_dirname" > "$fake_dir/dirname"
    chmod +x "$fake_dir/dirname"
    err_output=$(PATH="$fake_dir" "$sh_cmd" "$SCRIPT_DIR/ipv4_addrs.sh" 2>&1)
    rc=$?
    rm -rf "$fake_dir"
    if [ "$rc" -ne 0 ] && printf '%s' "$err_output" | grep -q 'error:'; then
        printf 'PASS: no ip/ifconfig causes non-zero exit with error message\n'
        PASS=$((PASS + 1))
    else
        printf 'FAIL: expected non-zero exit with error message, got exit %d and output: %s\n' "$rc" "$err_output"
        FAIL=$((FAIL + 1))
    fi
}
assert_no_ip_no_ifconfig

# assert_bare_name_via_path: verifies the '*) command -v' branch when the script
# is invoked as a bare name with $SCRIPT_DIR in PATH.
# BASH_SOURCE[0] is set to the absolute path by bash (found via PATH), so kcov can track it.
assert_bare_name_via_path() {
    fake_dir=$(mktemp -d "${TMPDIR:-/tmp}/test_ipv4_addrs.XXXXXX") || return 1
    printf '#!/bin/sh\nprintf "2: eth0:\\n    inet 192.168.1.1/24 scope global eth0\\n"\n' > "$fake_dir/ip"
    chmod +x "$fake_dir/ip"
    actual=$(PATH="$SCRIPT_DIR:$fake_dir:$PATH" "$SHELL" ipv4_addrs.sh)
    rc=$?
    rm -rf "$fake_dir"
    if [ "$rc" -eq 0 ] && [ "$actual" = "192.168.1.1" ]; then
        printf 'PASS: ipv4_addrs.sh (bare name via PATH) -> %s\n' "$actual"
        PASS=$((PASS + 1))
    else
        printf 'FAIL: ipv4_addrs.sh (bare name via PATH) -> expected 192.168.1.1, got %s (exit %d)\n' "$actual" "$rc"
        FAIL=$((FAIL + 1))
    fi
}
assert_bare_name_via_path

printf '\n%d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
