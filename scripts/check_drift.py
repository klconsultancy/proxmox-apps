#!/usr/bin/env python3
"""Report Drift: Upstream changes to what the Manifest references.

For every part in manifest.yaml, compares each source at the commit the part
was last reviewed at with the same source at Upstream's current head. A source
is a whole file, or named functions within a file.

    scripts/check_drift.py              # print a report, exit 1 on Drift
    scripts/check_drift.py --issues     # open or update one issue per drifted part
"""

import argparse
import difflib
import json
import re
import subprocess
import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
CACHE = ROOT / ".cache" / "upstream"
ISSUE_BODY_LIMIT = 60000


def git(repo, *args, check=True):
    return subprocess.run(["git", "-C", str(repo), *args], capture_output=True, text=True, check=check)


def fetch(name, url):
    """A blobless clone of an Upstream repository, and the commit at its head."""
    repo = CACHE / f"{name}.git"
    if not repo.exists():
        CACHE.mkdir(parents=True, exist_ok=True)
        subprocess.run(["git", "clone", "-q", "--bare", "--filter=blob:none", url, str(repo)], check=True)
    git(repo, "fetch", "-q", "origin", "HEAD")
    return repo, git(repo, "rev-parse", "FETCH_HEAD").stdout.strip()


def file_at(repo, commit, path):
    result = git(repo, "show", f"{commit}:{path}", check=False)
    return result.stdout if result.returncode == 0 else None


def function_in(text, name):
    if text is None:
        return None
    match = re.search(rf"^{re.escape(name)}\(\) *\{{\n.*?^\}}\n", text, re.MULTILINE | re.DOTALL)
    return match[0] if match else None


def diff(before, after, label):
    if before is None and after is None:
        return f"`{label}` is not found upstream at either commit; the Manifest reference is wrong.\n"
    if before == after:
        return None
    if after is None:
        return f"`{label}` no longer exists upstream.\n"
    if before is None:
        return f"`{label}` did not exist at the reviewed commit.\n"
    lines = difflib.unified_diff(
        before.splitlines(), after.splitlines(), f"{label} (reviewed)", f"{label} (upstream)", lineterm=""
    )
    return "```diff\n" + "\n".join(lines) + "\n```\n"


def drift_of(part, repos):
    """The changed sources of one part, as (label, diff) pairs."""
    changes = []
    for source in part["sources"]:
        name, path = source["repo"], source["path"]
        repo, head = repos[name]
        reviewed = part["reviewed_at"][name]
        before, after = file_at(repo, reviewed, path), file_at(repo, head, path)
        if "functions" not in source:
            changes.append((f"{name}/{path}", diff(before, after, path)))
            continue
        for function in source["functions"]:
            label = f"{path}: {function}"
            changes.append(
                (f"{name}/{label}", diff(function_in(before, function), function_in(after, function), label))
            )
    return [(label, text) for label, text in changes if text]


def report(path, part, changes, repos):
    heads = {name: repos[name][1] for name in part["reviewed_at"]}
    body = f"Upstream changed since `{path}` was last reviewed.\n\n"
    for label, text in changes:
        body += f"### {label}\n\n{text}\n"
    body += "Review the change against the translation, then set in `manifest.yaml`:\n\n```yaml\n    reviewed_at:\n"
    body += "".join(f"      {name}: {commit}\n" for name, commit in heads.items())
    body += "```\n"
    if len(body) > ISSUE_BODY_LIMIT:
        body = body[:ISSUE_BODY_LIMIT] + "\n```\n\nTruncated. Run `scripts/check_drift.py` for the full diff.\n"
    return body


def publish(title, body):
    """Open an issue for a drifted part, or refresh the one that is already open."""
    found = subprocess.run(
        ["gh", "issue", "list", "--state", "open", "--search", f'in:title "{title}"', "--json", "number,title"],
        capture_output=True, text=True, check=True,
    )
    numbers = [issue["number"] for issue in json.loads(found.stdout) if issue["title"] == title]
    if numbers:
        command = ["gh", "issue", "edit", str(numbers[0]), "--body-file", "-"]
    else:
        command = ["gh", "issue", "create", "--title", title, "--body-file", "-"]
    subprocess.run(command, input=body, text=True, check=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--issues", action="store_true", help="open or update a GitHub issue per drifted part")
    args = parser.parse_args()

    manifest = yaml.safe_load((ROOT / "manifest.yaml").read_text())
    repos = {name: fetch(name, url) for name, url in manifest["upstream"].items()}

    drifted = 0
    for path, part in manifest["parts"].items():
        changes = drift_of(part, repos)
        if not changes:
            print(f"ok     {path}")
            continue
        drifted += 1
        print(f"drift  {path}: " + ", ".join(label for label, _ in changes))
        body = report(path, part, changes, repos)
        if args.issues:
            publish(f"Drift: {path}", body)
        else:
            print(body)

    sys.exit(1 if drifted and not args.issues else 0)


if __name__ == "__main__":
    main()
