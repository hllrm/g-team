---
name: g-team-review
description: Run the full review pipeline on the current branch diff. Dispatches code-lead which verifies done conditions and runs review-orchestrator. Issues MERGE READY or HOLD.
---

**Announce:** "Using g-team-review to run the full review pipeline."

You are running the merge gate. Execute these steps in order.

## Step 1 — Run the test suite

Before reviewing any code, verify the test suite passes.

**Detect the test command** using this priority order:
1. Check `package.json` scripts for `"test"` — if found, use `npm test` (or `bun test` / `yarn test` based on lockfile)
2. Check for `pytest.ini`, `pyproject.toml` with `[tool.pytest]`, or `tests/` with `.py` files — use `pytest`
3. Check for `Makefile` with a `test` target — use `make test`
4. Check `project_brief.md` Tests field for the framework name
5. If no test command can be detected: ask the developer — "What command runs your test suite?" — wait for answer

**Run the test command.** Capture the output.

**If all tests pass:**
- Report: `✓ Tests passed — proceeding to code review`
- Continue to Step 2

**If any tests fail:**
- Do NOT write `.claude/g-team-approved`
- Report the failing tests verbatim
- Stop with verdict: `HOLD — tests failing. Fix all test failures before re-running /g-team review.`
- Do not proceed to Step 2

**If the project has no tests** (no test directory, no test script, no test framework detected):
- Report: `⚠ No test suite detected`
- Ask the developer: "No tests found. Options: (a) dispatch test-writer to add an appropriate test suite now, (b) skip tests for this review (one-time override). Which do you prefer?"
- **If developer chooses (a):** dispatch the `test-writer` agent with the current diff and project stack context. Ask test-writer to write tests covering the changed code. Once tests are written and pass, continue to Step 2.
- **If developer chooses (b):** note `⚠ No tests — developer override` in the review output and continue to Step 2. Do not block.

## Step 2 — Gather the diff

Run:
```
git diff main...HEAD
```

If output is empty, run: `git diff --staged`

If both are empty, ask the developer: "What branch or commit range should I review?"

## Step 3 — Gather done conditions

Check for done conditions in this order:
1. The relevant plan file (check `docs/plans/` for the most recent `.md` file, or a spec mentioned by the developer)
2. The current milestone file in `milestones/`
3. Ask the developer: "What are the done conditions for this implementation?"

If no done conditions can be found, note this — code-lead will flag it as a process gap.

## Step 4 — Dispatch code-lead

Dispatch the `code-lead` agent. Provide:
- The full diff from Step 2
- The done conditions from Step 3
- The current branch name (from `git branch --show-current`)
- The task list (if known)

code-lead will verify done conditions and dispatch review-orchestrator internally. Wait for code-lead's complete verdict.

## Step 5 — Present verdict and manage sentinel

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
