#!/bin/bash
# G-Team workflow checkpoint — UserPromptSubmit hook.
# Outputs current workflow state so Claude can auto-trigger the right step.

PLAN_FILE=""
if [ -d "docs/plans" ]; then
    PLAN_FILE=$(ls -t docs/plans/*.md 2>/dev/null | head -1)
fi

REVIEW_APPROVED=false
[ -f ".claude/g-team-approved" ] && REVIEW_APPROVED=true

CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")

echo "[G-Team Workflow Checkpoint]"
echo "  Branch: $CURRENT_BRANCH"
if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
    echo "  ⚠  on main — non-trivial work should be on a feature branch (feat/<slug>, fix/<slug>)" >&2
fi
if [ -n "$PLAN_FILE" ]; then
    echo "  Active plan: $PLAN_FILE"

    # Count total waves
    TOTAL_WAVES=$(grep -c "^### Wave" "$PLAN_FILE" 2>/dev/null || echo 0)

    # Find current wave: first wave not marked "complete" in the Progress table
    CURRENT_WAVE=$(awk '
        /^\| Wave \| Status/ { in_table=1; next }
        in_table && /^\|[[:space:]]*[0-9]/ {
            split($0, cols, "|")
            wave = cols[2]; status = cols[3]
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", wave)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", status)
            if (status != "complete") { print wave; exit }
        }
        in_table && /^[^|]/ { in_table=0 }
    ' "$PLAN_FILE" 2>/dev/null)

    if [ -z "$CURRENT_WAVE" ]; then
        CURRENT_WAVE=1
    fi

    echo "  Wave: $CURRENT_WAVE of $TOTAL_WAVES"
else
    echo "  Active plan: none — if this is a non-trivial task, run /g-team plan before any file changes"
fi
if [ "$REVIEW_APPROVED" = true ]; then
    echo "  Review: approved (commit gate open)"
else
    echo "  Review: not yet approved — run /g-team review before merging"
fi

if [ -f ".claude/tier3-active" ]; then
    BUG_COUNT=$(cat ".claude/tier3-active" 2>/dev/null || echo 0)
    echo "  Tier 3 listen mode ACTIVE — ${BUG_COUNT} bug(s) logged this round — no fixes until developer declares round complete"
fi
