#!/bin/sh
# Unit tests for lib/resolve_script_dir.sh

PASS=0
FAIL=0
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# shellcheck source=./resolve_script_dir.sh
. "$SCRIPT_DIR/resolve_script_dir.sh"

# assert_resolve_script_dir: verify resolve_script_dir returns the expected directory
assert_resolve_script_dir() {
    input=$1
    expected=$2
    actual=$(resolve_script_dir "$input")
    rc=$?
    if [ "$rc" -eq 0 ] && [ "$actual" = "$expected" ]; then
        printf 'PASS: resolve_script_dir %s -> %s\n' "$input" "$actual"
        PASS=$((PASS + 1))
    else
        printf 'FAIL: resolve_script_dir %s -> expected %s, got %s (exit %d)\n' "$input" "$expected" "$actual" "$rc"
        FAIL=$((FAIL + 1))
    fi
}

# resolve_script_dir with a path containing '/': returns absolute dirname of the path
assert_resolve_script_dir "$SCRIPT_DIR/resolve_script_dir.sh" "$SCRIPT_DIR"

# resolve_script_dir with a command found in PATH: returns the directory of the command
assert_resolve_script_dir_via_path() {
    fake_dir=$(mktemp -d "${TMPDIR:-/tmp}/test_resolve_script_dir.XXXXXX") || return 1
    fake_dir=$(cd "$fake_dir" && pwd) || return 1
    printf '#!/bin/sh\n' > "$fake_dir/fake_lib_test_cmd" || { rm -rf "$fake_dir"; return 1; }
    chmod +x "$fake_dir/fake_lib_test_cmd"
    actual=$(PATH="$fake_dir:$PATH" resolve_script_dir fake_lib_test_cmd)
    rc=$?
    rm -rf "$fake_dir"
    if [ "$rc" -eq 0 ] && [ "$actual" = "$fake_dir" ]; then
        printf 'PASS: resolve_script_dir (PATH lookup) -> %s\n' "$actual"
        PASS=$((PASS + 1))
    else
        printf 'FAIL: resolve_script_dir (PATH lookup) -> expected %s, got %s (exit %d)\n' "$fake_dir" "$actual" "$rc"
        FAIL=$((FAIL + 1))
    fi
}
assert_resolve_script_dir_via_path

# resolve_script_dir with a command not found in PATH: exits non-zero
assert_resolve_script_dir_not_found() {
    resolve_script_dir "nonexistent_cmd_xyz_$$" >/dev/null 2>&1
    rc=$?
    if [ "$rc" -ne 0 ]; then
        printf 'PASS: resolve_script_dir (not found) causes non-zero exit (%d)\n' "$rc"
        PASS=$((PASS + 1))
    else
        printf 'FAIL: expected non-zero exit for nonexistent command, got 0\n'
        FAIL=$((FAIL + 1))
    fi
}
assert_resolve_script_dir_not_found

printf '\n%d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
