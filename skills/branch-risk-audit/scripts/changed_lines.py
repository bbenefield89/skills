#!/usr/bin/env python3
"""Collect changed hunks for the current branch and optional local diffs."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from dataclasses import dataclass
from typing import Iterable, List, Optional


HUNK_RE = re.compile(
    r"^@@ -(?P<old_start>\d+)(?:,(?P<old_count>\d+))? "
    r"\+(?P<new_start>\d+)(?:,(?P<new_count>\d+))? @@"
)


@dataclass
class Hunk:
    scope: str
    file: str
    change_type: str
    old_range: Optional[str]
    new_range: Optional[str]
    header: str


def run_git(args: List[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["git", *args],
        check=False,
        capture_output=True,
        text=True,
    )


def git_output(args: List[str]) -> str:
    proc = run_git(args)
    if proc.returncode != 0:
        raise RuntimeError(proc.stderr.strip() or "git command failed")
    return proc.stdout.strip()


def ref_exists(ref: str) -> bool:
    return run_git(["rev-parse", "--verify", "--quiet", ref]).returncode == 0


def detect_base_ref(explicit: Optional[str]) -> str:
    if explicit:
        if not ref_exists(explicit):
            raise RuntimeError(f"Base ref does not exist: {explicit}")
        return explicit

    candidates = []
    try:
        candidates.append(git_output(["symbolic-ref", "--quiet", "refs/remotes/origin/HEAD"]))
    except RuntimeError:
        pass

    candidates.extend(["origin/main", "origin/master", "main", "master"])

    for candidate in candidates:
        if candidate and ref_exists(candidate):
            return candidate

    raise RuntimeError("Could not detect a base branch")


def line_range(start: int, count: int) -> Optional[str]:
    if count == 0:
        return None
    end = start + count - 1
    return str(start) if start == end else f"{start}-{end}"


def classify_change(old_range: Optional[str], new_range: Optional[str]) -> str:
    if old_range and new_range:
        return "modify"
    if new_range:
        return "add"
    if old_range:
        return "delete"
    return "unknown"


def parse_diff(scope: str, diff_text: str) -> List[Hunk]:
    hunks: List[Hunk] = []
    current_file: Optional[str] = None

    for raw_line in diff_text.splitlines():
        line = raw_line.rstrip("\n")
        if line.startswith("+++ b/"):
            current_file = line[6:]
            continue
        if line.startswith("--- a/") and current_file is None:
            current_file = line[6:]
            continue
        match = HUNK_RE.match(line)
        if not match or current_file is None:
            continue

        old_start = int(match.group("old_start"))
        old_count = int(match.group("old_count") or "1")
        new_start = int(match.group("new_start"))
        new_count = int(match.group("new_count") or "1")
        old_range = line_range(old_start, old_count)
        new_range = line_range(new_start, new_count)

        hunks.append(
            Hunk(
                scope=scope,
                file=current_file,
                change_type=classify_change(old_range, new_range),
                old_range=old_range,
                new_range=new_range,
                header=line,
            )
        )

    return hunks


def collect(scope: str, diff_args: List[str]) -> List[Hunk]:
    proc = run_git(["diff", "--unified=0", "--no-color", *diff_args])
    if proc.returncode not in (0, 1):
        raise RuntimeError(proc.stderr.strip() or "git diff failed")
    return parse_diff(scope, proc.stdout)


def has_local_changes(args: Iterable[str]) -> bool:
    proc = run_git(list(args))
    return proc.returncode == 1


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--base", help="Explicit base ref", default=None)
    parser.add_argument(
        "--skip-local",
        action="store_true",
        help="Do not include staged or unstaged changes",
    )
    parsed = parser.parse_args()

    try:
        base_ref = detect_base_ref(parsed.base)
        merge_base = git_output(["merge-base", "HEAD", base_ref])

        results = {
            "base_ref": base_ref,
            "merge_base": merge_base,
            "hunks": collect("branch", [merge_base, "HEAD"]),
        }

        if not parsed.skip_local:
            if has_local_changes(["diff", "--quiet", "--cached"]):
                results["hunks"].extend(collect("staged", ["--cached"]))
            if has_local_changes(["diff", "--quiet"]):
                results["hunks"].extend(collect("unstaged", []))

        payload = {
            "base_ref": results["base_ref"],
            "merge_base": results["merge_base"],
            "hunks": [hunk.__dict__ for hunk in results["hunks"]],
        }
        json.dump(payload, sys.stdout, indent=2)
        sys.stdout.write("\n")
        return 0
    except RuntimeError as exc:
        print(str(exc), file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
