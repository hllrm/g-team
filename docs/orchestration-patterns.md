# G-Team Orchestration Patterns

Four standard workflows built from G-Team agents. Each pattern shows which agents run, in what order, and what each one receives and returns.

---

## Pattern 1 — Feature Build

**Trigger:** `/g-team plan` followed by wave execution.

**When to use:** Any non-trivial feature — three or more files, a new component, a layer-boundary change, or unclear scope.

**Flow:**

```
/g-team plan
  └─ task-decomposer (Sonnet)
       receives: feature request, file paths, constraints
       returns:  numbered task list with done conditions

  └─ wave-planner (Sonnet)
       receives: task list from task-decomposer
       returns:  wave schedule (Wave 1 = parallel starters, Wave N = unblocked by prior wave)

  └─ [approval gate — developer reviews and approves]

Wave 1 (all tasks in parallel)
  └─ [implement per task — agents or HQ]
       each task: implement → test → commit

Wave 2 (if dependencies exist)
  └─ [dependent tasks implement]

/g-team review
  └─ code-lead (Opus)
       receives: diff, done conditions, branch name
       dispatches review-orchestrator →
         code-reviewer (Opus)        — in parallel
         security-auditor (Opus)     — in parallel
         performance-auditor (Sonnet) — in parallel
         architecture-enforcer (Opus) — if layer boundaries touched
       returns: MERGE READY or HOLD with fix list
```

**Example — adding user authentication:**

```
task-decomposer receives:
  "Add email/password auth with JWT. Users table in Postgres.
   Protected routes return 401 if no valid token."

task-decomposer returns:
  1. Create User model and migration           (src/models/user.ts)       done: migration runs clean
  2. Create auth service (hash, verify, sign)  (src/services/auth.ts)     done: unit tests pass
  3. Create /auth/register and /auth/login     (src/routes/auth.ts)       done: returns JWT on success
  4. Create auth middleware                    (src/middleware/auth.ts)    done: 401 on missing/invalid token
  5. Write tests for service                   (tests/services/auth.ts)   done: happy + error cases pass
  6. Write tests for routes                    (tests/routes/auth.ts)     done: integration tests pass

wave-planner returns:
  Wave 1: tasks 1, 2 (independent)
  Wave 2: tasks 3, 4 (depend on 1 + 2)
  Wave 3: tasks 5, 6 (depend on 2 + 3)
```

---

## Pattern 2 — Full Review

**Trigger:** `/g-team review`

**When to use:** Before any merge. Non-negotiable — the commit gate is locked until MERGE READY.

**Flow:**

```
/g-team review
  └─ [gather diff: git diff main...HEAD]
  └─ [gather done conditions: from spec or milestone file]

  └─ code-lead (Opus)
       receives: diff, done conditions, branch name
       verifies: all done conditions are met in the diff
       dispatches →

         review-orchestrator (Sonnet)
           dispatches in parallel →
             code-reviewer (Opus)
               receives: diff + context
               returns:  BLOCKING/WARNING/SUGGESTION findings with file:line

             security-auditor (Opus)
               receives: diff + data flow context
               returns:  CRITICAL/HIGH/MEDIUM/LOW findings with remediation

             performance-auditor (Sonnet)
               receives: diff + data volume context
               returns:  findings with impact estimate

             architecture-enforcer (Opus)   [only if layer-boundary files touched]
               receives: diff + layer map from CLAUDE.md
               returns:  violations with file:line and correct pattern

           aggregates: all findings into single report

       code-lead issues verdict:
         MERGE READY  → skill writes .claude/g-team-approved
         HOLD         → prioritised fix list, no sentinel written
```

**Verdict meanings:**

- **MERGE READY** — all done conditions met, no BLOCKING findings. Commit gate unlocked.
- **HOLD — FIX REQUIRED** — one or more BLOCKING findings or done conditions not met. Fix all items and re-run `/g-team review`.
- **ESCALATE** — code-lead cannot determine verdict (missing context, contradictory requirements). Needs developer input before proceeding.

---

## Pattern 3 — Debug

**Trigger:** Manual — when a bug is confirmed and reproduction steps exist.

**When to use:** A specific, reproducible bug. Not for intermittent issues without logs.

**Flow:**

```
error-detective (Sonnet)
  receives: raw error output, stack trace, or log excerpt
  returns:  pattern identified, probable root cause, confidence level

debugger (Sonnet)
  receives: error-detective's findings + relevant source files
  returns:  root cause with file:line, how the bug occurs step-by-step,
            proposed fix strategy (not implementation)

[developer reviews fix strategy — approves or adjusts]

test-writer (Haiku)
  receives: debugger's fix strategy + test framework in use
  returns:  regression test that fails before the fix and passes after

[implement fix]

/g-team review    ← always run before committing the fix
```

**Example — N+1 query bug:**

```
error-detective receives:
  "API response time 8s on /api/orders. Server logs show 47 DB queries per request."

error-detective returns:
  Pattern: N+1 query — one query per order item fetching product details.
  Probable cause: orders.map(o => db.product.findById(o.productId)) in OrderService.
  Confidence: High. Recommend: dispatch debugger with OrderService.ts.

debugger receives:
  error-detective findings + src/services/order.ts

debugger returns:
  Root cause: OrderService.getOrdersWithProducts() line 34 — fetches products
  in a loop inside an async map. Each iteration issues a separate SELECT.
  Fix strategy: replace with a single JOIN query or batch fetch all product IDs
  first, then do one SELECT ... WHERE id IN (...). Recommend the JOIN approach
  for this schema.

test-writer receives:
  Fix strategy + existing test setup

test-writer returns:
  test that mocks DB and asserts getOrdersWithProducts calls db.query exactly once
```

---

## Pattern 4 — Planned Refactor

**Trigger:** Manual — when a refactor has clear scope and must not break architecture.

**When to use:** Any refactor touching more than two files, crossing a module boundary, or renaming a public interface.

**Flow:**

```
spec-writer (Sonnet)
  receives: refactor description, files to touch, scope boundary
  returns:  precise spec with: what moves where, exact renames,
            what is explicitly NOT changing, done condition

architecture-enforcer (Opus)
  receives: spec + current layer map
  returns:  PASS (spec is safe) or violations the spec would introduce
            [if violations: adjust spec before proceeding]

refactor-executor (Haiku)
  receives: approved spec + files to touch
  returns:  refactored files — exactly what the spec said, nothing extra

code-reviewer (Opus)
  receives: diff of the refactor
  returns:  quality findings — logic errors, missed renames, broken references

/g-team review    ← always run before committing
```

**Example — extracting a service layer:**

```
spec-writer receives:
  "Extract database calls from UserController into UserRepository.
   Controller should call repository methods, not query DB directly.
   Do not change any public API endpoints or response shapes."

spec-writer returns:
  1. Create src/repositories/user.ts
     - Move: UserController.findById() → UserRepository.findById(id: string): Promise<User|null>
     - Move: UserController.create() → UserRepository.create(dto: CreateUserDto): Promise<User>
     - Move: UserController.update() → UserRepository.update(id, dto): Promise<User|null>
  2. Modify src/controllers/user.ts
     - Replace direct db calls with UserRepository method calls
     - Import UserRepository, remove db import
  3. Scope boundary: only these two files. No route changes. No schema changes.
  Done condition: all existing UserController tests pass unchanged.

architecture-enforcer receives: spec + layer map
architecture-enforcer returns: PASS — repository pattern is correct for this layer.

refactor-executor receives: spec
refactor-executor returns: src/repositories/user.ts created, src/controllers/user.ts updated.
  Report: 3 methods moved, 1 import added, 1 import removed. Nothing outside scope touched.
```
