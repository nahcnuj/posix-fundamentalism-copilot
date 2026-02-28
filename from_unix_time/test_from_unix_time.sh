#!/bin/sh
# Unit tests for from_unix_time.sh

PASS=0
FAIL=0
SCRIPT_DIR=$(dirname "$0")

# unix_to_local: convert a UNIX timestamp to a local datetime string using the system date command.
# Tries BSD date (-r) first, then GNU date (-d @).
unix_to_local() {
    date -r "$1" +%Y%m%d%H%M%S 2>/dev/null || date -d "@$1" +%Y%m%d%H%M%S
}

# assert_eq: takes an input string and expected output string,
# runs from_unix_time.sh with the input, and verifies the result matches the expected output.
assert_eq() {
    input=$1
    expected=$2
    actual=$(printf '%s\n' "$input" | "${SHELL_UNDER_TEST:-sh}" "$SCRIPT_DIR/from_unix_time.sh")
    if [ "$actual" = "$expected" ]; then
        printf 'PASS: %s -> %s\n' "$input" "$actual"
        PASS=$((PASS + 1))
    else
        printf 'FAIL: %s -> expected %s, got %s\n' "$input" "$expected" "$actual"
        FAIL=$((FAIL + 1))
    fi
}

assert_eq "0"          "$(unix_to_local 0)"
assert_eq "1565571600" "$(unix_to_local 1565571600)"

printf '\n%d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
