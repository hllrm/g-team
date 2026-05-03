---
name: g-team-onboard
description: Onboard G-Team onto an existing codebase. Reads the repo first, presents findings, interviews about what's next, optionally audits current architecture with code-lead, and produces project_brief.md. Run before /g-team init and /g-team specialize on existing projects.
argument-hint: (none)
---

**Announce:** "Using g-team-onboard to onboard this codebase."

You are bringing G-Team structure to an existing project. You read before you ask — questions are grounded in what you observed, not speculative.

## Step 1 — Read the codebase

Read every source that exists — skip silently if absent.

**Directory structure:**

List the project root (top 2 levels). Note top-level directories and their apparent purpose (src, app, tests, docs, packages, etc.).

**Key files to read:**

- `README.md` — project description, stack hints, setup instructions
- `package.json` — name, description, dependencies, devDependencies, scripts
- `pyproject.toml` — project metadata, dependencies, tool config
- `requirements.txt` — Python dependencies
- `CLAUDE.md` — existing project rules (if G-Team rules already present, note it)
- `project_brief.md` — if already exists, read it and tell the developer: "A project_brief.md already exists — I'll use it as the base and update it rather than starting fresh."

**Entry point detection:**

Look for whichever of these exist:
- `src/index.ts`, `src/main.ts`, `src/app.ts`, `src/server.ts` — Node/TypeScript
- `main.py`, `app.py`, `src/main.py`, `src/app/main.py` — Python / FastAPI
- `src/App.vue`, `src/main.ts` — Vue

**Test structure:**

Look for `tests/`, `test/`, `__tests__/`, `spec/` directories. Note: test framework (jest, vitest, pytest, etc.) and rough coverage signal (many test files vs. few vs. none vs. no test directory).

**Architecture signals:**

Look for layer directories: `routes/`, `controllers/`, `services/`, `repositories/`, `models/`, `stores/`, `composables/`, `schemas/`, `middleware/`. Note any that exist.

## Step 2 — Present findings

Present a concise picture of what you found. Use this format exactly:

```
Codebase read ✓

Stack:           [e.g. Node.js + TypeScript + Express, or Vue 3 + Pinia, or FastAPI + SQLAlchemy]
Entry point:     [e.g. src/index.ts  — or "not found"]
Architecture:    [e.g. routes/controllers/services detected  — or "flat structure"  — or "monorepo: packages/"]
Tests:           [e.g. Jest · 24 test files in tests/  — or "no test directory found"]
G-Team rules:    [Already in CLAUDE.md  — or "not present"]
project_brief:   [Found — will update  — or "not found — will create"]

Notable:
  - [observation, e.g. "No test directory — test-writer will be valuable early"]
  - [observation, e.g. "src/controllers/ files are large — refactor-executor worth considering"]
  - [observation, e.g. "requirements.txt has 60+ dependencies — security-auditor worth an early run"]
```

Omit the Notable block if there is nothing worth flagging.

Then ask: **"Does this match what you're working with? Anything to correct before I continue?"**

Wait for the developer's confirmation. Update your understanding if corrected before moving on.

## Step 3 — Interview: what's next?

Ask these questions one group at a time. Wait for each answer before moving to the next.

**Group 1 — The work**

> "What do you want to do with this codebase? (New feature, refactor, performance fix, bringing a new team member up to speed, something else?)"

Follow up based on the answer:
- New feature: "What specifically? What user problem does it solve?"
- Refactor: "Which area? What's driving it — tech debt, performance, architecture violation?"
- Performance: "Where is it slow? Do you have metrics, or is it a hunch?"
- Onboarding a team member: note this — the brief should document the architecture in more detail than usual.

**Group 2 — Constraints**

> "What constraints matter here? Think: timeline, team size, areas of the code that are fragile or off-limits, anything you don't want touched."

**Group 3 — Existing problems**

> "Before we plan new work — is there anything in the current codebase you'd want me to know about? Fragile areas, known bugs, tech debt you want to avoid building on top of?"

**Group 4 — Stack confirmation (only if ambiguous)**

Ambiguous means: multiple lockfiles found (package.json AND requirements.txt), polyglot top-level directories, or the Stack line in Step 2 contained a "?" or "or". If the stack was clear and single-runtime, skip this group.

If the stack was unclear after Step 1, or if multiple runtimes might be involved:

> "I detected [stack]. Is this accurate? Are there any other runtimes or frameworks in use I should know about — a separate service, a mobile app, a background worker, a different language in another part of the repo?"

Skip this group if the stack was clear.

## Step 4 — Optional architecture audit

Ask:

> "Should I dispatch code-lead to audit the current architecture before we plan new work? It will flag layer boundary violations, wrong import directions, and structural problems worth knowing about before adding to the codebase. Worth it if you're planning significant changes. (y/n)"

**If yes:**

Dispatch `code-lead` with:
- The directory structure and architecture signals from Step 1
- The stack detected
- Any layer map inferred from directory names
- The relevant source files (entry points + service/controller/route files if found)

Ask code-lead:
> "Audit this codebase for architecture issues: layer boundary violations, wrong import directions, files doing too much (SRP violations), and any structural patterns that will make the planned work harder to add cleanly. Flag each finding as BLOCKING, HIGH, MEDIUM, or LOW severity. Do not fix anything — report only. Planned work: [insert Group 1 answer from Step 3]."

Present code-lead's findings to the developer:

**"Architecture audit complete. Here's what code-lead found:"** followed by the findings.

Then ask: "Do you want to address any of these before planning the new work, or should I factor them into the brief as known risks?"

**If no:** proceed to Step 5.

## Step 5 — Produce project_brief.md

Write `project_brief.md` with this structure:

```markdown
# [Project name — from package.json name field, or README title, or directory name]

## Current state

**Stack:** [detected stack]
**Architecture:** [layer structure observed — or "flat" if no layers found]
**Tests:** [framework and rough coverage signal]
**Entry point:** [file path — or "not identified"]

## Problem / Goal

[What the developer wants to accomplish — from Group 1 interview]

## Scope

### In scope
[Features or changes confirmed in the interview]

### Out of scope
[Explicitly named constraints, fragile areas, off-limits code from Groups 2–3]

### Known risks / existing issues
[Tech debt or fragile areas from Group 3. Architecture findings from Step 4 if the audit was run.]

## Tech decisions

| Component | Choice | Rationale | Risk | Code-lead note |
|-----------|--------|-----------|------|----------------|
[One row per top-level choice only: language runtime, framework, ORM/database library, test runner, key infrastructure (auth, queue, storage). Do NOT list transitive or utility dependencies. Rationale = "already in use". Risk = Low for stable established deps — flag anything unusual, old, or with known CVEs. Code-lead note = relevant audit finding if Step 4 was run, otherwise "-".]

## Technical constraints

[Deadline if given. Team size if given. Off-limits areas. Any other constraints from Groups 2–3.]
```

If `project_brief.md` already existed, merge the new information in. Preserve any existing content that remains accurate — do not overwrite wholesale.

## Step 6 — Report and suggest next steps

```
project_brief.md written ✓

Suggested next steps:

  /g-team init        Install commit enforcement, inject G-rules into CLAUDE.md,
                      scaffold ROADMAP.md and milestones/

  /g-team specialize  Install [detected stack] architect agent and architecture rules
                      (reads project_brief.md automatically)

  /g-team plan        When you're ready to start the work described in the brief
```

If the architecture audit found BLOCKING or HIGH severity issues, add:

```
  Before /g-team plan, consider addressing the architecture issues code-lead flagged.
  Dispatch spec-writer with the refactor description, then refactor-executor to execute it.
```

## Rules

- Never write `project_brief.md` before Steps 3 and 4 are complete — the brief's "Known risks" section depends on both the interview answers and any audit findings.
- Never skip Step 2 confirmation — if the developer corrects your reading, update before continuing.
- Dispatch code-lead only if the developer confirms in Step 4 — not by default.
- If `project_brief.md` already exists, update it — do not replace content that is still accurate.
- Do not run `/g-team init` or `/g-team specialize` yourself — suggest them and stop.
- Group 4 (stack confirmation) is optional — skip it unless: multiple lockfiles exist, polyglot directories were found, or the Stack field in Step 2 was uncertain.
