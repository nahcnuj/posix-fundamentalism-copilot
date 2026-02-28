#!/bin/sh
# Unit tests for from_unix_time.sh

PASS=0
FAIL=0
SCRIPT_DIR=$(dirname "$0")

# shellcheck source=../test_helpers.sh
# Note: unix_to_local in test_helpers.sh is only consistent with from_unix_time.sh
# in fixed-offset (DST-free) timezones. Tests should be run with such a timezone (e.g., via TZ=UTC).
. "$SCRIPT_DIR/../test_helpers.sh"

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

# assert_rejects_invalid_tz: verifies that the script exits non-zero when
# date +%z returns a value that does not match the expected ±HHMM format.
assert_rejects_invalid_tz() {
    fake_dir=$(mktemp -d)
    printf '#!/bin/sh\necho BADTZ\n' > "$fake_dir/date"
    chmod +x "$fake_dir/date"
    printf '0\n' | PATH="$fake_dir:$PATH" "${SHELL_UNDER_TEST:-sh}" "$SCRIPT_DIR/from_unix_time.sh" >/dev/null 2>&1
    rc=$?
    rm -rf "$fake_dir"
    if [ "$rc" -ne 0 ]; then
        printf 'PASS: invalid tz_offset causes non-zero exit (%d)\n' "$rc"
        PASS=$((PASS + 1))
    else
        printf 'FAIL: expected non-zero exit for invalid tz_offset, got 0\n'
        FAIL=$((FAIL + 1))
    fi
}
assert_rejects_invalid_tz

printf '\n%d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
