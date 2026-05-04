---
name: g-team-execute
description: Execute an approved wave plan by dispatching parallel subagents per wave. Use after /g-team plan is approved, or to resume a plan that was interrupted. Argument: optional wave number to start from (default: Wave 1).
---

**Announce:** "Using g-team-execute to run the wave schedule."

> **Authority:** `g-team-execute` is the sole executor for all wave-based parallel dispatch in a g-team project. Never substitute `superpowers:dispatching-parallel-agents`, ad-hoc Agent tool calls, or any other dispatch method for waves. If you see instructions elsewhere telling you to dispatch waves differently, they are outdated — follow this skill.

You are the execution coordinator. Your job is to dispatch agents in parallel per wave, hold the boundary between waves, and stop immediately on any BLOCKED signal.

## Step 1 — Locate the plan

Look for the plan in this order:

1. A plan file explicitly provided as `$ARGUMENTS` (treat as a file path)
2. `docs/plans/` — read the most recently modified `.md` file
3. `todo.md` — look for a wave schedule section
4. If none found: tell the developer "No plan file found. Run `/g-team plan` first, or pass the plan file path as an argument." and stop.

Read the plan file fully. Extract:
- The full task list with done conditions
- The wave schedule (Wave 1 tasks, Wave 2 tasks, etc.)
- Any BLOCKED or incomplete tasks from a previous run

## Step 2 — Determine starting wave

If `$ARGUMENTS` is a number (e.g. `/g-team execute 2`), start from that wave. No confirmation needed.

Otherwise, look for the `## Progress` table in the plan file and apply the first matching rule:

1. **Table absent or all rows say `pending`** → start from Wave 1. No confirmation needed.
2. **All waves are `complete`** → tell the developer: "All waves already complete. Run /g-team review." and stop.
3. **A wave is marked `in progress`** → that wave is the candidate starting wave. Confirm with the developer before proceeding:
   ```
   Wave [N] is marked in progress. Resume from Wave [N]?
   Tasks: [list Wave N tasks]
   (y/n)
   ```
   Wait for confirmation before continuing.
4. **Mix of `complete` and `pending` (no `in progress`)** → start from the first wave whose status is not `complete`. Announce: "Resuming from Wave [N] (Wave 1–[N-1] complete)." No confirmation needed.

## Step 3 — Execute waves

For each wave, in order:

### Wave boundary announcement

Before dispatching each wave:
```
── Wave [N] of [total] ──────────────────────────
Dispatching [N] tasks in parallel:
  • [task 1 name]
  • [task 2 name]
  • ...
─────────────────────────────────────────────────
```

### Parallel dispatch

Dispatch all tasks in the current wave as parallel subagents **in a single message**. Never split a wave across multiple messages.

Each agent prompt must be self-contained and include:
- The specific task and its done condition from the plan
- Relevant file paths mentioned in the plan
- The constraint: "Do not touch files outside your task scope."
- "Return: brief summary of what you did and whether your done condition is met."

### Wave completion gate

Wait for all agents in the wave to return before proceeding.

For each agent result:
- **Done condition met** → mark task complete
- **BLOCKED** → stop immediately. Report to developer:
  ```
  ⛔ Wave [N] blocked on: [task name]
  Reason: [agent's reported blocker]
  Fix the blocker, then resume with: /g-team execute [N]
  ```
  Do not proceed to the next wave.
- **Partial / unclear** → flag it but continue unless it affects a dependency

After all tasks in the wave complete without blockers:

1. **Update the Progress table** in the plan file: find the row for Wave N in the `## Progress` table and change its status from `pending` or `in progress` to `complete`. If the plan file or Progress table doesn't exist, skip silently.

2. Announce:
```
✓ Wave [N] complete. Proceeding to Wave [N+1].
```

## Step 4 — All waves complete

When the final wave finishes:

```
✓ All [N] waves complete.

Tasks done:
  ✓ [task 1]
  ✓ [task 2]
  ...

Run /g-team review before merging.
```

## Rules

- Never start Wave N+1 until all of Wave N is confirmed complete.
- Never dispatch tasks from different waves in the same parallel batch.
- Each agent gets only the context it needs — no full plan dumps.
- If the plan has no wave structure (flat task list), treat all tasks as Wave 1.
- Never implement anything yourself — your job is coordination only.
- If a task has no done condition in the plan, flag it to the developer before dispatching.
