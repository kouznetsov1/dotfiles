#!/usr/bin/env python3
import json
import os
import sys

CONTEXT_LIMIT = 200000

data = json.load(sys.stdin)

cwd = data.get("workspace", {}).get("current_dir", "")
transcript_path = data.get("transcript_path", "")

# parse transcript for actual usage
context_tokens = 0
if transcript_path and os.path.exists(transcript_path):
    try:
        with open(transcript_path, "r") as f:
            for line in reversed(f.readlines()):
                line = line.strip()
                if not line:
                    continue
                try:
                    obj = json.loads(line)
                    if obj.get("type") == "assistant" and "message" in obj and "usage" in obj["message"]:
                        usage = obj["message"]["usage"]
                        context_tokens = (
                            usage.get("input_tokens", 0) +
                            usage.get("cache_creation_input_tokens", 0) +
                            usage.get("cache_read_input_tokens", 0) +
                            usage.get("output_tokens", 0)
                        )
                        break
                except json.JSONDecodeError:
                    continue
    except Exception:
        pass

pct = int(context_tokens * 100 / CONTEXT_LIMIT) if CONTEXT_LIMIT else 0

# git branch
branch = ""
if cwd:
    try:
        os.chdir(cwd)
        import subprocess
        result = subprocess.run(["git", "branch", "--show-current"], capture_output=True, text=True)
        branch = result.stdout.strip() if result.returncode == 0 else ""
    except Exception:
        pass

dirname = os.path.basename(cwd) if cwd else ""
parts = [f"{pct}%"]
if branch:
    parts.append(branch)
if dirname:
    parts.append(dirname)

print(" | ".join(parts))
