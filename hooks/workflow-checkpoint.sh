#!/bin/bash
# G-Team workflow checkpoint — UserPromptSubmit hook.
# Outputs current workflow state so Claude can auto-trigger the right step.

# Consume stdin payload — UserPromptSubmit delivers tool_input JSON here.
# We don't use it, but reading it prevents broken-pipe edge cases on some shells.
if [ ! -t 0 ]; then
    _STDIN_PAYLOAD=$(cat - 2>/dev/null || true)
    : "${_STDIN_PAYLOAD:=}"
fi

# Helper: emit a non-negative integer, defaulting to 0 on empty / non-numeric input.
to_int() {
    local v
    v=$(printf '%s' "$1" | tr -d '[:space:]')
    case "$v" in
        ''|*[!0-9]*) printf '0' ;;
        *) printf '%s' "$v" ;;
    esac
}

# Integration tier — `full` (default) emits everything; `balanced` skips the
# auto-trigger advisory; `light` emits only Branch + Tier.
TIER="full"
if [ -f ".claude/integration-tier" ]; then
    _t=$(tr -d '[:space:]' < .claude/integration-tier 2>/dev/null)
    case "$_t" in
        full|balanced|light) TIER="$_t" ;;
    esac
fi

ACTIVE_CONTEXT=""
if [ -f "ROADMAP.md" ]; then
    ACTIVE_CONTEXT=$(grep -m1 'Active context:' ROADMAP.md | sed 's/.*Active context:[[:space:]]*//')
fi

REVIEW_APPROVED=false
[ -f ".claude/g-team-approved" ] && REVIEW_APPROVED=true

CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")

echo "[G-Forge Workflow Checkpoint]"
echo "  Branch: $CURRENT_BRANCH"

# Light tier — minimal output, then exit.
if [ "$TIER" = "light" ]; then
    echo "  Tier:   light — manual mode; commit gate off"
    exit 0
fi

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

# Milestone health — rework commits, blockers, review holds since main.
# Patterns kept in sync with /g-patterns Step 2c rework signals.
REWORK_COUNT=0
BLOCKED_COUNT=0
HOLD_COUNT=0
if git rev-parse --verify main >/dev/null 2>&1 && [ "$CURRENT_BRANCH" != "main" ] && [ "$CURRENT_BRANCH" != "master" ]; then
    _rework_raw=$(git log --oneline main..HEAD 2>/dev/null \
        | grep -ciE '(^[a-f0-9]+[[:space:]]+)?(revert:|^[a-f0-9]+[[:space:]]+revert "|fix-of-fix|take 2|retry|another attempt|re-do)' 2>/dev/null)
    REWORK_COUNT=$(to_int "$_rework_raw")
fi
if [ -f "todo.md" ]; then
    _blocked_raw=$(grep -cE 'BLOCKED' todo.md 2>/dev/null)
    BLOCKED_COUNT=$(to_int "$_blocked_raw")
fi
if [ -f ".claude/review-holds" ]; then
    _holds_raw=$(cat .claude/review-holds 2>/dev/null)
    HOLD_COUNT=$(to_int "$_holds_raw")
fi

if [ "$REWORK_COUNT" -eq 0 ] && [ "$BLOCKED_COUNT" -eq 0 ] && [ "$HOLD_COUNT" -eq 0 ]; then
    echo "  Health: ✓ clean"
else
    HEALTH_PARTS=""
    [ "$REWORK_COUNT" -gt 0 ] && HEALTH_PARTS="${HEALTH_PARTS}${REWORK_COUNT} rework · "
    [ "$BLOCKED_COUNT" -gt 0 ] && HEALTH_PARTS="${HEALTH_PARTS}${BLOCKED_COUNT} blocked · "
    [ "$HOLD_COUNT" -gt 0 ] && HEALTH_PARTS="${HEALTH_PARTS}${HOLD_COUNT} holds · "
    HEALTH_PARTS=${HEALTH_PARTS%· }
    echo "  Health: ⚠ ${HEALTH_PARTS}"
fi

# Tier line — surfaces the integration tier so the LLM knows whether
# auto-triggers are permitted (only on `full`). `light` already exited above.
if [ "$TIER" = "balanced" ]; then
    echo "  Tier:   balanced — no auto-triggers; invoke skills manually"
else
    echo "  Tier:   full"
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
          "https://raw.githubusercontent.com/hllrm/G-Forge/main/.claude-plugin/plugin.json" \
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
