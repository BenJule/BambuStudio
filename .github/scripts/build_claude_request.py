#!/usr/bin/env python3
"""Build the Claude API request JSON from issue context and repo files."""
import json
import os

file_contents = ""
with open("/tmp/filelist.txt") as f:
    for filepath in (line.strip() for line in f if line.strip()):
        if os.path.isfile(filepath):
            try:
                content = open(filepath).read()
                file_contents += f"\n\n### File: {filepath}\n```\n{content}\n```"
            except Exception as e:
                print(f"Could not read {filepath}: {e}")

prompt = "\n".join([
    "You are an AI assistant helping to fix GitHub issues in BambuStudio, a 3D printing slicer fork.",
    "",
    f"Issue #{os.environ['ISSUE_NUMBER']}: {os.environ['ISSUE_TITLE']}",
    "",
    "Issue description:",
    os.environ["ISSUE_BODY"],
    "",
    f"Relevant repository files:{file_contents}",
    "",
    "Analyze the issue and provide a fix. Return ONLY valid JSON (no markdown, no explanations) with this exact structure:",
    '{',
    '  "commit_message": "type: short description (max 72 chars, conventional commits)",',
    '  "pr_title": "type: short description",',
    '  "changes": [',
    '    {',
    '      "file": "relative/path/to/file",',
    '      "content": "complete new content of the file"',
    '    }',
    '  ]',
    '}',
    "",
    "Rules:",
    "- Only modify files necessary to fix the issue",
    "- Keep changes minimal and focused",
    "- Use conventional commit types: fix, feat, ci, build, docs, refactor",
    "- Return valid JSON only — no other text",
])

request = {
    "model": "claude-opus-4-7",
    "max_tokens": 8192,
    "messages": [{"role": "user", "content": prompt}],
}

with open("/tmp/claude-request.json", "w") as f:
    json.dump(request, f)

print(f"Request built ({len(file_contents)} chars of file context)")
