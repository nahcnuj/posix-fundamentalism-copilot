#!/bin/sh
# Property-based tests verifying round-trip conversion between UNIX timestamps and UTC datetime strings.
# Tests both to_unix_time.sh and from_unix_time.sh together.

PASS=0
FAIL=0
SCRIPT_DIR=$(dirname "$0")

SEED=${SEED:-$(awk 'BEGIN{srand(); print int(rand() * 2147483647)}')}
printf 'SEED=%s\n' "$SEED"

# assert_roundtrip_unix: takes a UNIX timestamp, pipes through from_unix_time then to_unix_time
# (unix->datetime->unix), and verifies the result matches the original input.
assert_roundtrip_unix() {
    input=$1
    actual=$(printf '%s\n' "$input" | "$SHELL" "$SCRIPT_DIR/../from_unix_time/from_unix_time.sh" | "$SHELL" "$SCRIPT_DIR/../to_unix_time/to_unix_time.sh")
    if [ "$actual" = "$input" ]; then
        printf 'PASS (unix->datetime->unix): %s -> %s\n' "$input" "$actual"
        PASS=$((PASS + 1))
    else
        printf 'FAIL (unix->datetime->unix): %s -> expected %s, got %s\n' "$input" "$input" "$actual"
        FAIL=$((FAIL + 1))
    fi
}

# assert_roundtrip_datetime: takes a datetime string, pipes through to_unix_time then from_unix_time
# (datetime->unix->datetime), and verifies the result matches the original input.
assert_roundtrip_datetime() {
    input=$1
    actual=$(printf '%s\n' "$input" | "$SHELL" "$SCRIPT_DIR/../to_unix_time/to_unix_time.sh" | "$SHELL" "$SCRIPT_DIR/../from_unix_time/from_unix_time.sh")
    if [ "$actual" = "$input" ]; then
        printf 'PASS (datetime->unix->datetime): %s -> %s\n' "$input" "$actual"
        PASS=$((PASS + 1))
    else
        printf 'FAIL (datetime->unix->datetime): %s -> expected %s, got %s\n' "$input" "$input" "$actual"
        FAIL=$((FAIL + 1))
    fi
}

for ts in $(awk -v seed="$SEED" 'BEGIN { srand(seed); for (i = 0; i < 20; i++) print int(rand() * 2147483647) }'); do
    assert_roundtrip_unix "$ts"
done

for dt in $(awk -v seed="$SEED" 'BEGIN {
    srand(seed)
    for (i = 0; i < 20; i++) {
        y = 1970 + int(rand() * 130)
        m = 1 + int(rand() * 12)
        d = 1 + int(rand() * 28)
        h = int(rand() * 24)
        mi = int(rand() * 60)
        s = int(rand() * 60)
        printf "%04d%02d%02d%02d%02d%02d\n", y, m, d, h, mi, s
    }
}'); do
    assert_roundtrip_datetime "$dt"
done

printf '\n%d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
