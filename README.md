# posix-fundamentalism-copilot

A collection of POSIX-compliant shell scripts.

## Library

All usable scripts are available under the `lib/` directory:

| Script | Description |
|--------|-------------|
| `lib/from_unix_time.sh` | Convert a UNIX timestamp (stdin) to a datetime string in `YYYYMMDDhhmmss` format |
| `lib/to_unix_time.sh` | Convert a datetime string in `YYYYMMDDhhmmss` format (stdin) to a UNIX timestamp |
| `lib/ipv4_addrs.sh` | Print all IPv4 addresses of the current host, excluding localhost |

### Usage

Execute a script directly:

```sh
echo 0 | sh lib/from_unix_time.sh
# => 19700101000000

echo 19700101000000 | sh lib/to_unix_time.sh
# => 0
```

Or add `lib/` to your `PATH` for convenient access:

```sh
export PATH="$PATH:/path/to/posix-fundamentalism-copilot/lib"
echo 0 | from_unix_time.sh
```

## Repository Structure

```
lib/                  # Symlinks to all usable scripts (single entry point for users)
from_unix_time/       # UNIX timestamp → datetime conversion script + tests
to_unix_time/         # datetime → UNIX timestamp conversion script + tests
ipv4_addrs/           # IPv4 address listing script + tests
property_tests/       # Property-based (round-trip) tests
examples/             # Example scripts (including non-POSIX constructs)
```

## Running Tests

```sh
sh test.sh
```