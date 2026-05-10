# G-Team Agents

All 16 agents ship with every install. Stack-specific architect agents are installed per-project by `/g-specialize` and are not listed here.

---

## Orchestration

Agents that coordinate other agents and own the feature or review lifecycle end-to-end. They never write or edit code themselves.

### `project-manager`
**Tier:** Sonnet  
**Role:** Owns everything from roadmap to merged PR — maintains milestones, breaks product goals into wave plans, and drives the full feature lifecycle through to a PR-ready state.  
**Use when:** You want end-to-end feature management handed off in one step: scope → plan → execute → gate → PR description.  
**Give it:** The feature request, current roadmap state, and any known constraints.  
**Returns:** A coordinated execution plan, then drives it through `task-decomposer`, `wave-planner`, `spec-writer`, `code-lead`, and `pr-writer` in the right order.

---

### `review-orchestrator`
**Tier:** Sonnet  
**Role:** Coordinates the full review pipeline — code review, architecture, security, and performance in parallel — and aggregates findings into one report.  
**Use when:** Running a full pre-merge review. Usually dispatched by `code-lead`, not directly.  
**Give it:** The branch diff and the list of changed files.  
**Returns:** An aggregated findings report across all reviewers: Critical findings first, then Major, then Minor, with an overall PASS / PASS WITH NOTES / FAIL verdict.

---

### `code-lead`
**Tier:** Opus  
**Role:** Guards technical quality at every level — milestone feasibility, commit reviews, and merge gates — by verifying done conditions and running the full review pipeline via `review-orchestrator`.  
**Use when:** Running `/g-review` after implementation waves complete; this is the merge gate. Also consult during milestone planning for technical feasibility and sequencing risk.  
**Give it:** The branch diff, done conditions, branch name, and task list.  
**Returns:** MERGE READY or HOLD with a prioritised fix list; at the roadmap level, a sequencing recommendation with reasoning.

---

## Implementation

Agents that plan and execute concrete work: decomposing requests, scheduling waves, writing specs, and executing changes.

### `task-decomposer`
**Tier:** Sonnet  
**Role:** Breaks any request into atomic, verifiable tasks with mechanically checkable done conditions.  
**Use when:** You have a feature request or bug fix that involves more than one file or step and want a structured task list before starting.  
**Give it:** The full request, any known file paths, and any constraints.  
**Returns:** A numbered task list table with file scope and done condition per task. Flags any "Clarify:" items that need resolution before work can start.

---

### `wave-planner`
**Tier:** Sonnet  
**Role:** Takes a task list and produces a parallel wave execution schedule by mapping dependencies.  
**Use when:** You have a task list from `task-decomposer` and need to know what can run in parallel before handing off to executors.  
**Give it:** The complete task list with done conditions (the table from `task-decomposer`).  
**Returns:** A wave schedule: each wave lists the tasks it contains and what each wave is blocked by, plus a peak-parallelism summary.

---

### `spec-writer`
**Tier:** Sonnet  
**Role:** Produces a precise implementation spec from a brief or task — precise enough for a Haiku agent to execute without making judgment calls.  
**Use when:** You have a task and want a written spec before handing it to an executor such as `refactor-executor` or `test-writer`.  
**Give it:** The task description, relevant file paths, and any architectural constraints.  
**Returns:** A structured spec with goal, inputs, outputs, constraints, exact file paths, step-by-step implementation steps, and a done condition.

---

### `refactor-executor`
**Tier:** Haiku  
**Role:** Executes a written refactor spec exactly — no scope creep, no adjacent improvements, no judgment calls.  
**Use when:** You have a complete spec from `spec-writer` and want it executed mechanically.  
**Give it:** The complete refactor spec and the files to touch.  
**Returns:** The refactored files, a step-by-step completion report, and a list of adjacent issues noticed but not acted on.

---

## Review & Quality

Agents that audit code changes and report findings. None of them fix what they find.

### `code-reviewer`
**Tier:** Opus  
**Role:** Reviews code changes for logic errors, code smells, DRY violations, edge cases, and production reliability issues.  
**Use when:** Changes are ready for quality review before merge, or you want a second opinion on a specific implementation.  
**Give it:** The diff or the files to review, plus context on what the code is supposed to do.  
**Returns:** Findings grouped by severity (Critical / Major / Minor) with `file:line` refs and specific remediation guidance in prose.

---

### `security-auditor`
**Tier:** Opus  
**Role:** Audits for OWASP Top 10 vulnerabilities, injection vectors, secrets exposure, and auth flaws.  
**Use when:** Any code that handles user input, authentication, secrets, file paths, or external data is being reviewed — especially before any merge touching auth or external integrations.  
**Give it:** The files or diff to audit, plus context on the data flows involved.  
**Returns:** Findings with vulnerability class, attack scenario, severity (Critical / High / Medium / Low), `file:line`, and remediation guidance.

---

### `architecture-enforcer`
**Tier:** Opus  
**Role:** Validates layer boundary integrity, import directions, and separation of concerns — reporting violations with `file:line` refs.  
**Use when:** Changes touch more than one layer, introduce a new component, or cross a module boundary. Dispatched conditionally by `review-orchestrator` when layer-boundary files are changed.  
**Give it:** The diff or files to review, plus the project's layer map (from CLAUDE.md if present).  
**Returns:** Violations with `file:line`, the rule broken, the correct fix pattern, and a PASS / FAIL verdict.

---

### `performance-auditor`
**Tier:** Sonnet  
**Role:** Flags O(n²) paths, N+1 queries, unnecessary re-renders, hot-path waste, and resource leaks.  
**Use when:** Changes touch data-fetching logic, loops over large collections, render-critical UI paths, or database queries without limits.  
**Give it:** The diff or files to review, plus context on expected data volume.  
**Returns:** Findings with `file:line`, estimated impact (e.g. "O(n²) on items array: 10k items = 100M iterations"), and a recommended fix approach.

---

## Debugging & Investigation

Agents that investigate failures and error output. Neither implements fixes.

### `debugger`
**Tier:** Sonnet  
**Role:** Reproduces a failing test or bug, traces root cause through the call stack, and proposes a fix strategy — stopping at strategy, never implementing.  
**Use when:** A bug is confirmed and you want root cause analysis before fixing, especially when a first fix attempt has already failed.  
**Give it:** The failing test output or bug description, the relevant files, and any reproduction steps.  
**Returns:** A debug report identifying the failure point and root cause at `file:line`, what was ruled out, a numbered fix strategy, and a verification method.

---

### `error-detective`
**Tier:** Sonnet  
**Role:** Parses logs, stack traces, and error output to identify patterns and narrow root causes — working from raw output without needing reproduction steps.  
**Use when:** You have an error log, stack trace, or crash report and want to understand what happened before handing off to `debugger`.  
**Give it:** The raw error output, stack trace, or log excerpt. Optionally the relevant source files.  
**Returns:** Error classification, origin, recurrence pattern, the 2-3 most likely root causes ranked by probability, and the specific thing to check to confirm.

---

## Output

Agents that produce deliverables: tests, documentation, and PR descriptions.

### `test-writer`
**Tier:** Haiku  
**Role:** Writes unit tests from a function signature or implementation spec, using fixed data only — no `Date.now()`, `Math.random()`, or generated UUIDs.  
**Use when:** You have a spec or implemented function and want test coverage written, including upfront TDD tests that fail until the function exists.  
**Give it:** The function signature or spec, the test framework in use, and any example inputs/outputs.  
**Returns:** Complete, immediately runnable test file(s) written to the correct project location, covering happy path, boundary conditions, and error cases.

---

### `doc-writer`
**Tier:** Haiku  
**Role:** Writes inline documentation and README sections from code — explaining WHY (constraints, decisions, non-obvious behavior), never restating what the code already says.  
**Use when:** Code needs documentation: function/module docstrings, README sections, or design-decision notes after implementation is complete.  
**Give it:** The file(s) to document and any context about design intent or non-obvious decisions.  
**Returns:** Documentation added inline or as Markdown output, focused on constraints, invariants, and non-obvious choices.

---

### `pr-writer`
**Tier:** Haiku  
**Role:** Generates a PR description from `git diff` output — what changed, why it changed, and how to test it.  
**Use when:** Changes are ready to merge and you need a PR description written for a human reviewer who has not seen the code before.  
**Give it:** The `git diff main...HEAD` output (or equivalent) and the done conditions for the work.  
**Returns:** A structured PR description: feature/fix title, "What changed" bullets, a mandatory "Why" section, and an actionable test checklist.
