#!/bin/bash
# pre-compact.sh — PreCompact hook for G-Team Claude Code plugin
# Fires before context compression. Writes .claude/compact-state.md so the
# next session can recover context without re-briefing. Must never exit 1.

# Consume stdin to avoid broken pipe (PreCompact may or may not send JSON)
cat > /dev/null 2>&1

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || echo "unknown")

# Ensure .claude/ exists in the developer's project directory
mkdir -p .claude 2>/dev/null

# Collect git state
BRANCH=$(git branch --show-current 2>/dev/null || echo "not a git repo")
COMMITS=$(git log --oneline -5 2>/dev/null || echo "no commits found")

# Extract the Handoff block from todo.md if it exists
if [ -f "todo.md" ]; then
  # Capture everything from the HANDOFF header line through the closing separator
  HANDOFF=$(awk '/^━+$/{found++} found==1{print} found==2{print; exit}' todo.md 2>/dev/null)
  if [ -z "$HANDOFF" ]; then
    HANDOFF="(Handoff block not found in todo.md)"
  fi
else
  HANDOFF="todo.md not found"
fi

# Write compact-state.md
cat > .claude/compact-state.md << EOF
# Compact State — ${TIMESTAMP}

## Branch
${BRANCH}

## Recent commits
${COMMITS}

## Handoff at compaction
${HANDOFF}

---
*Written by pre-compact hook at ${TIMESTAMP}. Load this file at session start to recover context.*
EOF

exit 0
