# resolve_script_dir: print the absolute directory containing the given script path.
# Handles the case where the path contains no '/' (invoked via PATH).
resolve_script_dir() {
    case "$1" in
        */*) _rsd_p=$1 ;;
        *)
            _rsd_p=$(command -v "$1") || {
                printf 'error: cannot resolve path for %s\n' "$1" >&2
                return 1
            }
            ;;
    esac
    ( cd "$(dirname "$_rsd_p")" && pwd ) || return 1
}
