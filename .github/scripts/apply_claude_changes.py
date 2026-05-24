#!/usr/bin/env python3
"""Parse Claude's JSON response and apply file changes safely."""
import json
import os
import pathlib
import sys

with open("/tmp/claude-output.txt") as f:
    raw = f.read().strip()

# Strip markdown code fence if Claude wrapped the JSON
if "```json" in raw:
    raw = raw.split("```json")[1].split("```")[0].strip()
elif raw.startswith("```"):
    raw = raw.split("```")[1].split("```")[0].strip()

try:
    data = json.loads(raw)
except json.JSONDecodeError as e:
    print(f"Failed to parse JSON from Claude: {e}")
    print(f"Raw output:\n{raw[:1000]}")
    sys.exit(1)

with open("/tmp/commit_msg.txt", "w") as f:
    f.write(data["commit_message"])

with open("/tmp/pr_title.txt", "w") as f:
    f.write(data["pr_title"])

repo_root = pathlib.Path.cwd().resolve()

for change in data.get("changes", []):
    filepath = change["file"]
    content = change["content"]

    # Guard against path traversal
    if os.path.isabs(filepath) or ".." in filepath.split(os.sep) or filepath.startswith(".git"):
        print(f"REJECTED unsafe path: {filepath}")
        sys.exit(1)

    resolved = (repo_root / filepath).resolve()
    if not str(resolved).startswith(str(repo_root)):
        print(f"REJECTED path escaping repo root: {filepath}")
        sys.exit(1)

    resolved.parent.mkdir(parents=True, exist_ok=True)
    resolved.write_text(content)
    print(f"Written: {filepath}")

print(f"Applied {len(data.get('changes', []))} file(s)")
