#!/bin/bash
# Run all unit tests

SCRIPT_DIR=$(dirname "$0")

FAIL=0
for test_script in "$SCRIPT_DIR"/*/test_*.sh; do
    "${SHELL:-sh}" "$test_script" || FAIL=$((FAIL + 1))
done
[ "$FAIL" -eq 0 ]
