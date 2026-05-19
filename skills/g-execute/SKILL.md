---
name: g-execute
description: Execute an approved wave plan by dispatching parallel subagents per wave. Use after /g-plan is approved, or to resume a plan that was interrupted. Argument: optional wave number to start from (default: Wave 1).
context: [task, sprint]
---

**Announce:** "Using g-execute to run the wave schedule."

> **Authority:** `g-execute` is the sole executor for all wave-based parallel dispatch in a g-team project. Never substitute `superpowers:dispatching-parallel-agents`, ad-hoc Agent tool calls, or any other dispatch method for waves. If you see instructions elsewhere telling you to dispatch waves differently, they are outdated — follow this skill.

You are the execution coordinator. Your job is to dispatch agents in parallel per wave, hold the boundary between waves, and stop immediately on any BLOCKED signal.

## Step 0 — Read telemetry profile (adaptive orchestration)

Read `.claude/telemetry-profile` if it exists. Treat the contents as one of `stable`, `cautious`, `defensive`, or `recovery`. If the file is missing, malformed, or contains anything else, treat the profile as `stable`.

Apply the following dispatch adjustments throughout this skill based on the profile:

| Profile | Wave-size cap | Model bump | Extra prompt clause |
|---------|---------------|------------|---------------------|
| `stable` | none | none | none |
| `cautious` | none | none | none — reviewer adjustments live in `/g-review` |
| `defensive` | 3 agents/wave max | Sonnet → Opus when defaults to Sonnet | append `"Telemetry profile: defensive. Be extra strict about scope boundaries."` to every agent prompt |
| `recovery` | 1 agent/wave (force serial) | Opus on every dispatch | append `"Telemetry profile: recovery. Verify every file path before writing. Surface uncertainty immediately."` to every agent prompt |

If wave-size cap is exceeded, split the wave into sub-batches (W3.1, W3.2, …) and run them serially within the wave. The wave is not complete until every sub-batch returns.

Announce the active profile once at the top of the run:
```
Telemetry profile: [profile] — [one-line effect]
```

## Step 1 — Locate the plan

Look for the plan in this order:

1. A plan file explicitly provided as `$ARGUMENTS` (treat as a file path)
2. `docs/plans/` — read the most recently modified `.md` file
3. `todo.md` — look for a wave schedule section
4. If none found: tell the developer "No plan file found. Run `/g-plan` first, or pass the plan file path as an argument." and stop.

Read the plan file fully. Extract:
- The full task list with done conditions
- The wave schedule (Wave 1 tasks, Wave 2 tasks, etc.)
- Any BLOCKED or incomplete tasks from a previous run

## Step 2 — Determine starting wave

If `$ARGUMENTS` is a number (e.g. `/g-execute 2`), start from that wave. No confirmation needed.

Otherwise, look for the `## Progress` table in the plan file and apply the first matching rule:

1. **Table absent or all rows say `pending`** → start from Wave 1. No confirmation needed.
2. **All waves are `complete`** → tell the developer: "All waves already complete. Run /g-review." and stop.
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
- The Step 0 telemetry-profile clause (when the active profile is `defensive` or `recovery`)

### Wave completion gate

Wait for all agents in the wave to return before proceeding.

For each agent result:
- **Done condition met** → mark task complete
- **BLOCKED** → stop immediately. Report to developer:
  ```
  ⛔ Wave [N] blocked on: [task name]
  Reason: [agent's reported blocker]
  Fix the blocker, then resume with: /g-execute [N]
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

When the final wave finishes, announce:

```
✓ All [N] waves complete.

Tasks done:
  ✓ [task 1]
  ✓ [task 2]
  ...
```

Then **immediately invoke `/g-review`** — do not wait for the developer to ask. Use Glob to find `skills/g-review/SKILL.md` inside `~/.claude/plugins/cache/g-team/g-team/` and read it, then follow its instructions exactly.

Do not output a "run /g-review" suggestion and stop. The review is part of the wave execution sequence and must run automatically.

## Rules

- Never start Wave N+1 until all of Wave N is confirmed complete.
- Never dispatch tasks from different waves in the same parallel batch.
- Each agent gets only the context it needs — no full plan dumps.
- If the plan has no wave structure (flat task list), treat all tasks as Wave 1.
- Never implement anything yourself — your job is coordination only.
- The telemetry profile read in Step 0 is **advisory at dispatch time only** — it never blocks or auto-rewrites the plan. If the profile is `recovery` and the developer-approved plan has multi-agent waves, run them serially per the wave-size cap; do not silently rewrite the plan file.
- **Sub-batch semantics** — when wave-size cap forces sub-batches (e.g. W3.1, W3.2), sub-batches run strictly serially within the wave. A BLOCKED signal in any sub-batch stops the wave immediately, mirroring the inter-wave gate. The Progress table is updated to `complete` only after all sub-batches in the wave return without BLOCKED.
- **Escalation logging** — whenever Three-Strikes (G-RULES.md §A7) escalates a task to a higher model tier, append a single line to `.claude/escalation-log` in the format `YYYY-MM-DD <task-label>`. Create the file if missing. This feeds the escalation-frequency telemetry metric — without this write, the metric cannot increment.
- If a task has no done condition in the plan, flag it to the developer before dispatching.
- **Never instruct subagents to run `git commit`.** Committing is HQ's responsibility after `/g-review` issues MERGE READY. Agent prompts must not include commit instructions — only implement, test, and return results.
