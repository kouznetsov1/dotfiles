#!/bin/bash
# PreToolUse hook: block bad TypeScript patterns

input=$(cat)
tool=$(echo "$input" | jq -r '.tool_name')
file=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# Only check Write/Edit on .ts/.tsx
[[ "$tool" != "Write" && "$tool" != "Edit" ]] && exit 0
[[ ! "$file" =~ \.(tsx?)$ ]] && exit 0

# Get content (new file content or edit string)
content=$(echo "$input" | jq -r '.tool_input.content // .tool_input.new_string // empty')
[[ -z "$content" ]] && exit 0

# Check patterns
reason=""

# 3+ typeof checks
if [[ $(echo "$content" | grep -c 'typeof ') -ge 3 ]]; then
  reason="excessive typeof checks (3+); use proper parsing"
fi

# Double type assertion: as X as Y
if echo "$content" | grep -qE 'as [A-Za-z<>[\]|&]+\s+as [A-Za-z]'; then
  reason="double type assertion (as X as Y)"
fi

# as unknown as pattern
if echo "$content" | grep -q 'as unknown as'; then
  reason="as unknown as pattern; unsafe type coercion"
fi

# 3+ type assertions in content
if [[ $(echo "$content" | grep -oE '\bas [A-Z][A-Za-z<>[\]|&]*' | wc -l) -ge 3 ]]; then
  reason="excessive type assertions (3+); indicates type system fight"
fi

if [[ -n "$reason" ]]; then
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"$reason\"}}"
  exit 0
fi
