# G-Rules — Claude Code Session Discipline

Drop at project root. In `CLAUDE.md` add: `@G-RULES.md`

---

## A · Session Rules

**A1 Model** — Haiku: explore / reads / search / format · Sonnet: implement / write · Opus: only after 2 fails on same task. Never default Opus because a task "feels hard."

**A2 Plan** — Atomic verifiable tasks before touching files. Log in `todo.md`. Identify Wave 1 (no blockers). Vague goals ("make it work") → ask before starting.

**A3 Execution workflow**
- Execute 1st pass only (no scope creep mid-wave)
- Before committing — mandatory gate: run the project's lint and test commands (check `package.json`, `Makefile`, `pyproject.toml`, or CI config for the right commands). Any red = stop, fix first.
- Business logic / public API / bug fix → tests required. Pure UI render → skip is OK, state why explicitly. Silence = not acceptable.
- Pure functions inside a component → extract to the project's lib/utils layer first, then test
- After each commit: update `todo.md` (remove closed rows + Details), append to `todo-done.md`, commit immediately — never leave either file dirty
- End of pass: rewrite `## Handoff` block in `todo.md` (replace, never append), commit, post the same block in chat

**A4 Token optimisation**
- Grep before Read — find line numbers, then read only those lines (`limit` + `offset`)
- No full-file reads on files >100 lines unless rewriting the whole file
- All independent tool calls in the same message (parallel)
- Cache `file:line` refs — never re-read the same file. Never re-Grep what an agent returned.
- Edit tool for partials; Write only for full rewrites. One logical change per commit.
- Don't refactor or optimise in the same pass as the feature/fix

**A5 Mindset** — State assumptions. No features / abstractions / error-handling beyond the ask. Every changed line traces to the request. Don't improve adjacent code. Remove imports made unused by your changes; leave pre-existing dead code alone and mention it.

**A6 Delivery** — Complete snippets with all imports. Explain WHY not what. Mark placeholders (`YOUR_API_KEY`). Flag security risks. No `TODO`/`FIXME` in delivered code.

**A7 Three-Strikes** — Same bug class × 3 attempts = STOP. Name the mechanism. List what failed and why. Find an alternative that bypasses it entirely. Escalate model before attempt 3, not after.
Warning signs: error message changes but bug class persists · you're explaining why *this* approach should work when the last one didn't · fix requires knowing internals of a platform component you don't control.

---

## B · G-Team Workflow

### Project lifecycle (run once at project start)

```
/g-kickoff    → interview developer, produce project_brief.md
/g-roadmap    → milestone plan → ROADMAP.md + milestones/M*.md
/g-init       → scaffold files, hook scripts, settings.json
/g-specialize → detect stack, install architect agent + rules profile
```

For an existing project without g-team: run `/g-onboard` instead of the above sequence.

### Per-task loop — auto-triggered, Claude initiates without being asked

```
/g-plan       → decompose task, schedule waves, write specs — wait for approval
/g-execute    → dispatch waves in parallel, hold boundary between waves
/g-review     → code-lead gate — issues MERGE READY or HOLD
```

**Non-trivial** = ≥3 files, new feature, layer-boundary change, bug fix with unclear root cause, or anything with multiple dependent steps. Single-file edits with a known location may proceed inline.

**Auto-trigger rule:** Do not wait for the user to type `/g-plan`, `/g-execute`, or `/g-review`. Detect the condition and trigger automatically.

**Wave execution rule:** always use `/g-execute` for wave-based parallel dispatch.

### Maintenance and support skills

| Skill | Purpose |
|-------|---------|
| `/g-update` | Pull latest plugin from GitHub, realign all g-team-managed project files |
| `/g-brief` | Refresh `project_brief.md` from the current conversation |
| `/g-status` | One-shot snapshot: branch, active milestone, next task |
| `/g-help` | Context-aware help — reads project state and detects workflow phase |
| `/g-doctor` | Health check: missing files, broken hooks, config drift, sentinel state |
| `/g-listen` | Enter Tier 3 listen mode for smoke test collection |
| `/g-skill-design` | Design a new plugin skill from a brief |
| `/g-skill-validate` | Validate a skill or agent file against plugin architecture rules |

### Hard stops

- Never commit without `.claude/g-team-approved` — the commit gate will block it
- Never skip `/g-plan` for non-trivial tasks — "it's quick" is not an exception
- `code-lead` HOLD = fix everything listed, re-review. No partial merges.
- `git commit` is HQ-only, after MERGE READY. Never instruct subagents to commit — they implement and return results only.

---

## C · Agent Discipline

**HQ = command centre only.** Decomposes, directs, integrates, commits. Never does grunt work an agent could do.

**Wave model** — Classify every step: Independent / Dependent / Sequential-by-file. All independent steps launch in one message. Never split a wave across messages.

**When to spawn vs. inline**

| Situation | Action |
|-----------|--------|
| Non-trivial feature or multi-step task | `/g-plan` first |
| All agent work ready to merge | `/g-review` gate before commit |
| Open-ended search, unknown locations, >3 files | Spawn **Explore** agent |
| Self-contained implementation, inputs fully known | Spawn **general-purpose** agent |
| Long task that would bloat main context | Spawn agent |
| Exact file:line known, <3 targeted edits | Inline |
| Needs mid-task judgment or back-and-forth | Inline — keep in HQ |
| Build / audit >2 min with clear done condition | Background agent |
| Same bug class, 3rd attempt | Stop inline. Explore agent + escalate model + different mechanism. |

**Agent prompt must include:** exact `file:line` refs for known things · scope boundary (what NOT to touch) · one specific verifiable done condition · enough WHY for judgment calls.

**Results flow:** summary + `file:line` refs back to HQ — never raw file dumps.

**Caps:** Hard limit 7 agents/task. 4 agents in one wave = warning sign, restructure first.

**Background by default** for anything >~2 min that doesn't block HQ's next move.

---

## D · Code Quality

**Style**
- `const` everywhere; `let` only when reassignment is unavoidable; never `var`
- Module-level `let` requires a WHY comment — explain why it's not a reactive/store value
- Named exports only (no `export default` in lib/composables; components/classes are the exception)
- Return early / fail fast — validate at top, minimise nesting
- One responsibility per module/component (SRP). No duplication — extract shared logic.

**Naming — files**

| Type | Convention |
|------|------------|
| Components / classes | `PascalCase` |
| Lib / utilities / stores | `camelCase` |
| Composables | `camelCase`, prefix `use` |

**Naming — functions**

| Type | Convention |
|------|------------|
| Data reads | `fetchX` |
| Data writes | `createX` / `updateX` |
| Event handlers | `handleX` |
| Booleans | `isX` / `hasX` |
| Store actions | verb + noun (`setActivePage`) |
| Unused args | `_arg` prefix |

Composable export matches filename: `useFoo.ts` → `export function useFoo`.

**Comments** — WHY only: hidden constraint, subtle invariant, platform workaround. One line max. No commented-out blocks. Use `// region Name` / `// endregion` in files >~150 lines.

**Error handling** — Explicit errors, no silent failures. Validate at system boundaries only (user input, external API). Never hardcode secrets. Watch for O(n²) on critical paths.

**Testing**
- Fixed hardcoded data — never `Date.now()` or random values in setup
- Static expected values — no programmatically built expected strings
- Happy path + boundary conditions + error cases
- Named by scenario, not "it works"
- Mandatory: bug fixes · critical business logic · public APIs
- Optional: internal helpers tested indirectly via integration tests

**Component / module structure** — Stack-specific. See `.claude/rules/architecture-<stack>.md` installed by `/g-specialize`.

**Branch discipline**
- Non-trivial work (≥3 files, new feature, layer-boundary change, unclear bug, public API change) → create a feature branch before the first file change: `git checkout -b feat/<slug>`, `fix/<slug>`, or `refactor/<slug>`
- All work subject to the commit gate (`.claude/g-team-approved` required) regardless of branch
- MERGE READY verdict on a feature branch → HQ merges to main (`git merge --no-ff`) or opens a PR. Never force-push to main.
- MERGE READY on main is only acceptable for: hotfixes (single-file bug fix), doc-only changes (README, CHANGELOG, comments), or version bumps. Everything else requires a branch.
- Branch naming: `feat/<slug>` for new features, `fix/<slug>` for bug fixes, `refactor/<slug>` for refactors, `chore/<slug>` for housekeeping

---

## E · Architecture Gate

Architecture rules: `.claude/rules/architecture-<stack>.md` — installed by `/g-specialize`
Architecture reviewer: `.claude/agents/<stack>-architect.md` — installed by `/g-specialize`

Run `/g-specialize` once after `/g-init` to detect the project stack and install the correct profile. Re-run if the stack or data layer changes significantly.

**Non-trivial** = any of: ≥3 files · layer-boundary path · new component/store/composable/route · public API change · refactor / migrate / restructure / new feature.

**Mandatory sequence:**
1. Plan Mode — no writes
2. Map each file to its layer (cite rules file by line)
3. Validate import directions — source layer → target layer must be permitted
4. Confirm state ownership — mutations in declared owner only
5. Confirm side-effect ownership — HTTP/IPC calls in service/composable layer only
6. Invoke architecture-review subagent → wait for PASS/FAIL report
7. Present: plan + review + files grouped by layer
8. Wait for explicit human approval before exiting Plan Mode

**Hard stops — refuse and ask for guidance if:**
- Any import flows up or sideways across layer boundaries
- Business logic in UI atoms, molecules, or pages
- Direct API/IPC calls outside the service/composable layer
- Circular dependency would be created
- State ownership duplicated across two modules

---

## F · Design Patterns

**Principles**
- **Composition over inheritance** — favour small, focused units composed together. Inheritance for true is-a relationships only; everything else is composition or delegation.
- **Explicit over implicit** — visible dependencies, clear data flow, no magic registration or auto-wiring. If you can't trace where something comes from by reading the call site, it's too implicit.
- **YAGNI** — no abstractions, generics, base classes, or extensibility hooks until there is a second concrete use case. The first use case defines the shape; the second reveals the pattern.
- **Fail fast at boundaries** — validate and throw at system entry points (user input, external API, IPC). Never let invalid state propagate inward; never swallow it silently.
- **Observer / event-driven** — decouple producers from consumers via events, signals, or channels. Components that react to state changes subscribe; they do not poll, reach up the hierarchy, or hold a direct reference to the emitter. The emitter knows nothing about its subscribers.
- **State machine for discrete modes** — when a unit has ≥3 mutually exclusive modes (loading/idle/error, grounded/jumping/falling, locked/unlocked/expired), model them as an explicit state machine — not nested booleans, not string comparisons, not flag fields. Each state owns its enter, update, and exit behaviour.

**Anti-patterns — refuse unless there is an explicit documented reason**
- **God object / god component** — one class or component responsible for more than one coherent concern. Split by responsibility, not by line count.
- **Prop drilling past 2 levels** — pass data through more than two component layers via props. Use a store, context, or composable instead.
- **Business logic in the UI layer** — pages and components wire state and handle events; they do not compute, transform, or validate domain data. Extract to lib/, services/, or composables/.
- **Mutable module-level state** — module-level `let` that is mutated at runtime causes invisible coupling between callers and breaks SSR and test isolation.
- **Premature abstraction** — a shared utility, base class, or generic extracted from a single use case. Wait for the second caller; the first use case defines the interface, the second validates it.
- **Magic values** — naked numbers or strings with non-obvious meaning inline in logic. Extract to a named constant with a comment if the name alone isn't self-evident.
- **Circular dependencies** — always indicates a layer boundary violation or a missing intermediate abstraction. Resolve by extracting the shared dependency or inverting the dependency direction.
- **Catch-and-continue** — `catch (e) {}` or `catch (e) { return null }` without logging, re-throwing, or surfacing to the caller. Every caught error must be handled explicitly or re-thrown.

**Stack-specific patterns** live in `.claude/rules/architecture-<stack>.md`, installed by `/g-specialize`. The rules above apply universally; stack rules add or refine them for the specific architecture.

---

## G · Testing Protocol

**Three tiers — different owners, different rules.**

**Tier 1 — Automated Gates** (Claude owns · blocking on every commit)
Lint · type-check · unit tests · build verification. Any red = stop, do not commit, report and fix first.

**Tier 2 — Tooling-Assisted** (Claude runs when infrastructure exists)
E2E, integration, contract tests. If infrastructure is missing and the task touches a critical path, flag the gap explicitly — never silently skip.

**Tier 3 — Human-Driven** (user owns the verdict · Claude never infers pass from output)
Smoke tests · acceptance · design review · business logic correctness. User exercises the real app and reports findings in chat. Claude cannot substitute judgement here.

---

**Tier 3 Instrument — QA Panel or Test Plan**

Tier 3 requires a testing instrument. Which one depends on the project:

- **QA panel present** — a structured in-app testing UI. G-Team integrates it from the start, not as an afterthought.
  - At milestone planning: identify which test groups are impacted. Compile `docs/qa-scope/<milestone-slug>.md` mapping each in-scope group to what must pass.
  - QA panel currency: any task adding/removing user-facing surface must include "QA panel updated" as a done condition. MERGE READY is blocked if the panel is stale.
- **No QA panel** — at milestone planning, generate a test plan and print it in chat. The test plan lists scenarios to exercise, grouped by feature area, derived from the milestone scope. The developer uses this as their checklist during Tier 3. No file saved — it is a live prompt artifact.

The instrument is established at milestone start. Tier 3 without an instrument (no QA panel and no generated test plan) is not valid.

---

**Tier 3 Protocol — Listen Mode**

Run `/g-listen` to enter listen mode. It writes the state file, prints the instrument, and enforces the collect-only discipline automatically.

Manual protocol (if `/g-listen` is unavailable):

1. Print the instrument: QA panel scope (from `docs/qa-scope/<milestone-slug>.md`) or the test plan generated at milestone start.
2. Prompt: `Ready for smoke test? Work through the list above and report each finding in chat — say "done this round" when finished.`
3. Claude enters **listen mode** — no fixes, no suggestions, no edits. Acknowledge each report only:
   > `Bug N logged — <bug area>`
4. User declares **"done this round"**
5. Claude triages the full batch:
   - Same class ≥ 2 occurrences → **systemic**: grep all instances, treat as one wave
   - Single occurrence, known location → **isolated**: inline fix
6. Systemic waves execute first, then isolated fixes
7. Tier 1 gates run after fixes before next round begins
8. Next Tier 3 round → back to listen mode
9. Repeat until user declares DoD met

**Hard stops during listen mode:** No file edits. No mid-round fixes. No "quick suggestions." Collect and triage only — never act on a single report in isolation.

**Listen mode state file — `.claude/tier3-active`**
- When entering listen mode: write `0` to `.claude/tier3-active`
- After each bug is acknowledged: increment the count in `.claude/tier3-active`
- After triage and fix wave completes: delete `.claude/tier3-active`
- The workflow-checkpoint hook reads this file and surfaces listen mode status on every prompt

---

## Project Tracking

### File hierarchy

| File | Written by | Purpose |
|------|-----------|---------|
| `project_brief.md` | `/g-kickoff` | Project goals, constraints, stack decisions |
| `ROADMAP.md` | `/g-roadmap` | Milestone plan — current, backlog, done |
| `milestones/M*.md` | `/g-roadmap`, `/g-plan` | Per-milestone scope, tasks, done conditions |
| `todo.md` | HQ | Active task ledger — Handoff + Tasks + Details |
| `todo-done.md` | HQ | Archive of closed tasks and pass reports |

### Commit gate infrastructure

Three hook scripts installed by `/g-init` under `.claude/hooks/`:

- **`check-commit.sh`** (PreToolUse) — blocks `git commit` if `.claude/g-team-approved` is absent. `/g-review` writes the sentinel after issuing MERGE READY.
- **`post-commit-cleanup.sh`** (PostToolUse) — deletes `.claude/g-team-approved` after each successful commit. The gate resets automatically.
- **`workflow-checkpoint.sh`** (UserPromptSubmit) — reads branch, milestone, review state, and Tier 3 listen mode on every prompt. Output appears as a system reminder at the top of each turn.

Never bypass the commit gate with `--no-verify` or by manually writing the sentinel.

### todo.md structure

**`todo.md`** — three sections only:
1. `## Handoff` — one block, replaced (never appended) each pass. Cold-start context.
2. `## Tasks` — `| # | Task | Notes |` table. Notes column: `*` when a Details section exists.
3. `## Details` — `### N — Title` subsections for asterisked rows only.

**`todo-done.md`** — archive. All closed tasks, pass reports, and summaries. Never inflate `todo.md` with history.

Rules: closing a task = remove row + Details from `todo.md`, append to `todo-done.md`. Both files committed every session. Every edit to either file commits immediately — never left dirty.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HANDOFF — <project> | branch: <branch>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Done this pass:   · <item>
Next up:          · <item>
Active context:   · <file:line, state, in-flight logic>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Same content in both the committed file and the chat message — chat is for paste, file is the persistent record.
