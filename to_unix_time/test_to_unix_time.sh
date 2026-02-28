#!/bin/sh
# Tests for to_unix_time.sh

PASS=0
FAIL=0

# assert_eq: takes an input string and expected output string,
# runs to_unix_time.sh with the input, and verifies the result matches the expected output.
assert_eq() {
    input=$1
    expected=$2
    actual=$(printf '%s\n' "$input" | "${SHELL_UNDER_TEST:-sh}" "$(dirname "$0")/to_unix_time.sh")
    if [ "$actual" = "$expected" ]; then
        printf 'PASS: %s -> %s\n' "$input" "$actual"
        PASS=$((PASS + 1))
    else
        printf 'FAIL: %s -> expected %s, got %s\n' "$input" "$expected" "$actual"
        FAIL=$((FAIL + 1))
    fi
}

assert_eq "19700101000000" "0"
assert_eq "20190812010000" "1565571600"

printf '\n%d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
