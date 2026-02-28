# resolve_script_dir: print the directory containing the given script path.
# Handles the case where the path contains no '/' (invoked via PATH).
resolve_script_dir() {
    case "$1" in
        */*) dirname "$1" ;;
        *)
            _p=$(command -v "$1") || {
                printf 'error: cannot resolve path for %s\n' "$1" >&2
                return 1
            }
            dirname "$_p"
            ;;
    esac
}
