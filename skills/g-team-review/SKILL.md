---
name: g-team-review
description: Run the full review pipeline on the current branch diff. Dispatches code-lead which verifies done conditions and runs review-orchestrator. Issues MERGE READY or HOLD.
---

**Announce:** "Using g-team-review to run the full review pipeline."

You are running the merge gate. Execute these steps in order.

## Step 1 — Gather the diff

Run:
```
git diff main...HEAD
```

If output is empty, run: `git diff --staged`

If both are empty, ask the developer: "What branch or commit range should I review?"

## Step 2 — Gather done conditions

Check for done conditions in this order:
1. The relevant spec file (typically `docs/superpowers/plans/*.md` or a spec mentioned by the developer)
2. The current milestone file in `milestones/`
3. Ask the developer: "What are the done conditions for this implementation?"

If no done conditions can be found, note this — code-lead will flag it as a process gap.

## Step 3 — Dispatch code-lead

Dispatch the `code-lead` agent. Provide:
- The full diff from Step 1
- The done conditions from Step 2
- The current branch name (from `git branch --show-current`)
- The task list (if known)

code-lead will verify done conditions and dispatch review-orchestrator internally. Wait for code-lead's complete verdict.

## Step 4 — Present verdict and manage sentinel

Present code-lead's verdict to the developer verbatim.

**If verdict is MERGE READY:**
- Create `.claude/` directory if it does not exist
- Write `.claude/g-team-approved` with content: `approved`
- Tell the developer: "MERGE READY. Commit gate unlocked — you can now run git commit and merge."

**Milestone close-out (MERGE READY only):**

1. Read `todo.md` — identify tasks marked as done or the tasks being reviewed in this session.
2. Read `ROADMAP.md` — find the current active milestone (look for `🚧 In progress`).
3. Read the active milestone file from `milestones/` (e.g. `milestones/M1.md`). If the `milestones/` directory does not exist or no matching tasks are found, skip silently — do not report anything.
4. For each task in the milestone's `## Scope` checklist that matches a completed task from this review, mark it `[x]`.
5. If ALL scope items in the milestone are now `[x]`:
   - Update the milestone status header to `✅ Done`
   - Update the corresponding milestone entry in `ROADMAP.md` from `🚧 In progress` to `✅ Done`
   - Move the milestone to the `## Done` section of `ROADMAP.md`
   - Report: `✓ Milestone [ID — Name] closed out`
6. If only some tasks are done:
   - Save the partial updates to the milestone file
   - Report: `✓ [N] milestone tasks checked off — [M] remaining`

**If verdict is HOLD — FIX REQUIRED:**
- Do NOT write `.claude/g-team-approved`
- Tell the developer: "HOLD. Fix all blocking items listed above, then re-run /g-team review."

**If verdict is ESCALATE:**
- Do NOT write `.claude/g-team-approved`
- Present the escalation details and ask the developer for guidance before proceeding.

## Rules
- Never modify code-lead's verdict — present it exactly.
- Never write `.claude/g-team-approved` for anything other than MERGE READY.
- If code-lead is blocked by missing information, gather it and re-dispatch — do not guess.
- The sentinel is automatically cleared after the next `git commit` by the commit hook.
