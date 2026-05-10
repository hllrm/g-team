---
name: g-init
description: Scaffold a new project with CLAUDE.md (compact G-rules injected), ROADMAP.md, milestones/, todo.md, and commit enforcement hooks. Run once in a new project after installing g-team.
---

**Announce:** "Using g-init to scaffold the project."

You are initializing a G-Team project. Execute these steps in order. Do not skip any step.

## Step 1 — Confirm project root

The project root is the current working directory. If uncertain, ask the developer to confirm before creating any files.

## Step 2 — Create or update CLAUDE.md

Check if `CLAUDE.md` exists at the project root.

**If it does not exist:**
1. Glob the plugin cache for `templates/CLAUDE.md` — pattern: `~/.claude/plugins/cache/g-team/g-team/*/templates/CLAUDE.md`. Use the highest version found.
2. Read the template file.
3. Replace `[Project Name]` with the actual project name (use the directory name, or ask if unclear).
4. Write the result to `CLAUDE.md` at the project root.
5. Tell the developer: "Fill in the project description, stack table, and conventions sections in CLAUDE.md before proceeding."
6. Report: `✓ CLAUDE.md — created from template`

**If it exists:** Read it. If the text `<!-- G-Team Rules` is not present, append this block at the end of the file:

```
<!-- G-Team Rules — injected by /g-init. Do not edit manually. -->
<!-- (rules loaded via @G-RULES.md at top of file) -->
<!-- End G-Team Rules -->
```

Report: `✓ CLAUDE.md — verified`

## Step 2a — Install G-RULES.md

Copy `[plugin-root]/G-RULES.md` to the project root as `G-RULES.md`.

The plugin root is `~/.claude/plugins/cache/g-team/g-team/` (use Glob to confirm the exact path).

If `G-RULES.md` already exists at the project root, overwrite it — it is g-team managed.

Then ensure `CLAUDE.md` contains a reference to it. Add this line near the top of CLAUDE.md (after the title, before any other content) if not already present:
```
@G-RULES.md
```

Report: `✓ G-RULES.md — installed`

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
        echo "G-Team: No code-lead sign-off. Run /g-review and wait for MERGE READY before committing." >&2
        exit 1
    fi
    # Advisory: warn when committing directly to main with approval
    BRANCH=$(git branch --show-current 2>/dev/null)
    if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
        echo "G-Team: Note — committing directly to main. Non-trivial work should be on a feature branch (feat/<slug>, fix/<slug>)." >&2
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

ACTIVE_CONTEXT=""
if [ -f "todo.md" ]; then
    ACTIVE_CONTEXT=$(grep -m1 'Active context:' todo.md | sed 's/.*Active context:[[:space:]]*//')
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
    BUG_COUNT=$(cat ".claude/tier3-active" 2>/dev/null || echo 0)
    echo "  Tier 3 listen mode ACTIVE — ${BUG_COUNT} bug(s) logged this round — no fixes until developer declares round complete"
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
            "command": "bash -c 'bash \"$(git rev-parse --git-common-dir)/../.claude/hooks/workflow-checkpoint.sh\"'",
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
            "command": "bash -c 'bash \"$(git rev-parse --git-common-dir)/../.claude/hooks/check-commit.sh\"'",
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
            "command": "bash -c 'bash \"$(git rev-parse --git-common-dir)/../.claude/hooks/post-commit-cleanup.sh\"'",
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
  ✓ G-RULES.md — installed
  ✓ ROADMAP.md — stub created (or already existed)
  ✓ milestones/M1.md — created (or already existed)
  ✓ todo.md — created (or already existed)
  ✓ .claude/hooks/ — check-commit.sh and workflow-checkpoint.sh installed
  ✓ .claude/settings.json — hooks registered

Next: run /g-plan with your first feature request, or edit milestones/M1.md to define your scope.
```

## Rules
- Never create a file that already exists without reading it first.
- If project_brief.md exists at the project root, use its content to pre-fill ROADMAP.md and milestones/M1.md.
- Settings.json merge must never drop existing hooks — read before writing.
