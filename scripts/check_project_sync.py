#!/usr/bin/env python3
"""
Check that FocusFlow.xcodeproj is in sync with project.yml.

`xcodegen generate` is deterministic for a given XcodeGen version, but:

  1. XcodeGen emits the `targets = (...)` list in a non-deterministic order,
     so the same spec can produce different-but-equivalent files.
  2. Different XcodeGen versions order targets differently (2.45.4 vs 2.46.0
     are known to differ here).

Target ordering has no effect on the build, so a raw byte diff produces false
failures. This script normalises the ordering of those lists before comparing.

Usage:
    scripts/check_project_sync.py
"""

import re
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
PROJECT = REPO / "FocusFlow.xcodeproj" / "project.pbxproj"


def normalise(text: str) -> str:
    """Sort the entries of every `targets = (...)` / `children = (...)` list."""
    out = []
    lines = text.split("\n")
    i = 0
    while i < len(lines):
        line = lines[i]
        out.append(line)
        # Look for a list opener: `something = (`
        if re.search(r"=\s*\(\s*$", line):
            block = []
            j = i + 1
            while j < len(lines) and not re.match(r"^\s*\);", lines[j]):
                block.append(lines[j])
                j += 1
            if j < len(lines):
                # Keep the list contents sorted so ordering differences vanish.
                out.extend(sorted(block))
                out.append(lines[j])
                i = j + 1
                continue
        i += 1
    return "\n".join(out)


def main() -> int:
    if not PROJECT.exists():
        print(f"::error::{PROJECT} does not exist")
        return 1

    before = PROJECT.read_text()

    result = subprocess.run(
        ["xcodegen", "generate"], cwd=REPO, capture_output=True, text=True
    )
    if result.returncode != 0:
        print("::error::xcodegen generate failed")
        print(result.stdout)
        print(result.stderr)
        return 1

    after = PROJECT.read_text()

    # Restore the committed version so CI never mutates the checkout.
    subprocess.run(["git", "checkout", "--", str(PROJECT)], cwd=REPO, check=True)

    if normalise(before) == normalise(after):
        print("FocusFlow.xcodeproj is in sync with project.yml ✅")
        return 0

    print("::error::FocusFlow.xcodeproj is out of sync with project.yml.")
    print("Run 'xcodegen generate' and commit the result.")

    # Show a normalised diff so the failure is actionable.
    import difflib

    diff = difflib.unified_diff(
        normalise(before).split("\n"),
        normalise(after).split("\n"),
        fromfile="committed",
        tofile="generated",
        lineterm="",
        n=2,
    )
    for line in list(diff)[:120]:
        print(line)

    return 1


if __name__ == "__main__":
    sys.exit(main())
