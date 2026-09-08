"""Apply managed Codex settings while retaining local state and TOML comments."""

import os
from collections.abc import MutableMapping
from pathlib import Path
import stat
import sys
import tempfile

import tomlkit


def merge_settings(current, managed):
    for key, value in managed.items():
        if isinstance(value, MutableMapping) and isinstance(
            current.get(key), MutableMapping
        ):
            merge_settings(current[key], value)
        else:
            current[key] = value


def main():
    source, destination = map(Path, sys.argv[1:])
    managed = tomlkit.parse(source.read_text())
    existing = destination.read_text() if destination.exists() else ""
    current = tomlkit.parse(existing)
    merge_settings(current, managed)
    rendered = tomlkit.dumps(current)

    if (
        destination.exists()
        and not destination.is_symlink()
        and destination.stat().st_mode & stat.S_IWUSR
        and rendered == existing
    ):
        return

    destination.parent.mkdir(parents=True, exist_ok=True)
    # Replace the symlink itself, never the read-only Nix store target.
    # mkstemp creates the new file with mode 0600.
    fd, temporary = tempfile.mkstemp(prefix=".config.toml-", dir=destination.parent)
    try:
        with os.fdopen(fd, "w") as output:
            output.write(rendered)
        os.replace(temporary, destination)
    finally:
        Path(temporary).unlink(missing_ok=True)


if __name__ == "__main__":
    main()
