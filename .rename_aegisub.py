#!/usr/bin/env python3
"""Mechanically rename SubStation to SubStation in filenames and content."""

import os
import re
import subprocess

PROTECTED_SUBSTRINGS = [
    "nielsm@substation.org",
    "jfs@substation.org",
    "verm@substation.org",
    "rsod@substation.org",
    "mooker@substation.org",
]

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


def should_rename(name):
    if name == "substation.pot":
        return False
    return "substation" in name.lower()


def rename_filename(name):
    new = re.sub(
        r"(?i)substation",
        lambda m: "SubStation" if m.group(0)[0].isupper() else "substation",
        name,
    )
    return new


def replace_in_file(path):
    try:
        with open(path, "r", encoding="utf-8", errors="replace") as f:
            text = f.read()
    except Exception:
        return False
    original = text
    text = re.sub(r"\bAegisub\b", "SubStation", text)
    text = re.sub(r"\baegisub\b", "substation", text)
    for prot in PROTECTED_SUBSTRINGS:
        if prot in original and prot not in text:
            text = text.replace(prot.replace("substation", "substation"), prot)
    if text != original:
        with open(path, "w", encoding="utf-8") as f:
            f.write(text)
        return True
    return False


def main():
    root = os.getcwd()
    print(f"working in: {root}")

    paths = subprocess.check_output(
        ["git", "-C", root, "ls-files"], text=True
    ).splitlines()
    paths.sort(key=lambda p: p.count("/"), reverse=True)

    renamed_files = 0
    for rel in paths:
        parts = rel.split("/")
        new_parts = [rename_filename(p) if should_rename(p) else p for p in parts]
        if new_parts != parts:
            new_rel = "/".join(new_parts)
            old_full = os.path.join(root, rel)
            new_full = os.path.join(root, new_rel)
            if os.path.exists(old_full) and not os.path.exists(new_full):
                os.makedirs(os.path.dirname(new_full), exist_ok=True)
                os.rename(old_full, new_full)
                renamed_files += 1
            elif os.path.exists(new_full):
                print(f"SKIP (target exists): {rel} -> {new_rel}")

    replaced = 0
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for fn in filenames:
            full = os.path.join(dirpath, fn)
            if not is_text_file(full):
                continue
            if replace_in_file(full):
                replaced += 1
    print(f"\nrenamed {renamed_files} files")
    print(f"replaced in {replaced} files")

    # Pass 3: version reset. SubStation's meson.build says version '3.5.0';
    # SubStation starts at 1.0.0.
    meson_build = os.path.join(root, "meson.build")
    if os.path.exists(meson_build):
        with open(meson_build, "r", encoding="utf-8") as f:
            text = f.read()
        new_text = re.sub(
            r"version:\s*'[^']*'",
            "version: '1.0.0'",
            text,
        )
        if new_text != text:
            with open(meson_build, "w", encoding="utf-8") as f:
                f.write(new_text)
            print("reset version: 3.5.0 -> 1.0.0 in meson.build")


if __name__ == "__main__":
    main()
