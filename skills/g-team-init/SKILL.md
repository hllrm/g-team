---
name: g-team-init
description: Scaffold a new project with CLAUDE.md (compact G-rules injected), ROADMAP.md, milestones/, todo.md, and commit enforcement hooks. Run once in a new project after installing g-team.
---

**Announce:** "Using g-team-init to scaffold the project."

You are initializing a G-Team project. Execute these steps in order. Do not skip any step.

## Step 1 — Confirm project root

The project root is the current working directory. If uncertain, ask the developer to confirm before creating any files.

## Step 2 — Create or update CLAUDE.md

Check if `CLAUDE.md` exists at the project root.

**If it does not exist:** Create it with this content (replace [Project Name] with the actual project name, or use a placeholder):

```
# [Project Name]

[Brief description of what this project does.]

<!-- G-Team Rules — injected by /g-team init. Do not edit manually. -->
## G-Team Workflow

**Models**: Haiku for reads/search · Sonnet for implementation · Opus only after 2 failed attempts on the same task.

**Workflow — auto-triggered, no command needed**:
Claude detects task complexity and initiates the workflow automatically — never wait for the user to type a command:
- Non-trivial task? (≥3 files, new feature, layer-boundary change, unclear bug, public API change) → run `/g-team plan` before any file changes
- Plan approved → run `/g-team execute` to dispatch waves
- Implementation complete / user wants to merge → run `/g-team review`
All three steps are mandatory. Skipping any requires explicit developer override.

**Agent discipline**: HQ orchestrates only — dispatches agents, collects results, integrates. Never does grunt work an agent can do. Hard limit: 7 agents per task.

**Architecture gate**: ≥3 files, layer-boundary change, new component, or public API change → plan first (no writes), validate import directions, verify state ownership, get sign-off.

**Hard stops**: No merge without MERGE READY · No plan skip for non-trivial tasks · HOLD = fix all blocking items, re-review · Same bug class × 3 attempts = stop, escalate, try a different mechanism.
<!-- End G-Team Rules -->
```

**If it exists:** Read it. If the text `<!-- G-Team Rules` is not present, append the G-Team Rules block (from `<!-- G-Team Rules` to `<!-- End G-Team Rules -->`) at the end of the file.

## Step 3 — Create ROADMAP.md

Create `ROADMAP.md` if it does not exist:

```
# Roadmap

## Current Milestone
- **M1** — [Define milestone name] — 🚧 In progress

## Backlog
- M2 — [Define next milestone]

## Done
(none yet)
```

If a `project_brief.md` exists, read it and use the project goals to fill in M1 and M2 with meaningful content.

## Step 4 — Create milestones/M1.md

Create the `milestones/` directory if it does not exist.
Create `milestones/M1.md` if it does not exist:

```
# M1 — [Milestone Name]

## Goal
[One sentence describing what this milestone delivers]

## Scope
- [ ] Task 1
- [ ] Task 2

## Done condition
[Specific, mechanically checkable condition]

## Status
🚧 In progress
```

## Step 5 — Create todo.md

Create `todo.md` if it does not exist:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HANDOFF — [project] | branch: [branch]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Done this pass:   · (nothing yet)
Next up:          · Define M1 scope in milestones/M1.md
Active context:   · Fresh project, just initialized
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Tasks
| # | Task | Notes |
|---|------|-------|
| 1 | Define M1 scope | Update milestones/M1.md |

## Details
```

## Step 6 — Set up commit enforcement hooks

Create `.claude/hooks/` directory if it does not exist.

Write `.claude/hooks/check-commit.sh` with this exact content:

```bash
#!/bin/bash
# G-Team commit gate — PreToolUse hook.
# Blocks git commit if .claude/g-team-approved does not exist.
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
fi
```

Write `.claude/hooks/post-commit-cleanup.sh` with this exact content:

```bash
#!/bin/bash
# G-Team post-commit cleanup — PostToolUse hook.
# Clears .claude/g-team-approved after a successful git commit.
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
    rm -f ".claude/g-team-approved"
fi
```

Write `.claude/hooks/workflow-checkpoint.sh` with this exact content:

```bash
#!/bin/bash
# G-Team workflow checkpoint — UserPromptSubmit hook.
# Outputs current workflow state so Claude can auto-trigger the right step.

PLAN_FILE=""
if [ -d "docs/plans" ]; then
    PLAN_FILE=$(ls -t docs/plans/*.md 2>/dev/null | head -1)
fi

REVIEW_APPROVED=false
[ -f ".claude/g-team-approved" ] && REVIEW_APPROVED=true

echo "[G-Team Workflow Checkpoint]"
if [ -n "$PLAN_FILE" ]; then
    echo "  Active plan: $PLAN_FILE"

    # Count total waves
    TOTAL_WAVES=$(grep -c "^### Wave" "$PLAN_FILE" 2>/dev/null || echo 0)

    # Find current wave: first wave not marked "complete" in the Progress table
    # The Progress table rows look like: | 1 | complete | ... | or | 1 | pending | ... |
    CURRENT_WAVE=$(awk '
        /^\| Wave \| Status/ { in_table=1; next }
        in_table && /^\|[[:space:]]*[0-9]/ {
            # Extract wave number and status from table row
            split($0, cols, "|")
            wave = cols[2]; status = cols[3]
            # Trim whitespace
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", wave)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", status)
            if (status != "complete") { print wave; exit }
        }
        in_table && /^[^|]/ { in_table=0 }
    ' "$PLAN_FILE" 2>/dev/null)

    # If no Progress table yet (or all complete), default to wave 1
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
```

## Step 7 — Register hooks in .claude/settings.json

Read `.claude/settings.json` if it exists. If it does not exist, start with `{}`.

Add the following hook entries under the `hooks` key. If `hooks` already exists, merge — do not overwrite existing hooks.

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/workflow-checkpoint.sh",
            "timeout": 5000
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/check-commit.sh",
            "timeout": 5000
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/post-commit-cleanup.sh",
            "timeout": 5000
          }
        ]
      }
    ]
  }
}
```

Write the merged result back to `.claude/settings.json`.

## Step 8 — Report

After all steps, report:

```
G-Team initialized ✓

  ✓ CLAUDE.md — G-Team rules injected
  ✓ ROADMAP.md — stub created (or already existed)
  ✓ milestones/M1.md — created (or already existed)
  ✓ todo.md — created (or already existed)
  ✓ .claude/hooks/ — check-commit.sh and workflow-checkpoint.sh installed
  ✓ .claude/settings.json — hooks registered

Next: run /g-team plan with your first feature request, or edit milestones/M1.md to define your scope.
```

## Rules
- Never create a file that already exists without reading it first.
- If project_brief.md exists at the project root, use its content to pre-fill ROADMAP.md and milestones/M1.md.
- Settings.json merge must never drop existing hooks — read before writing.
