#!/bin/sh
# Tests for from_unix_time.sh

PASS=0
FAIL=0
SCRIPT_DIR=$(dirname "$0")

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

# assert_roundtrip_unix: takes a UNIX timestamp, converts to datetime and back,
# and verifies the final result matches the original input.
assert_roundtrip_unix() {
    input=$1
    datetime=$(printf '%s\n' "$input" | "${SHELL_UNDER_TEST:-sh}" "$SCRIPT_DIR/from_unix_time.sh")
    actual=$(printf '%s\n' "$datetime" | "${SHELL_UNDER_TEST:-sh}" "$SCRIPT_DIR/../to_unix_time/to_unix_time.sh")
    if [ "$actual" = "$input" ]; then
        printf 'PASS (roundtrip unix->datetime->unix): %s -> %s -> %s\n' "$input" "$datetime" "$actual"
        PASS=$((PASS + 1))
    else
        printf 'FAIL (roundtrip unix->datetime->unix): %s -> %s -> expected %s, got %s\n' "$input" "$datetime" "$input" "$actual"
        FAIL=$((FAIL + 1))
    fi
}

# assert_roundtrip_datetime: takes a datetime string, converts to UNIX and back,
# and verifies the final result matches the original input.
assert_roundtrip_datetime() {
    input=$1
    unix=$(printf '%s\n' "$input" | "${SHELL_UNDER_TEST:-sh}" "$SCRIPT_DIR/../to_unix_time/to_unix_time.sh")
    actual=$(printf '%s\n' "$unix" | "${SHELL_UNDER_TEST:-sh}" "$SCRIPT_DIR/from_unix_time.sh")
    if [ "$actual" = "$input" ]; then
        printf 'PASS (roundtrip datetime->unix->datetime): %s -> %s -> %s\n' "$input" "$unix" "$actual"
        PASS=$((PASS + 1))
    else
        printf 'FAIL (roundtrip datetime->unix->datetime): %s -> %s -> expected %s, got %s\n' "$input" "$unix" "$input" "$actual"
        FAIL=$((FAIL + 1))
    fi
}

# Unit tests
assert_eq "0"          "19700101000000"
assert_eq "1565571600" "20190812010000"

# Property-based round-trip tests
assert_roundtrip_unix "0"
assert_roundtrip_unix "1"
assert_roundtrip_unix "86399"
assert_roundtrip_unix "86400"
assert_roundtrip_unix "1565571600"
assert_roundtrip_unix "1582934400"
assert_roundtrip_unix "1609459199"
assert_roundtrip_unix "1609459200"

assert_roundtrip_datetime "19700101000000"
assert_roundtrip_datetime "19700101000001"
assert_roundtrip_datetime "19700101235959"
assert_roundtrip_datetime "19700102000000"
assert_roundtrip_datetime "20190812010000"
assert_roundtrip_datetime "20200229120000"
assert_roundtrip_datetime "20201231235959"
assert_roundtrip_datetime "20210101000000"

printf '\n%d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
