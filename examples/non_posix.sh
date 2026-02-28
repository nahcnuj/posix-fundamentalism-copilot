#!/bin/sh
# This script intentionally contains non-POSIX constructs to demonstrate
# that shellcheck catches POSIX compliance violations.

n=10
echo {1..$n}        # SC3009: brace expansion is undefined in POSIX sh
echo {1..10}        # SC3009: brace expansion is undefined in POSIX sh
echo -n 42          # SC3037: echo flags are undefined in POSIX sh
trap 'exit 42' sigint  # SC3048/SC3049: signal names must be uppercase and without 'SIG' prefix (use INT) in POSIX sh
cmd &> file         # SC3020: &> redirection is undefined in POSIX sh
foo-bar() { :; }    # SC3033: function names outside [a-zA-Z_][a-zA-Z0-9_]* are undefined in POSIX sh
[ "$UID" = 0 ]      # SC3028: UID is undefined in POSIX sh
local var=value     # SC3043: 'local' is undefined in POSIX sh
time sleep 1 | sleep 5  # SC2176: 'time' is undefined for pipelines in POSIX sh
