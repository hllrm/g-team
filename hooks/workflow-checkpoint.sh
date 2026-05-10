#!/bin/bash
# G-Team workflow checkpoint — UserPromptSubmit hook.
# Outputs current workflow state so Claude can auto-trigger the right step.

ACTIVE_CONTEXT=""
if [ -f "ROADMAP.md" ]; then
    ACTIVE_CONTEXT=$(grep -m1 'Active context:' ROADMAP.md | sed 's/.*Active context:[[:space:]]*//')
fi

REVIEW_APPROVED=false
[ -f ".claude/g-team-approved" ] && REVIEW_APPROVED=true

CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")

echo "[G-Team Workflow Checkpoint]"
echo "  Branch: $CURRENT_BRANCH"
if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
    echo "  ⚠  on main — non-trivial work should be on a feature branch (feat/<slug>, fix/<slug>)" >&2
fi
if [ -n "$ACTIVE_CONTEXT" ]; then
    echo "  Active: $ACTIVE_CONTEXT"
else
    echo "  Active: none"
fi
if [ "$REVIEW_APPROVED" = true ]; then
    echo "  Review: approved (commit gate open)"
else
    echo "  Review: not yet approved — run /g-review before merging"
fi

if [ -f ".claude/tier3-active" ]; then
    ITEM_COUNT=$(cat ".claude/tier3-active" 2>/dev/null || echo 0)
    echo "  Listen mode ACTIVE — ${ITEM_COUNT} item(s) logged — no action until user says done"
fi

# Self-update check — background curl once per day, zero blocking latency
CLAUDE_DIR="$HOME/.claude"
INSTALLED_MANIFEST="$CLAUDE_DIR/plugins/cache/g-team/g-team/.claude-plugin/plugin.json"
VERSION_CACHE="$CLAUDE_DIR/g-team-latest-version"
CHECK_STAMP="$CLAUDE_DIR/g-team-check-stamp"

if [ -f "$INSTALLED_MANIFEST" ]; then
    INSTALLED_VER=$(grep '"version"' "$INSTALLED_MANIFEST" | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?[a-zA-Z0-9]*' | head -1)

    NEEDS_CHECK=true
    if [ -f "$CHECK_STAMP" ] && find "$CHECK_STAMP" -mmin -1440 2>/dev/null | grep -q .; then
        NEEDS_CHECK=false
    fi

    if [ "$NEEDS_CHECK" = true ]; then
        (curl -sf --max-time 5 \
          "https://raw.githubusercontent.com/hllrm/g-team/main/.claude-plugin/plugin.json" \
          | grep '"version"' | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?[a-zA-Z0-9]*' | head -1 \
          > "$VERSION_CACHE" && touch "$CHECK_STAMP") >/dev/null 2>&1 &
    fi

    if [ -f "$VERSION_CACHE" ]; then
        LATEST_VER=$(cat "$VERSION_CACHE")
        if [ -n "$LATEST_VER" ] && [ "$LATEST_VER" != "$INSTALLED_VER" ]; then
            echo "  ⚡ g-team update available: $INSTALLED_VER → $LATEST_VER — run /g-update to pull and sync"
        fi
    fi
fi
