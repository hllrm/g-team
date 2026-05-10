---
name: g-review
description: Run the full review pipeline on the current branch diff. Dispatches code-lead which verifies done conditions and runs review-orchestrator. Issues MERGE READY or HOLD.
---

**Announce:** "Using g-review to run the full review pipeline."

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
- Stop with verdict: `HOLD — tests failing. Fix all test failures before re-running /g-review.`
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

Dispatch the `code-lead` agent. Provide **all of the following** in the prompt so code-lead does not re-run already-completed checks:

- **Attested test result** — state explicitly: `"Tests: PASS (attested — exit 0, output below)"` and include the captured output from Step 1, OR `"Tests: skipped — developer override"` if the developer chose (b). If tests failed, you do not reach this step.
- **Attested type-check result** — if a type-checker was run (e.g. `vue-tsc --noEmit`, `tsc --noEmit`) in any prior step or by an implementing agent, include: `"Type-check: PASS (attested — exit 0)"`. If not run, omit this line.
- The full diff from Step 2
- The done conditions from Step 3
- The current branch name (from `git branch --show-current`)
- The task list (if known)

code-lead will verify remaining done conditions structurally (file checks, grep, read) and dispatch review-orchestrator internally. It must NOT re-run tests or type-check when attested results are provided. Wait for code-lead's complete verdict.

## Step 5 — Tier 3 Smoke Test (MERGE READY path only)

If code-lead's verdict is **HOLD** or **ESCALATE**, skip to Step 6 — no smoke test needed until blocking issues are fixed.

If code-lead's verdict is **MERGE READY**:

1. Check whether `.claude/tier3-active` exists. If it does, a listen-mode session is already in progress — skip straight to Step 6.
2. Print the testing instrument:
   - Check for `docs/qa-scope/<milestone-slug>.md`. If it exists, read it and print the in-scope test groups.
   - If no QA scope doc: check whether the project has a QA panel (README, project docs). If it does, list the known affected test groups.
   - If no QA panel: retrieve or regenerate the test plan that was produced at milestone planning. Print it in full — the developer uses it as their checklist.
3. Prompt the developer:

   > "Code review passed. **Tier 3 — smoke test the changes.**
   > Work through the list above and report each finding in chat — say **'done this round'** when finished."

4. Write `0` to `.claude/tier3-active`.
5. **Listen mode is now active.** Rules while in listen mode:
   - Do NOT edit any files.
   - Do NOT suggest fixes or make comments about what might be wrong.
   - For each finding the developer reports, respond only with: `Bug N logged — <area>`
   - Increment the count in `.claude/tier3-active` after each acknowledgement.
6. When the developer says **"done this round"**:
   - Delete `.claude/tier3-active`.
   - If the count was **0** (no bugs reported): proceed to Step 6.
   - If any bugs were logged: triage the full batch (systemic vs. isolated), dispatch fix waves, re-run from Step 1 after fixes land. Do not proceed to Step 6 until a clean smoke-test round returns 0 bugs.

## Step 6 — Present verdict and manage sentinel

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
- Tell the developer: "HOLD. Fix all blocking items listed above, then re-run /g-review."

**If verdict is ESCALATE:**
- Do NOT write `.claude/g-team-approved`
- Present the escalation details and ask the developer for guidance before proceeding.

## Rules
- Never modify code-lead's verdict — present it exactly.
- Never write `.claude/g-team-approved` for anything other than MERGE READY.
- Never skip Step 5 (Tier 3 smoke test) on a MERGE READY verdict — the sentinel must not be written until at least one clean smoke-test round completes.
- If code-lead is blocked by missing information, gather it and re-dispatch — do not guess.
- The sentinel is automatically cleared after the next `git commit` by the commit hook.
- In listen mode: zero edits, zero suggestions, acknowledgement only. Violations of listen mode reset the round.
