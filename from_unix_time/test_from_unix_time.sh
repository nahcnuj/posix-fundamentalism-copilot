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
    actual=$(printf '%s\n' "$input" | "$SHELL" "$SCRIPT_DIR/from_unix_time.sh")
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

# assert_eq_with_tz: verifies that the script converts input correctly for a
# given controlled tz_offset (using a fake date command returning that offset).
assert_eq_with_tz() {
    tz_offset=$1
    input=$2
    expected=$3
    fake_dir=$(mktemp -d "${TMPDIR:-/tmp}/test_from_unix_time.XXXXXX") || return 1
    printf '#!/bin/sh\necho %s\n' "$tz_offset" > "$fake_dir/date"
    chmod +x "$fake_dir/date"
    actual=$(printf '%s\n' "$input" | PATH="$fake_dir:$PATH" "$SHELL" "$SCRIPT_DIR/from_unix_time.sh")
    rc=$?
    rm -rf "$fake_dir"
    if [ "$rc" -eq 0 ] && [ "$actual" = "$expected" ]; then
        printf 'PASS: %s (tz=%s) -> %s\n' "$input" "$tz_offset" "$actual"
        PASS=$((PASS + 1))
    else
        printf 'FAIL: %s (tz=%s) -> expected %s, got %s (exit %d)\n' "$input" "$tz_offset" "$expected" "$actual" "$rc"
        FAIL=$((FAIL + 1))
    fi
}

# Valid tz_offset patterns (line 7: [+-][0-9][0-9][0-9][0-9])
assert_eq_with_tz "+0000" "0"          "19700101000000"
assert_eq_with_tz "+0900" "0"          "19700101090000"
assert_eq_with_tz "+0530" "0"          "19700101053000"
assert_eq_with_tz "-0700" "0"          "19691231170000"

# assert_rejects_invalid_tz: verifies that the script exits non-zero when
# date +%z returns a value that does not match the expected ±HHMM format.
assert_rejects_invalid_tz() {
    fake_dir=$(mktemp -d "${TMPDIR:-/tmp}/test_from_unix_time.XXXXXX") || return 1
    printf '#!/bin/sh\necho BADTZ\n' > "$fake_dir/date"
    chmod +x "$fake_dir/date"
    printf '0\n' | PATH="$fake_dir:$PATH" "$SHELL" "$SCRIPT_DIR/from_unix_time.sh" >/dev/null 2>&1
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

# assert_bare_name_not_in_path: verifies that the bare-name invocation path
# (the '*) command -v' branch) is reachable and exits non-zero when the script
# cannot be resolved via PATH.
assert_bare_name_not_in_path() {
    fake_dir=$(mktemp -d "${TMPDIR:-/tmp}/test_from_unix_time.XXXXXX") || return 1
    printf '#!/bin/sh\necho +0000\n' > "$fake_dir/date"
    chmod +x "$fake_dir/date"
    ( cd "$SCRIPT_DIR" && printf '0\n' | PATH="$fake_dir" "$SHELL" from_unix_time.sh ) >/dev/null 2>&1
    rc=$?
    rm -rf "$fake_dir"
    if [ "$rc" -ne 0 ]; then
        printf 'PASS: from_unix_time.sh (bare name, not in PATH) causes non-zero exit (%d)\n' "$rc"
        PASS=$((PASS + 1))
    else
        printf 'FAIL: expected non-zero exit for bare-name invocation without PATH, got 0\n'
        FAIL=$((FAIL + 1))
    fi
}
assert_bare_name_not_in_path

printf '\n%d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
