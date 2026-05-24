#!/usr/bin/env python3
"""Parse Claude's JSON response and apply the unified diff."""
import json
import os
import subprocess
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
    print(f"Raw output:\n{raw[:500]}")
    sys.exit(1)

with open("/tmp/commit_msg.txt", "w") as f:
    f.write(data["commit_message"])

with open("/tmp/pr_title.txt", "w") as f:
    f.write(data["pr_title"])

diff = data.get("diff", "").strip()
if not diff:
    print("Claude returned empty diff — no fix could be generated")
    sys.exit(1)

# Write diff to file
with open("/tmp/claude.patch", "w") as f:
    f.write(diff)

print("Applying patch:")
print(diff[:500])

# Apply via git apply
result = subprocess.run(
    ["git", "apply", "--check", "/tmp/claude.patch"],
    capture_output=True, text=True
)
if result.returncode != 0:
    print(f"Patch check failed:\n{result.stderr}")
    # Try with --reject to get partial application info
    result2 = subprocess.run(
        ["git", "apply", "--verbose", "/tmp/claude.patch"],
        capture_output=True, text=True
    )
    print(f"Apply output:\n{result2.stdout}\n{result2.stderr}")
    sys.exit(1)

result = subprocess.run(
    ["git", "apply", "/tmp/claude.patch"],
    capture_output=True, text=True
)
if result.returncode != 0:
    print(f"Patch apply failed:\n{result.stderr}")
    sys.exit(1)

print("Patch applied successfully")
