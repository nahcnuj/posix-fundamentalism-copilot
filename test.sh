#!/bin/sh
# Run all unit tests

SCRIPT_DIR=$(dirname "$0")

"${SHELL_UNDER_TEST:-sh}" "$SCRIPT_DIR/to_unix_time/test_to_unix_time.sh"
"${SHELL_UNDER_TEST:-sh}" "$SCRIPT_DIR/from_unix_time/test_from_unix_time.sh"
