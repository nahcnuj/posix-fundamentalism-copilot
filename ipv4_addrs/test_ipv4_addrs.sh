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
    actual=$(PATH="$fake_dir:$PATH" "${SHELL_UNDER_TEST:-sh}" "$SCRIPT_DIR/ipv4_addrs.sh")
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

# assert_addrs_ifconfig: tests awk parsing of ifconfig-style output.
# Feeds ifconfig-formatted data through a fake ip command (using PATH="$fake_dir:$PATH"),
# verifying the awk parser handles both plain 'inet X.X.X.X' and 'inet addr:X.X.X.X' formats.
# Since the same awk program handles both ip and ifconfig output, this tests the parser
# without needing a restricted PATH or awk/cat wrapper scripts.
assert_addrs_ifconfig() {
    description=$1
    fake_ifconfig_output=$2
    expected=$3

    fake_dir=$(mktemp -d "${TMPDIR:-/tmp}/test_ipv4_addrs.XXXXXX") || return 1
    printf '#!/bin/sh\ncat <<'"'"'EOF'"'"'\n%s\nEOF\n' "$fake_ifconfig_output" > "$fake_dir/ip"
    chmod +x "$fake_dir/ip"
    actual=$(PATH="$fake_dir:$PATH" "${SHELL_UNDER_TEST:-sh}" "$SCRIPT_DIR/ipv4_addrs.sh")
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
    sh_cmd="${SHELL_UNDER_TEST:-sh}"
    case "$sh_cmd" in
        /*) : ;;
        *) sh_cmd=$(command -v "$sh_cmd") ;;
    esac
    err_output=$(PATH="" "$sh_cmd" "$SCRIPT_DIR/ipv4_addrs.sh" 2>&1)
    rc=$?
    if [ "$rc" -ne 0 ] && printf '%s' "$err_output" | grep -q 'error:'; then
        printf 'PASS: no ip/ifconfig causes non-zero exit with error message\n'
        PASS=$((PASS + 1))
    else
        printf 'FAIL: expected non-zero exit with error message, got exit %d and output: %s\n' "$rc" "$err_output"
        FAIL=$((FAIL + 1))
    fi
}
assert_no_ip_no_ifconfig

printf '\n%d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
