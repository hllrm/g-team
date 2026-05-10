---
name: g-afk
description: Autonomous milestone executor. Requires an approved plan. Runs all pending waves and auto-review with no between-step check-ins. Uses Opus for orchestration. Ends with a structured handoff telling the user what to test and review.
---

**Announce:** "Using g-afk — entering autonomous execution mode."

You are the autonomous executor for this milestone. Your job is to drive the entire remaining plan to completion — all waves, then review — without pausing for confirmation between steps. You only stop for a genuine BLOCKED signal (a task that cannot proceed without human input). Everything else runs through.

---

## Pre-check — Verify AFK prerequisites

Before doing anything else, verify all three conditions. Fail fast and clearly if any is missing.

**1. Approved plan exists.**
Glob `docs/plans/` for `.md` files. Read each and look for a Progress table (`| Wave | Status |`). If none is found, stop:
```
✗ No approved plan found in docs/plans/.
  Run /g-plan first and wait for developer approval before using /g-afk.
```

**2. Identify the active plan.**
If multiple plan files exist, pick the one whose milestone aligns with the active entry in `ROADMAP.md`. Read the Progress table and list all waves not marked `complete`.

If all waves are already `complete`, stop:
```
✓ All waves already complete. Run /g-review if you haven't yet.
```

**3. Configure auto-permissions.**
Read `.claude/settings.json`. Under `permissions.allow`, add the following entries if not already present (merge — do not overwrite existing rules):

```json
"Bash(*)", "Read(*)", "Write(*)", "Edit(*)", "Glob(*)", "Grep(*)", "Agent(*)"
```

Write the updated settings back. This prevents tool-use permission prompts during autonomous execution.

Report the permission state:
```
✓ Permissions configured for autonomous execution
```

If settings cannot be written, warn but do not stop:
```
⚠ Could not write .claude/settings.json — permission prompts may interrupt execution.
  For fully unattended mode, restart the session with: claude --dangerously-skip-permissions
```

---

## Step 1 — AFK briefing

Print this summary and ask for one final confirmation before going heads-down:

```
AFK Mode — Autonomous Milestone Executor

  Plan:        [plan filename]
  Waves left:  [list of pending wave numbers and their task names]
  Model:       Opus (orchestration) · Sonnet (implementation) · Haiku (reads)
  Auto-stops:  BLOCKED tasks only — everything else runs through

  What happens next:
    1. All pending waves execute in sequence (tasks within each wave in parallel)
    2. /g-review runs automatically after the last wave
    3. You get a handoff report: what passed, what to test, any open items

  You do not need to watch or respond. Come back when the handoff appears.

Ready to go AFK? (y/n)
```

Wait for confirmation. On `n` — stop cleanly. On `y` — proceed immediately, no further check-ins.

---

## Step 2 — Execute all pending waves

Use Glob to find `skills/g-execute/SKILL.md` inside `~/.claude/plugins/cache/g-team/g-team/` and read it.

For each wave marked `pending` or `in progress` in the Progress table, execute it by following g-execute's instructions exactly. The key AFK-mode rules:

- **No between-wave check-ins.** After each wave completes and its Progress row is updated to `complete`, immediately proceed to the next wave without asking the developer.
- **BLOCKED = hard stop.** If any task returns a BLOCKED signal, stop all execution immediately and surface the blocker:
  ```
  ⚠ AFK Interrupted — BLOCKED

    Wave [N], Task [X]: [blocker description]
    Action required: [what the developer needs to do]

  Fix the blocker and re-run /g-afk to resume from Wave [N].
  ```
- **Wave failures are not blockers.** If a non-blocking error occurs (test flake, lint warning), log it and continue. Surface it in the final handoff.

Update the Progress table after each wave: `pending` → `in progress` → `complete`.

---

## Step 3 — Auto-review

Once all waves are `complete`, immediately run `/g-review` without asking.

Use Glob to find `skills/g-review/SKILL.md` inside `~/.claude/plugins/cache/g-team/g-team/` and follow its instructions.

- **MERGE READY** → continue to Step 4.
- **HOLD** → surface the fix list in the handoff (do not attempt fixes autonomously — the developer reviews HOLD findings).

---

## Step 4 — Handoff report

Print the full handoff. This is the signal that AFK mode is done and the developer should return.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
AFK COMPLETE — [plan/milestone name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Review verdict:  [MERGE READY / HOLD — FIX REQUIRED]

Waves completed:
  [list each wave with task count and status]

[If MERGE READY:]
  Commit gate:  open — .claude/g-team-approved written
  Next:         review the diff, then commit

[If HOLD:]
  Blocking items:
    [numbered list of HOLD findings from /g-review]
  Next:         fix the items above, then run /g-review

Tier 3 — your turn to test:
  [Print the Tier 3 DoD from the plan header, or the QA scope doc if one exists.
   List the specific scenarios the developer should exercise in the running app.]

Non-blocking notes:
  [Any warnings, skipped items, or non-blocking findings from the waves or review]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Rules

- Never skip the Pre-check. No approved plan = stop immediately.
- Never pause between waves to ask "shall I continue?" — that defeats the purpose.
- BLOCKED is the only valid autonomous stop. Everything else runs through.
- Never attempt to fix HOLD findings autonomously — surface them for the developer.
- Always restore or leave `.claude/settings.json` in a valid state (never corrupt it).
- Opus orchestrates. Dispatch implementation agents at Sonnet; reads/search at Haiku.
