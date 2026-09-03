#!/usr/bin/env python3
"""Second pass: rename C++ identifiers that contain 'SubStation' (e.g.
SubStationApp, SubStationLocale, GetSubStationLongVersionString, RestartSubStation,
SubStationFileDropTarget, SubStationUpdateDescription, SUBSTATION_CATALOG,
SUBSTATION_APPEND_MENU, etc.)."""

import os
import re
import subprocess

# Order matters: longer prefixes first so we don't double-replace.
IDENTIFIERS = [
    # Class / function names
    "GetSubStationLongVersionString",
    "GetSubStationShortVersionString",
    "GetSubStationBuildCredit",
    "GetSubStationBuildTime",
    "RestartSubStation",
    "SubStationFileDropTarget",
    "SubStationUpdateDescription",
    "SubStationLocale",
    "SubStationApp",
    "SubStationLanguage",
    # Macros
    "SUBSTATION_CATALOG",
    "SUBSTATION_APPEND_MENU",
    "SUBSTATION_BUILD",
    # "SubStation" alone at identifier boundary (e.g. comments, log strings)
    "SubStation",
]

# Skip dirs
SKIP_DIRS = {".git", "builddir", "subprojects"}


def is_text_file(path):
    try:
        with open(path, "rb") as f:
            chunk = f.read(8192)
        if b"\x00" in chunk:
            return False
        text_chars = sum(
            1 for b in chunk
            if b in (9, 10, 13) or 32 <= b <= 126 or b >= 128
        )
        return text_chars / max(len(chunk), 1) > 0.95
    except Exception:
        return False


def main():
    root = os.getcwd()
    replaced = 0
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for fn in filenames:
            full = os.path.join(dirpath, fn)
            if not is_text_file(full):
                continue
            try:
                with open(full, "r", encoding="utf-8", errors="replace") as f:
                    text = f.read()
            except Exception:
                continue
            original = text
            for ident in IDENTIFIERS:
                # Replace the identifier exactly. Be careful to match the
                # identifier boundary. We use a regex that requires word
                # boundary on both sides OR a non-word character before
                # (e.g. start of string, ':', '.', '*', '&', ' ', etc.).
                replacement = ident.replace("SubStation", "SubStation").replace(
                    "AEGISUB", "SUBSTATION"
                )
                # Use lookahead/lookbehind to ensure we don't match inside
                # a longer identifier.
                pattern = r"(?<![A-Za-z0-9_])" + re.escape(ident) + r"(?![A-Za-z0-9_])"
                text = re.sub(pattern, replacement, text)
            if text != original:
                with open(full, "w", encoding="utf-8") as f:
                    f.write(text)
                replaced += 1
    print(f"identifier-replaced in {replaced} files")


if __name__ == "__main__":
    main()
