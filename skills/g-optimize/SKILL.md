---
name: g-optimize
description: Full-codebase or targeted performance audit. Detects algorithmic complexity problems, N+1 queries, re-render waste, resource leaks, and caching opportunities. Targeted scope produces an inline report. Whole-codebase scope produces a prioritised roadmap milestone.
argument-hint: [path/to/scope]
---

**Announce:** "Using g-optimize to scan for performance issues."

You are scanning code for performance problems. You detect — you do not fix. Fixing is handled by `/g-refactor`.

## Step 1 — Determine scope

**If an argument was provided** (e.g. `/g-optimize src/services`):
- Set `mode: targeted`, `scope: [argument]`. Skip the question below.

**If no argument was provided**, ask:
> "Scan the whole codebase (findings will become a prioritised roadmap entry) or a specific area?
> Type a path to scope (e.g. `src/services`) or **all** for the full codebase."

Wait for the answer. Set `mode: targeted` or `mode: full` accordingly.

## Step 2 — Detect stack context

Read `CLAUDE.md` and `package.json` / `pyproject.toml` / `Cargo.toml` (whichever exists) to identify:
- UI framework (React, Vue, Svelte, Angular — enables UI-specific checks)
- ORM or DB layer (Prisma, TypeORM, SQLAlchemy, Drizzle, ActiveRecord — enables N+1 checks)
- Runtime (Node, Python, Go, Rust — determines applicable patterns)

Apply scope filter: scope all subsequent searches to `[scope]` when `mode: targeted`.

## Step 3 — Pattern scan (run all in parallel)

**Complexity — nested loops over collections**
```bash
# Nested forEach/map/filter — O(n²) candidates
grep -rn "\.forEach\|\.map\|\.filter\|\.find\|\.reduce" \
  --include="*.ts" --include="*.tsx" --include="*.js" \
  --exclude-dir=node_modules --exclude-dir=dist \
  [scope] -l | xargs grep -l "\.forEach\|\.map\|\.filter" | head -20
```
For each flagged file, read it to identify genuinely nested iterations over unbounded collections.

**Complexity — sort/search inside frequently called functions**
```bash
grep -rn "\.sort(\|\.find(\|\.filter(" \
  --include="*.ts" --include="*.tsx" --include="*.py" \
  --exclude-dir=node_modules \
  [scope]
```
Flag sorts and linear searches that appear inside render functions, request handlers, or event callbacks.

**N+1 — query/API call inside a loop**
```bash
grep -rn "await\s\+[a-zA-Z]*\.\(find\|findOne\|findById\|get\|fetch\|query\|execute\)(" \
  --include="*.ts" --include="*.tsx" --include="*.js" \
  --exclude-dir=node_modules \
  [scope]
```
Flag any `await db.*` or `await api.*` that appears inside a `for`, `forEach`, `map`, or `reduce` body.

```bash
# Python ORM N+1
grep -rn "\(\.filter(\|\.get(\|\.all()\)" \
  --include="*.py" \
  [scope]
```

**Hot path waste — regex construction inside functions**
```bash
grep -rn "new RegExp(" \
  --include="*.ts" --include="*.tsx" --include="*.js" --include="*.py" \
  --exclude-dir=node_modules \
  [scope] | grep -v "\.test\.\|\.spec\."
```
Flag `new RegExp()` calls that are not at module scope — they recompile on every call.

**Hot path waste — expensive operations on every state change**
```bash
# Deep clone on render/computed
grep -rn "JSON\.parse(JSON\.stringify\|structuredClone\|deepClone\|cloneDeep" \
  --include="*.ts" --include="*.tsx" --include="*.js" \
  --exclude-dir=node_modules \
  [scope]
```

**UI — re-render waste (React)**
```bash
# Inline object/array literals as props (new reference on every render)
grep -rn "<[A-Z][a-zA-Z]* [^>]*={\s*{" \
  --include="*.tsx" --include="*.jsx" \
  --exclude-dir=node_modules \
  [scope]

# Event handlers recreated on every render
grep -rn "on[A-Z][a-zA-Z]*={(" \
  --include="*.tsx" --include="*.jsx" \
  --exclude-dir=node_modules \
  [scope] | grep -v "useCallback"
```

**UI — re-render waste (Vue)**
```bash
# Computed values that depend on the whole store rather than a slice
grep -rn "useStore\(\)\." \
  --include="*.vue" --include="*.ts" \
  --exclude-dir=node_modules \
  [scope]
```

**Resource leaks — listeners and subscriptions without cleanup**
```bash
grep -rn "addEventListener\|\.on(\|\.subscribe(" \
  --include="*.ts" --include="*.tsx" --include="*.js" \
  --exclude-dir=node_modules \
  [scope] -l | xargs grep -L "removeEventListener\|\.off(\|\.unsubscribe(\|cleanup\|dispose\|onUnmounted\|useEffect.*return"
```
Files that add listeners without corresponding removal are leak candidates.

**Resource leaks — timers without cleanup**
```bash
grep -rn "setInterval\|setTimeout" \
  --include="*.ts" --include="*.tsx" --include="*.js" \
  --exclude-dir=node_modules \
  [scope] -l | xargs grep -L "clearInterval\|clearTimeout\|cleanup\|onUnmounted\|return () =>"
```

**Bundle size — large whole-library imports**
```bash
grep -rn "^import \* as\|^import [A-Z][a-zA-Z]* from '[a-z]" \
  --include="*.ts" --include="*.tsx" --include="*.js" \
  --exclude-dir=node_modules \
  [scope] | grep -v "\.test\.\|\.spec\." | head -30
```
Flag whole-library imports where tree-shakable named imports would suffice (lodash, date-fns, etc.).

**Caching opportunities — repeated identical computations**
```bash
grep -rn "\.filter(.*\.map(\|\.map(.*\.filter(" \
  --include="*.ts" --include="*.tsx" --include="*.js" \
  --exclude-dir=node_modules \
  [scope] | grep -v "\.test\.\|\.spec\."
```

## Step 4 — Score each finding

**Severity**
- Critical (3): O(n²)+ on an unbounded collection in a hot path; N+1 on every request; timer/listener leak with no cleanup
- Major (2): sort/search inside render or handler without memoization; regex construction in hot function; deep clone on every state change; inline object props causing cascade re-renders
- Minor (1): whole-library import with tree-shakable alternative; regex outside hot path; theoretical caching opportunity

**Impact**
- High (3): called on every request, render, or user action; affects core feature path
- Medium (2): called frequently but not on every interaction; affects one feature
- Low (1): called rarely, background task, or admin path

**Change risk**
- High (3): no tests, many callers, touches shared infrastructure
- Medium (2): some tests, moderate coupling
- Low (1): well-tested, isolated, few callers

**Priority score** = (Severity × Impact) / Change Risk

| Score | Tier | Label |
|-------|------|-------|
| ≥ 6 | P0 | Fix Now — measurable user impact |
| 3–5 | P1 | This cycle — significant latency/memory debt |
| 1–2 | P2 | Next cycle — schedule it |
| < 1 | P3 | Backlog — low ROI |

## Step 5a — Targeted mode output

```
## Performance Audit — [scope]
Generated: [date]

### P0 — Fix Now
- `file:line` [Severity] [category] — [what was found, quantified where possible]
  Impact: [e.g. "O(n²) on items array — 10k items = 100M iterations"]
  Fix approach: [one sentence]

### P1 — This Cycle
...

### P2 / P3
...

---
Summary: N issues (P0: X · P1: Y · P2: Z · P3: W)
```

After the report:
> "Run `/g-refactor [scope]` to begin a guided optimisation of this area."

## Step 5b — Whole-codebase mode output

Print the condensed findings summary, then ask:
> "Found [N] performance issues. Add these to the roadmap as a prioritised optimisation milestone? (y/n)"

If yes, write `milestones/M-optimize-[YYYY-MM].md`:

```markdown
# M-optimize-[YYYY-MM] — Performance: Full Codebase Audit

**Generated:** [date]
**Status:** ⬜ Not started
**Goal:** Resolve [N] performance findings ordered by user-facing impact and risk.
**Risk level:** [Low / Medium / High]

---

## P0 — Fix Now (Wave 1)

| # | Finding | File | Category | Estimated Impact | Change Risk |
|---|---------|------|----------|-----------------|-------------|
| 1 | [description] | `file:line` | [N+1 / O(n²) / leak / etc.] | [quantified] | Low |

**Done condition:** All P0 items resolved, Tier 1 gates pass, performance regression tests added where applicable.

---

## P1 — This Cycle (Wave 2)
[table]

---

## P2 — Schedule Next Cycle
[table]

---

## P3 — Backlog
[table]

---

## Execution notes
- Run `/g-refactor milestones/M-optimize-[YYYY-MM].md` to begin guided execution.
- For every P0 fix: add a benchmark or assertion that will catch regression before merging.
- P0 and P1 items must pass `/g-review` before P2 work begins.
```

Append to `ROADMAP.md`:
```markdown
### M-optimize-[YYYY-MM] — Performance Audit ([date])
**Status:** ⬜ Not started
**Goal:** Resolve [N] performance findings ordered by user-facing impact (P0–P3).
**Scope:**
- P0 ([X] items): [brief — e.g. N+1 queries, O(n²) loops]
- P1 ([Y] items): [brief — e.g. re-render waste, regex in hot paths]
- P2/P3 ([Z] items): scheduled for later cycles
**Depends on:** [current active milestone or —]
```

Confirm:
> "Milestone written to `milestones/M-optimize-[YYYY-MM].md` and added to ROADMAP.md. Run `/g-refactor milestones/M-optimize-[YYYY-MM].md` to begin."

## Rules
- Report findings only — no fixes.
- Every finding must cite `file:line` and quantify impact where possible ("O(n²) on items: 10k items = 100M iterations" is more useful than "nested loop").
- UI re-render checks only apply when a UI framework is detected in Step 2.
- N+1 checks only apply when an ORM or API client is detected in Step 2.
- Never write the milestone file without explicit developer confirmation.
- If a category scan returns zero findings, omit it from the report silently.
