# G-Team Agent Reference

All 15 G-Team agents are available in every project after `/plugin install g-team`. Stack-profile agents (`vue-architect`, `node-architect`, `fastapi-architect`) are installed per-project by `/g-team specialize`.

---

## Model Tiers

G-Team assigns models by task nature — not by escalation.

| Tier | Model | Used for |
|------|-------|----------|
| **Opus** | `claude-opus-4-*` | Critical judgment: code review, security audit, architecture enforcement, technical sign-off |
| **Sonnet** | `claude-sonnet-4-*` | Reasoning and orchestration: planning, debugging, performance analysis, coordination |
| **Haiku** | `claude-haiku-4-*` | Deterministic execution: generate from spec, write tests, write docs, write PRs |

The right model is assigned upfront in each agent's frontmatter. You never need to choose.

---

## Planning Agents

### `task-decomposer` — Sonnet

**Mandate:** Break a request into atomic, independently executable tasks. Each task includes: what to do, which file(s) to touch, and a mechanically checkable done condition.

**Dispatch when:** You have a feature request or bug fix that involves more than one file or step and want a structured task list before starting.

**Give it:** The full request, any known file paths, any constraints.

**Returns:** A numbered task list, each with file scope and done condition. Flags any "Clarify:" items that need resolution before work can start.

**Does not:** Estimate effort, suggest implementation approaches, or touch files.

---

### `wave-planner` — Sonnet

**Mandate:** Take a task list and produce a parallel execution schedule. Groups tasks by dependency: Wave 1 = all tasks that can run in parallel, Wave 2+ = tasks unblocked by the prior wave.

**Dispatch when:** You have a task list from `task-decomposer` and want to know what can run in parallel.

**Give it:** The complete task list with done conditions.

**Returns:** A wave schedule table: wave number, tasks in that wave, and what each wave is blocked by.

**Does not:** Add or remove tasks, estimate time, or make implementation decisions.

---

### `spec-writer` — Sonnet

**Mandate:** Produce an implementation spec precise enough that a Haiku-tier agent can execute it without making judgment calls. Includes: inputs, outputs, constraints, exact file paths, and edge cases.

**Dispatch when:** You have a task and want a written spec before handing it to an executor (e.g., `refactor-executor` or `test-writer`).

**Give it:** The task description, relevant file paths, any architectural constraints.

**Returns:** A structured spec with explicit inputs, outputs, file paths, and a done condition.

**Does not:** Implement anything or make architecture decisions.

---

## Quality Agents (Opus)

### `code-reviewer` — Opus

**Mandate:** Review code for logic errors, code smells, DRY violations, edge cases, and production reliability issues. Report with `file:line` references and severity. Never fix.

**Dispatch when:** Changes are ready for quality review before merge, or you want a second opinion on a specific implementation.

**Give it:** The diff or the files to review, plus context on what the code is supposed to do.

**Returns:** Findings grouped by severity (BLOCKING / WARNING / SUGGESTION) with `file:line` refs and specific remediation guidance.

**Does not:** Edit files, suggest architectural changes (that's `architecture-enforcer`), or audit for security (that's `security-auditor`).

---

### `security-auditor` — Opus

**Mandate:** Audit for OWASP Top 10 vulnerabilities, injection vectors (SQL, command, path traversal), secrets exposure, auth and session flaws, insecure dependencies, and unsafe deserialization.

**Dispatch when:** Any code that handles user input, authentication, secrets, file paths, or external data is being reviewed.

**Give it:** The files or diff to audit, plus context on the data flows involved.

**Returns:** Findings with CVE references where applicable, severity (CRITICAL / HIGH / MEDIUM / LOW), affected `file:line`, and remediation guidance.

**Does not:** Fix vulnerabilities, perform penetration testing, or audit infrastructure.

---

### `architecture-enforcer` — Opus

**Mandate:** Validate layer boundary integrity, import directions, separation of concerns, and SRP. Flag any file that violates the project's defined layer map.

**Dispatch when:** Changes touch more than one layer, introduce a new component, or cross a module boundary. Always included in full review pipeline.

**Give it:** The diff or files to review, plus the project's layer map (from CLAUDE.md architecture rules section if present).

**Returns:** Violations with `file:line`, the rule being broken, and the correct fix pattern.

**Does not:** Fix violations, make product decisions, or audit code quality (that's `code-reviewer`).

---

## Reasoning Agents (Sonnet)

### `performance-auditor` — Sonnet

**Mandate:** Flag algorithmic complexity issues (O(n²) or worse on critical paths), N+1 database queries, unnecessary re-renders in UI code, expensive computations in hot paths, and missing pagination on unbounded queries.

**Dispatch when:** Changes touch data-fetching logic, loops over large collections, render-critical UI paths, or database queries without limits.

**Give it:** The diff or files to review, plus context on expected data volume.

**Returns:** Findings with `file:line`, estimated impact (affects every request vs. edge case), and a recommended fix pattern.

**Does not:** Fix issues, benchmark code, or audit for security.

---

### `debugger` — Sonnet

**Mandate:** Given a failing test or bug report, reproduce the issue, trace the root cause through the call stack, and propose a fix strategy. Stop at strategy — never implement.

**Dispatch when:** A bug is confirmed and you want root cause analysis before fixing.

**Give it:** The failing test output or bug description, the relevant files, and any reproduction steps.

**Returns:** Root cause identified with `file:line`, a step-by-step explanation of how the bug occurs, and a proposed fix strategy.

**Does not:** Edit files, run tests speculatively, or fix the bug.

---

### `error-detective` — Sonnet

**Mandate:** Parse logs, stack traces, and error output. Identify patterns, distinguish symptom from cause, and narrow down to probable root causes. Works from raw output — does not need reproduction steps.

**Dispatch when:** You have an error log, stack trace, or crash report and want to understand what happened before debugging.

**Give it:** The raw error output, stack trace, or log excerpt. Optionally: the relevant source files.

**Returns:** Pattern identified, probable root cause with confidence level, and recommended next step (usually: dispatch `debugger` with this finding).

**Does not:** Fix anything, read the full codebase speculatively, or run commands.

---

### `project-manager` — Sonnet

**Mandate:** Own the full feature lifecycle from roadmap to merged PR. Coordinates `task-decomposer`, `wave-planner`, `spec-writer`, and `code-lead`. Never touches files directly.

**Dispatch when:** You want end-to-end feature management — planning through review — handed off in one step.

**Give it:** The feature request, current roadmap state, any known constraints.

**Returns:** A coordinated execution plan and then drives it through to a PR-ready state by dispatching the right agents in the right order.

**Does not:** Write code, edit files, or make architectural decisions directly.

---

### `review-orchestrator` — Sonnet

**Mandate:** Run the full review pipeline in parallel: `code-reviewer`, `security-auditor`, `performance-auditor`, and (if layer boundaries were touched) `architecture-enforcer`. Aggregate findings into a single report. Never touches files.

**Dispatch when:** Running a full pre-merge review. Usually dispatched by `code-lead`, not directly.

**Give it:** The branch diff, the list of changed files, and the done conditions for the work being reviewed.

**Returns:** Aggregated findings report across all reviewers: BLOCKING items first, then WARNINGS, then SUGGESTIONS. Includes a summary verdict.

**Does not:** Issue MERGE READY (that's `code-lead`'s call), fix anything, or make product decisions.

---

## Execution Agents (Haiku)

### `test-writer` — Haiku

**Mandate:** Write unit tests given a function signature, spec, or description. Fixed data only — no `Date.now()`, `Math.random()`, or other non-deterministic values. Covers: happy path, boundary conditions, and error cases.

**Dispatch when:** You have a spec or implemented function and want test coverage written.

**Give it:** The function signature or spec, the test framework in use, any example inputs/outputs.

**Returns:** Complete test file(s) ready to run. Tests are self-contained — no external fixtures required unless provided.

**Does not:** Implement the code under test, write integration or end-to-end tests, or make architectural choices.

---

### `doc-writer` — Haiku

**Mandate:** Write inline documentation and README sections from code. Explains WHY, not WHAT. No restating of what the code already says. No multi-paragraph docstrings unless the function is genuinely complex.

**Dispatch when:** Code needs documentation — function/module docstrings, README sections, or architectural decision records.

**Give it:** The file(s) to document and any context about design intent or non-obvious decisions.

**Returns:** Documentation added inline or as Markdown output, ready to paste. Focuses on constraints, invariants, and non-obvious choices.

**Does not:** Refactor code, write tutorials, or create marketing copy.

---

### `pr-writer` — Haiku

**Mandate:** Generate a PR description from `git diff` output. Format: summary, what changed, why it changed, test plan.

**Dispatch when:** Changes are ready to merge and you need a PR description.

**Give it:** The `git diff` output (or the diff summary), the done conditions for the work.

**Returns:** A structured PR description: one-line title, bullet summary, what/why sections, test plan checklist.

**Does not:** Review code quality, run tests, or make merge decisions.

---

### `refactor-executor` — Haiku

**Mandate:** Execute a written refactor spec exactly. No scope creep, no adjacent improvements, no judgment calls. If the spec says rename `foo` to `bar`, it renames `foo` to `bar` — nothing else.

**Dispatch when:** You have a written spec from `spec-writer` and want it executed mechanically.

**Give it:** The complete refactor spec, the files to touch.

**Returns:** The refactored files. Reports what was changed and what was intentionally left unchanged.

**Does not:** Improve code beyond the spec, fix bugs noticed while refactoring, or make design decisions.

---

## Orchestration Agents

### `code-lead` — Opus

**Mandate:** Guard technical quality at the commit level. Verifies done conditions, dispatches `review-orchestrator` for the full review pipeline, and issues the final MERGE READY or HOLD verdict. Blocks non-passing merges.

**Dispatch when:** Running `/g-team review`. This is the merge gate.

**Give it:** The branch diff, done conditions, branch name, and task list.

**Returns:** MERGE READY (with `.claude/g-team-approved` sentinel written by the skill) or HOLD with a prioritised fix list.

**Does not:** Fix code, write tests, or approve merges without a full review pipeline.

---

## Stack Profile Agents

Installed per-project by `/g-team specialize`. Once installed they are project-native — no plugin required.

| Agent | Stack | Model |
|-------|-------|-------|
| `vue-architect` | Vue 3 + Pinia | Sonnet |
| `node-architect` | Node.js + TypeScript | Sonnet |
| `fastapi-architect` | FastAPI + Pydantic | Sonnet |

Each architect agent knows its stack's layer map, import rules, and anti-patterns. Dispatch during any review or planning task that touches stack-specific code.
