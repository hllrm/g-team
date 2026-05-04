# G-Rules — Claude Code Session Discipline

Drop at project root. In `CLAUDE.md` add: `@G-RULES.md`
Set `.claude/rules/architecture-<stack>.md` and `.claude/agents/architecture-review.md` for Part D.

---

## A · Session Rules

**A1 Model** — Haiku: explore / reads / search / format · Sonnet: implement / write · Opus: only after 2 fails on same task. Never default Opus because a task "feels hard."

**A2 Plan** — Atomic verifiable tasks before touching files. Log in `todo.md`. Identify Wave 1 (no blockers). Vague goals ("make it work") → ask before starting.

**A3 Execution workflow**
- Execute 1st pass only (no scope creep mid-wave)
- Before committing — mandatory gate: `npm test` all green + `npm run lint` 0 errors
- Business logic / public API / bug fix → tests required. Pure UI render → skip is OK, state why explicitly. Silence = not acceptable.
- Pure functions inside a component → extract to `src/lib/` first, then test
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

## B · G-Team Workflow (mandatory)

**Every non-trivial task starts with `project-manager`.** Non-trivial = ≥3 files, new feature, layer-boundary change, bug fix with unclear root cause, or anything with multiple dependent steps. Single-file edits with a known location may proceed inline.

**Auto-triggered sequence — Claude initiates without being asked:**
1. `/g-team plan` — non-trivial task detected → immediately run before any file changes. Drives task-decomposer → wave-planner → spec-writer, presents plan, waits for approval.
2. `/g-team execute` — plan approved → immediately dispatch waves. Runs agents in parallel per wave, holds boundary between waves.
3. `/g-team review` — implementation complete / user wants to merge → immediately run. `code-lead` verifies done conditions + dispatches review-orchestrator. Issues MERGE READY or HOLD.
4. HQ merges only after MERGE READY — never before.

**Auto-trigger rule:** Do not wait for the user to type `/g-team plan`, `/g-team execute`, or `/g-team review`. Detect the condition and trigger automatically.

**Wave execution rule:** always use `/g-team execute` for wave-based parallel dispatch. Never use `superpowers:dispatching-parallel-agents` in a g-team project — that skill is superseded by g-team-execute.

**Hard stops:**
- Never commit agent work without `code-lead` sign-off
- Never skip `project-manager` for non-trivial tasks — "it's quick" is not an exception
- `code-lead` HOLD = fix everything listed, then re-review. No partial merges.
- `git commit` is HQ-only, after MERGE READY. Never instruct subagents to commit — they implement and return results only.

---

## C · Agent Discipline

**HQ = command centre only.** Decomposes, directs, integrates, commits. Never does grunt work an agent could do.

**Wave model** — Classify every step: Independent / Dependent / Sequential-by-file. All independent steps launch in one message. Never split a wave across messages.

**When to spawn vs. inline**

| Situation | Action |
|-----------|--------|
| Non-trivial feature or multi-step task | `project-manager` first |
| All agent commits ready to merge | `code-lead` gate before merge |
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

**Component structure**
```
src/components/
  atoms/       — single-purpose, no app-state deps
  molecules/   — combine 2-3 atoms, stateless
  organisms/   — stateful, use stores or composables
  layout/      — app shell, navigation
src/pages/     — thin: layout + state wiring only, no logic >30 lines
src/lib/       — pure functions, constants shared across components
```
Sub-components with their own state or >30 lines → own file. Constants used by >1 component → `src/lib/`.

**Branch discipline**
- Non-trivial work (≥3 files, new feature, layer-boundary change, unclear bug, public API change) → create a feature branch before the first file change: `git checkout -b feat/<slug>`, `fix/<slug>`, or `refactor/<slug>`
- All work subject to the commit gate (`.claude/g-team-approved` required) regardless of branch
- MERGE READY verdict on a feature branch → HQ merges to main (`git merge --no-ff`) or opens a PR. Never force-push to main.
- MERGE READY on main is only acceptable for: hotfixes (single-file bug fix), doc-only changes (README, CHANGELOG, comments), or version bumps. Everything else requires a branch.
- Branch naming: `feat/<slug>` for new features, `fix/<slug>` for bug fixes, `refactor/<slug>` for refactors, `chore/<slug>` for housekeeping

---

## E · Architecture Gate

Architecture map: `.claude/rules/architecture-<stack>.md`
Architecture reviewer: `.claude/agents/architecture-review.md`
Update the map when the stack or data layer changes.

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

**Stack-specific patterns** live in `.claude/rules/architecture-<stack>.md`, installed by `/g-team specialize`. The rules above apply universally; stack rules add or refine them for the specific architecture.

---

## Project Tracking

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
