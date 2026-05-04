#!/bin/bash
# G-Team commit gate — PreToolUse hook.
# Blocks git commit if .claude/g-team-approved does not exist.
# Input: Claude Code PreToolUse JSON on stdin.

INPUT=$(cat)
CMD=$(echo "$INPUT" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    cmd = d.get('tool_input', {}).get('command', '') or d.get('command', '')
    print(cmd)
except Exception:
    pass
" 2>/dev/null)

if echo "$CMD" | grep -q "git commit"; then
    if [ ! -f ".claude/g-team-approved" ]; then
        echo "G-Team: No code-lead sign-off. Run /g-team review and wait for MERGE READY before committing." >&2
        exit 1
    fi
    # Advisory: warn when committing directly to main with approval
    BRANCH=$(git branch --show-current 2>/dev/null)
    if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
        echo "G-Team: Note — committing directly to main. Non-trivial work should be on a feature branch (feat/<slug>, fix/<slug>)." >&2
    fi
fi
