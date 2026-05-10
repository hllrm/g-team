---
name: g-audit
description: Full-codebase or targeted code quality audit. Detects SOLID violations, code smells, architectural drift, dead code, and test coverage gaps. Targeted scope produces an inline report. Whole-codebase scope produces a prioritised roadmap milestone.
argument-hint: [path/to/scope]
---

**Announce:** "Using g-audit to scan for code quality issues."

You are scanning code for technical debt. You detect — you do not fix. Fixing is handled by `/g-refactor`.

## Step 1 — Determine scope

**If an argument was provided** (e.g. `/g-audit src/services`):
- Treat it as a path scope. Set `mode: targeted`, `scope: [argument]`.
- Skip the question below.

**If no argument was provided**, ask:
> "Scan the whole codebase (findings will become a prioritised roadmap entry) or a specific area?
> Type a path to scope (e.g. `src/services`) or **all** for the full codebase."

Wait for the answer. Set:
- `mode: targeted` if a path was given
- `mode: full` if "all" or no path was given

## Step 2 — Map the codebase structure

Run these in parallel:

```bash
# Source file count by directory (top 20 dirs)
find . -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.py" \
  -o -name "*.go" -o -name "*.rs" -o -name "*.cs" -o -name "*.kt" -o -name "*.swift" \
  -o -name "*.dart" -o -name "*.rb" -o -name "*.ex" \) \
  -not -path "*/node_modules/*" -not -path "*/.git/*" \
  -not -path "*/dist/*" -not -path "*/build/*" -not -path "*/__pycache__/*" \
  | sed 's|/[^/]*$||' | sort | uniq -c | sort -rn | head -20
```

```bash
# Files over 300 lines (SRP candidates) — excludes tests and generated files
find . -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.py" \
  -o -name "*.go" -o -name "*.rs" -o -name "*.cs" \) \
  -not -path "*/node_modules/*" -not -path "*/.git/*" \
  -not -path "*/dist/*" -not -path "*/build/*" \
  -not -name "*.test.*" -not -name "*.spec.*" -not -name "*_test.*" \
  | xargs wc -l 2>/dev/null | sort -rn | awk '$1 > 300 && NF==2 {print $0}'
```

Read `CLAUDE.md` and `project_brief.md` (if they exist) to understand the declared layer map and stack.

Apply the scope filter: if `mode: targeted`, all subsequent searches are scoped to `[scope]` instead of `.`.

## Step 3 — Pattern scan (run all in parallel)

Run these grep commands to find violation candidates. Use the scope path in place of `.` when `mode: targeted`.

**SOLID — SRP: mixed concerns**
```bash
grep -rn "fetch\|axios\|http\.\|request(" \
  --include="*.ts" --include="*.tsx" --include="*.js" \
  --exclude-dir=node_modules --exclude-dir=dist \
  [scope] | grep -v "\.test\.\|\.spec\.\|service\|api\|client\|repository"
```
Flag files that call HTTP directly outside the designated service/api layer.

**SOLID — OCP: type-switch dispatchers**
```bash
grep -rn "switch\s*(" \
  --include="*.ts" --include="*.tsx" --include="*.js" --include="*.py" --include="*.go" \
  --exclude-dir=node_modules --exclude-dir=dist \
  [scope]
```
Flag `switch` blocks that match on a `type`, `kind`, or `action` discriminant — these require editing for each new variant.

**SOLID — LSP: broken override contracts**
```bash
grep -rn "throw new Error\|raise NotImplementedError\|panic!\|throw Exception" \
  --include="*.ts" --include="*.py" --include="*.go" --include="*.rs" \
  --exclude-dir=node_modules \
  [scope] | grep -v "\.test\.\|\.spec\."
```
Cross-reference with class definitions: flag throws that appear in override methods where the base type returns a value.

**SOLID — ISP: not-implemented stubs**
```bash
grep -rn -i "not.*implemented\|NotImplemented\|TODO.*implement\|throw.*not.*implement" \
  --include="*.ts" --include="*.py" --include="*.cs" --include="*.go" \
  --exclude-dir=node_modules \
  [scope]
```

**SOLID — DIP: concrete instantiation in domain/service code**
```bash
grep -rn "\bnew [A-Z][a-zA-Z]*\(Service\|Repository\|Client\|Adapter\|Driver\|Dao\|Store\)\b" \
  --include="*.ts" --include="*.js" \
  --exclude-dir=node_modules --exclude-dir=dist \
  [scope] | grep -v "\.test\.\|\.spec\."
```

**Smells — magic values**
```bash
grep -rn "[^a-zA-Z_\"'][3-9][0-9]\{1,\}\|[^a-zA-Z_\"'][0-9]\{3,\}" \
  --include="*.ts" --include="*.tsx" --include="*.py" --include="*.go" \
  --exclude-dir=node_modules --exclude-dir=dist \
  [scope] | grep -v "\.test\.\|\.spec\.\|port\|timeout\|delay\|size\|limit"
```

**Smells — catch-and-swallow**
```bash
grep -rn -A2 "catch\s*(" \
  --include="*.ts" --include="*.tsx" --include="*.js" \
  --exclude-dir=node_modules \
  [scope] | grep -B1 "^--$\|{}\|{ }\|return null\|return undefined\|return false" | grep "catch"
```

**Dead code — TODO/FIXME markers**
```bash
grep -rn "TODO\|FIXME\|HACK\|XXX" \
  --include="*.ts" --include="*.tsx" --include="*.py" --include="*.go" --include="*.rs" \
  --exclude-dir=node_modules \
  [scope]
```

**Coverage gaps — exported public API without tests**
```bash
# Find exported functions/classes
grep -rn "^export\s\+\(function\|class\|const\|async\)" \
  --include="*.ts" --include="*.tsx" \
  --exclude-dir=node_modules --exclude-dir=dist \
  --exclude="*.test.*" --exclude="*.spec.*" \
  [scope] | head -40
```
Then check whether corresponding test files exist for each module.

## Step 4 — Score each finding

For every finding from Step 3, assign three scores:

**Severity**
- Critical (3): broken contract (LSP), DIP violation in core domain, catch-and-swallow on critical path
- Major (2): god object (>300 lines, mixed concerns), OCP violation in hot dispatch path, ISP stubs
- Minor (1): magic values, TODO markers, OCP in low-churn code

**Impact** — how much does fixing this improve the codebase?
- High (3): affects many callers, core business logic, frequently modified file
- Medium (2): affects one module or feature area
- Low (1): isolated utility, rarely touched

**Change risk** — how dangerous is it to change this?
- High (3): no tests, many dependents, public API surface, cross-cutting concern
- Medium (2): some tests, moderate coupling
- Low (1): well-tested, isolated, few callers

**Priority score** = (Severity × Impact) / Change Risk

**Priority tiers:**
| Score | Tier | Label |
|-------|------|-------|
| ≥ 6 | P0 | Fix Now — blocks quality |
| 3–5 | P1 | This cycle — significant debt |
| 1–2 | P2 | Next cycle — schedule it |
| < 1 | P3 | Backlog — low ROI |

## Step 5a — Targeted mode output

Print the findings report:

```
## Audit Report — [scope]
Generated: [date]

### P0 — Fix Now
- `file:line` [Severity] [category] — [what was found] (Impact: High, Risk: Low)

### P1 — This Cycle
- `file:line` ...

### P2 — Next Cycle
...

### P3 — Backlog
...

---
Summary: N findings (P0: X · P1: Y · P2: Z · P3: W)
```

After the report, offer:
> "Run `/g-refactor [scope]` to begin a guided refactor of this area, or `/g-audit` with no args to scan the full codebase."

## Step 5b — Whole-codebase mode output

First, print a condensed findings summary (same format as 5a).

Then ask:
> "Found [N] issues across the codebase. Add these to the roadmap as a prioritised technical debt milestone? (y/n)"

If yes:

**Group findings by theme:**
- Architecture & SOLID violations
- Code smells & DRY
- Dead code & coverage gaps
- Each theme becomes a task group in the milestone

**Write the milestone file** to `milestones/M-audit-[YYYY-MM].md`:

```markdown
# M-audit-[YYYY-MM] — Technical Debt: Full Codebase Audit

**Generated:** [date]
**Status:** ⬜ Not started
**Goal:** Resolve [N] findings from the [date] audit, ordered by risk-adjusted priority.
**Risk level:** [Low / Medium / High — based on highest P0 risk score]

---

## P0 — Fix Now (Wave 1)

| # | Finding | File | Severity | Impact | Change Risk |
|---|---------|------|----------|--------|-------------|
| 1 | [description] | `file:line` | Critical | High | Low |

**Done condition:** All P0 items resolved and passing Tier 1 gates.

---

## P1 — This Cycle (Wave 2)

| # | Finding | File | Severity | Impact | Change Risk |
|---|---------|------|----------|--------|-------------|
| 2 | [description] | `file:line` | Major | High | Medium |

**Done condition:** All P1 items resolved or explicitly deferred with documented rationale.

---

## P2 — Schedule Next Cycle

[table — same format]

---

## P3 — Backlog

[table — same format]

---

## Execution notes
- Run `/g-refactor milestones/M-audit-[YYYY-MM].md` to begin guided execution of this milestone.
- P0 and P1 items must pass `/g-review` before P2 work begins.
- High change-risk items must have test coverage added before refactoring (flag for test-writer first).
```

**Append to ROADMAP.md:**
Add a new milestone entry:
```markdown
### M-audit-[YYYY-MM] — Technical Debt Audit ([date])
**Status:** ⬜ Not started
**Goal:** Resolve [N] audit findings ordered by risk-adjusted priority (P0–P3).
**Scope:**
- P0 ([X] items): [brief theme list]
- P1 ([Y] items): [brief theme list]
- P2/P3 ([Z] items): scheduled for later cycles
**Depends on:** [current active milestone or —]
```

Confirm:
> "Milestone written to `milestones/M-audit-[YYYY-MM].md` and added to ROADMAP.md. Run `/g-refactor milestones/M-audit-[YYYY-MM].md` to begin."

## Rules
- Report findings only — no fixes, no rewrites.
- Every finding must cite `file:line`.
- Priority scores are estimates, not guarantees. Developers may override tier assignments.
- Change risk must reflect actual test coverage and coupling — do not default everything to Low.
- If pattern scan returns no findings in a category, omit that category from the report.
- Never write the milestone file without explicit developer confirmation.
