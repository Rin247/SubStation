#!/usr/bin/env python3
"""Update git index to match the file moves made by the rename script."""

import os
import re
import subprocess

ROOT = os.getcwd()


def rename_filename(name):
    if name == "aegisub.pot":
        return name
    new = re.sub(
        r"(?i)aegisub",
        lambda m: "SubStation" if m.group(0)[0].isupper() else "substation",
        name,
    )
    return new


def main():
    # Get the list of files git knows about, and figure out which need renaming
    result = subprocess.check_output(
        ["git", "ls-files"], cwd=ROOT, text=True
    ).splitlines()
    renames = []
    for rel in result:
        parts = rel.split("/")
        new_parts = [rename_filename(p) for p in parts]
        if new_parts != parts:
            new_rel = "/".join(new_parts)
            renames.append((rel, new_rel))

    # Apply each rename
    for old, new in renames:
        if os.path.exists(os.path.join(ROOT, new)):
            # File exists at new path. Move it via git if old is tracked, or
            # just add the new path.
            if os.path.exists(os.path.join(ROOT, old)):
                subprocess.run(["git", "mv", "-f", old, new], cwd=ROOT, check=False)
            else:
                subprocess.run(["git", "add", new], cwd=ROOT, check=False)
        else:
            print(f"WARN: target missing: {new}")
    print(f"git-moved {len(renames)} files")


if __name__ == "__main__":
    main()
