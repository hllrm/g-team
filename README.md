# G-Team

> Multi-agent Claude Code plugin — planned execution, production architecture, enforced review.

G-Team installs a structured development workflow into any Claude Code project: decompose tasks into parallel waves, implement with specialist agents, gate every commit behind a full review pipeline.

---

## Install

### Prerequisites

- **Claude Code** — desktop app, CLI, or IDE extension. [claude.ai/code](https://claude.ai/code)
- **Git** — required for commit enforcement hooks
- **Python 3** — used by the commit gate script (pre-installed on most systems)

### Install the plugin

#### Via CLI

`/plugin` is only available in the Claude Code CLI. Open a terminal and run `claude`, then:

```bash
/plugin marketplace add hllrm/g-team
/plugin install g-team
```

All 16 G-Team agents, 14 skills, and 45 stack profiles become available globally across all your projects.

#### Desktop app, VS Code, JetBrains

`/plugin` is not available in these interfaces. Use the CLI to install — the plugin is registered globally and will be available in all Claude Code interfaces once installed:

```bash
# In a terminal:
claude
/plugin marketplace add hllrm/g-team
/plugin install g-team
```

Then open the desktop app or IDE extension as normal — the agents and skills will be available.

#### Load per-session (without installing)

For development or one-off use, load directly via the `--plugin-dir` flag:

```bash
git clone https://github.com/hllrm/g-team.git
claude --plugin-dir ./g-team
```

This loads G-Team for that session only. Re-run with `--plugin-dir` each time, or use the CLI install above for permanent access.

### Verify

Type `/g-team` in any Claude Code session. You should see: `help`, `status`, `doctor`, `kickoff`, `onboard`, `init`, `brief`, `plan`, `execute`, `review`, `specialize`, `update`, `skill-design`, `skill-validate`.

### Set up a new project

Run these three commands in order inside your project directory:

```bash
/g-team kickoff     # interview → scope challenge → brief → project_brief.md
/g-team init        # scaffold CLAUDE.md (G-rules injected), G-RULES.md, ROADMAP.md, milestones/, commit gate
/g-team specialize  # detect stack → install architect agent + architecture rules
```

After `/g-team init`, `git commit` is gated — it will block until `/g-team review` issues MERGE READY.

### Add to an existing project

Run onboard first to read the repo and capture current state:

```bash
/g-team onboard     # read repo → present findings → interview → project_brief.md
/g-team init        # safe on existing projects — appends G-rules if CLAUDE.md exists, creates missing files
/g-team specialize  # reads project_brief.md and detects stack automatically
```

Or skip onboard if you already know your scope and don't need a project_brief.md:

```bash
/g-team init
/g-team specialize
```

### Uninstall

```bash
/plugin uninstall g-team
```

Removes the plugin globally. Per-project commit hooks (installed in `.claude/hooks/` and registered in `.claude/settings.json`) must be removed manually from each project.

---

## G-RULES.md

`/g-team init` installs `G-RULES.md` at the project root and references it from `CLAUDE.md` via `@G-RULES.md`. This gives Claude full session discipline without bloating `CLAUDE.md`.

G-RULES.md has six sections:

| Section | What it governs |
|---------|----------------|
| **A — Session Rules** | Model selection, planning discipline, token optimisation, delivery standards, Three-Strikes escalation |
| **B — G-Team Workflow** | Auto-trigger rules for plan/execute/review; wave execution; hard stops; subagent commit prohibition |
| **C — Agent Discipline** | HQ vs. agent boundaries; wave model; when to spawn vs. inline; agent prompt requirements; agent caps |
| **D — Code Quality** | Style (const/let/var), naming conventions, comments, error handling, testing standards, component structure, branch discipline |
| **E — Architecture Gate** | Mandatory plan-first sequence for non-trivial changes; import direction validation; state ownership; hard stops |
| **F — Design Patterns** | Universal principles and anti-patterns (see below) |

### Section F — Design Patterns

Section F encodes six universal principles: **composition over inheritance**, **explicit over implicit**, **YAGNI**, **fail-fast at boundaries**, **observer/event-driven**, and **state machine for discrete modes**. It also lists eight anti-patterns to refuse by default (god object, prop drilling, business logic in UI, mutable module-level state, premature abstraction, magic values, circular dependencies, catch-and-continue).

Stack-specific patterns — including object pooling rules for game-dev profiles and framework-specific idioms for web, mobile, and systems targets — live in `.claude/rules/architecture-<stack>.md`, installed by `/g-team specialize`.

---

## Workflow

```
New project:
/g-team kickoff     →   project_brief.md  (goals, scope, tech decisions)

Existing project:
/g-team onboard     →   project_brief.md  (current state + planned work)

Then for both:
/g-team init        →   scaffolded project + commit gate + workflow hooks
/g-team specialize  →   stack architect agent + architecture rules

Day-to-day (auto-triggered — no command needed):
/g-team plan        →   approved wave schedule  →  saved to docs/plans/
/g-team execute     →   parallel agent swarming, wave by wave
/g-team review      →   MERGE READY or HOLD  →  milestone tasks auto-closed
git commit          →   gate clears, sentinel removed

Project hygiene:
/g-team brief       →   refresh project_brief.md as project evolves
/g-team help        →   where am I + what to do next
/g-team status      →   fast state snapshot
/g-team doctor      →   verify hooks, settings, rules block, milestone alignment
/g-team update      →   pull latest G-Team rules into this project
```

Full orchestration pattern reference: [docs/orchestration-patterns.md](docs/orchestration-patterns.md)

---

## Commit Enforcement

Once `/g-team init` is run in a project, three hooks are installed:

**`workflow-checkpoint.sh`** (`UserPromptSubmit`) — fires on every message. Reports the current branch (warns if on `main`), the active plan file, current wave and total waves, and whether `.claude/g-team-approved` is set. Claude reads this and auto-triggers `/g-team plan`, `/g-team execute`, or `/g-team review` based on current state.

**`check-commit.sh`** (`PreToolUse`) — blocks `git commit` unless `.claude/g-team-approved` exists. Prints a non-blocking advisory when committing directly to `main` with approval.

**`post-commit-cleanup.sh`** (`PostToolUse`) — clears `.claude/g-team-approved` after a successful commit.

The sentinel is written by `/g-team review` only on a MERGE READY verdict, and removed automatically after each commit. Every commit goes through the full review pipeline — no exceptions. Subagents are prohibited from committing; HQ commits once after MERGE READY.

To bypass in an emergency (not recommended):

```bash
rm .claude/hooks/check-commit.sh   # removes the gate for this project
```

---

## Skills

| Skill | What it does |
|-------|-------------|
| `/g-team help` | Context-aware state reader — detects current phase and outputs next action + full command reference |
| `/g-team status` | Fast structured snapshot: milestone · active plan/wave · review gate · handoff line |
| `/g-team doctor` | 9-point health check: all 3 hooks installed, all hooks registered in settings.json, G-Team Rules block, G-RULES.md present and referenced, no stale sentinel — ✓/✗ with fix instructions |
| `/g-team kickoff` | Interview → scope challenge → stack deep dive → project_brief.md |
| `/g-team onboard` | Read existing repo → present findings → interview → optional architecture audit → project_brief.md |
| `/g-team brief` | Refresh project_brief.md incrementally — reads current state, targeted Q&A, no full re-onboard |
| `/g-team init` | Scaffold CLAUDE.md, G-RULES.md, ROADMAP.md, milestones/, commit enforcement hooks |
| `/g-team specialize [stack]` | Detect stack from brief + deps → install architect agent + rules |
| `/g-team plan` | project-manager challenge gate → task-decomposer → wave-planner → approval gate → saves plan to docs/plans/ |
| `/g-team execute [wave]` | Dispatch parallel agents per wave; hold boundary until each wave completes; resume from a specific wave |
| `/g-team review` | test suite → code-lead → full review pipeline → MERGE READY or HOLD → auto-closes milestone tasks |
| `/g-team update` | Realign all g-team-managed files (CLAUDE.md rules, G-RULES.md, agents, architecture rules, hooks) to the current plugin version |
| `/g-team skill-design` | Design a new g-team skill from scratch — requirements gathering, step drafting, SKILL.md + command file + router wiring |
| `/g-team skill-validate [name]` | Validate a skill or agent against structural rules — ✓/✗ checklist, VALID or NEEDS FIXES verdict |

---

## Agents

16 agents ship with every install. Full reference: [docs/agents.md](docs/agents.md)

| Agent | Tier | Role |
|-------|------|------|
| `task-decomposer` | Sonnet | Atomic task breakdown with done conditions |
| `wave-planner` | Sonnet | Parallel wave schedule from task list |
| `spec-writer` | Sonnet | Precise implementation specs for executor agents |
| `code-reviewer` | Opus | Code quality, logic errors, DRY violations |
| `security-auditor` | Opus | OWASP Top 10, injection, secrets, auth flaws |
| `architecture-enforcer` | Opus | Layer boundaries, import directions, SRP |
| `performance-auditor` | Sonnet | N+1 queries, O(n²) paths, hot-path issues |
| `debugger` | Sonnet | Root cause analysis, fix strategy |
| `error-detective` | Sonnet | Log and stack trace pattern analysis |
| `project-manager` | Sonnet | Feature challenge gate + end-to-end lifecycle coordination |
| `review-orchestrator` | Sonnet | Parallel review pipeline aggregation |
| `code-lead` | Opus | Technical sign-off, merge gate verdict |
| `test-writer` | Haiku | Unit, integration, and e2e tests from specs; fixed data only |
| `doc-writer` | Haiku | Inline docs explaining WHY not WHAT |
| `pr-writer` | Haiku | PR descriptions from git diff |
| `refactor-executor` | Haiku | Spec-exact refactoring, no scope creep |

---

## Stack Profiles

Installed per-project by `/g-team specialize`. Each profile adds a stack-specific architect agent and appends architecture rules to `CLAUDE.md`. Once installed, the agent is project-native — no plugin required at runtime.

45 profiles ship with the plugin. Auto-detected from your project's dependency files when you run `/g-team specialize`.

**Web Frontend**
`react` · `next-js` · `nuxt` · `vue-pinia` · `sveltekit` · `angular` · `astro` · `remix`

**Node / Go / Rust Backend**
`node-ts` · `express` · `nest-js` · `go-gin` · `go-fiber` · `rust-axum` · `hono` · `bun`

**Python / Ruby / PHP**
`fastapi` · `django` · `laravel` · `rails` · `python-textual` · `python-cli` · `python-ml` · `python-data`

**JVM / .NET**
`spring-boot` · `asp-net-core` · `kotlin-ktor` · `kotlin-android` · `phoenix-liveview` · `wpf-csharp` · `maui`

**Mobile / Desktop**
`react-native` · `flutter` · `swift-ios` · `electron` · `tauri` · `capacitor`

**Game Dev + Systems**
`unity` · `unreal` · `godot-gdscript` · `godot-csharp` · `cpp-cmake` · `rust-cli` · `c-embedded`

**Claude Code Plugin**
`claude-plugin` — architect agent + architecture rules for Claude Code plugin development (skill structure, command routing, agent format, hook design, manifest validation)

Game-dev profiles (`unity`, `unreal`, `godot-gdscript`, `godot-csharp`, `cpp-cmake`) include object pooling rules and state machine patterns aligned with Section F of G-RULES.md.

---

## Playbook

Quick reference for the most common workflows.

### Starting a new project

```
/g-team kickoff      Groups 1–4: problem → scope → stack surface → stack deep dive + integration map
                     Challenges each feature and tech choice honestly
                     Dispatches project-manager (scope) + code-lead (stack validation)
                     Produces project_brief.md with tech decisions table

/g-team init         Creates CLAUDE.md with G-rules, G-RULES.md, ROADMAP.md, milestones/M1.md, todo.md
                     Installs .claude/hooks/workflow-checkpoint.sh (UserPromptSubmit)
                               .claude/hooks/check-commit.sh (PreToolUse — commit gate)
                               .claude/hooks/post-commit-cleanup.sh (PostToolUse — sentinel cleanup)
                     Registers all three in .claude/settings.json

/g-team specialize   Reads project_brief.md → detects stacks → confirms → installs architect agents
```

### Onboarding an existing project

```
/g-team onboard      Reads the repo first: stack, structure, tests, entry points
                     Presents findings and asks you to confirm before continuing
                     Interviews: what's next, constraints, known fragile areas
                     Optional: dispatches code-lead for architecture audit
                     Produces project_brief.md with current state + planned work

/g-team init         Installs commit enforcement, injects G-rules into CLAUDE.md, installs G-RULES.md
/g-team specialize   Reads project_brief.md → installs architect agent + rules
```

### Where am I?

```
/g-team help         Reads project state (todo.md, ROADMAP.md, plan files, hooks)
                     Detects current phase and outputs one clear next action
                     + full command reference

/g-team status       Fast structured snapshot — no narrative, just facts:
                     Milestone · Active plan + wave · Review gate · Handoff line

/g-team doctor       9-point health check — all 3 hooks installed, all hooks wired in
                     settings.json, G-Team Rules block in CLAUDE.md, G-RULES.md
                     present and referenced, no stale sentinel
                     Reports ✓/✗ per check with a one-line fix instruction
```

### Planning a feature

`/g-team plan`, `/g-team execute`, and `/g-team review` are **auto-triggered** — Claude detects task complexity and initiates them without you typing the commands. The `workflow-checkpoint.sh` hook fires on every message and reports current state (including active wave progress); G-RULES.md tells Claude what to do with it.

You can still invoke them manually if needed:

```
/g-team plan         Step 1: project-manager challenges the feature request (3 questions,
                       one verdict — bug fixes and refactors skip this gate)
                     Dispatches task-decomposer → wave-planner
                     Presents wave schedule for approval
                     Saves approved plan to docs/plans/<feature-slug>.md
                     On approval: hands off to /g-team execute

/g-team execute      Dispatches all Wave 1 tasks in parallel, waits for completion
                     Then Wave 2, Wave 3, etc. — holds boundary between waves
                     Stops immediately on any BLOCKED signal
                     Resume a partial run: /g-team execute 2

/g-team review       Step 1: runs the test suite — failures block with HOLD immediately
                       No test suite? Must dispatch test-writer or explicitly override
                     Dispatches code-lead → review-orchestrator → parallel reviewers
                     Issues MERGE READY or HOLD with fix list
                     On MERGE READY: auto-closes completed milestone tasks in ROADMAP.md
```

### Keeping the brief current

```
/g-team brief        Refresh project_brief.md as the project evolves
                     Reads current ROADMAP.md, todo.md, recent git log
                     Asks at most 4 targeted questions — no full re-onboard
```

### Day-to-day commit flow

```
git checkout -b feat/<slug>   # branch before non-trivial work
[implement feature or fix]
/g-team review       → runs tests, then full pipeline → MERGE READY unlocks the gate
git commit -m "..."  → gate clears, sentinel auto-removed
git merge main       → or open a PR
git push
```

### Debugging a bug

```
1. Dispatch error-detective with the stack trace or log output
2. Dispatch debugger with error-detective's findings + relevant source files
3. Dispatch test-writer with debugger's fix strategy
4. Implement the fix
5. /g-team review → commit
```

### Refactoring safely

```
1. Dispatch spec-writer with the refactor description and scope boundary
2. Dispatch architecture-enforcer with the spec + layer map
3. Dispatch refactor-executor with the approved spec
4. Dispatch code-reviewer with the resulting diff
5. /g-team review → commit
```

### Common single-agent dispatches

| What you need | Agent | Give it |
|---------------|-------|---------|
| Write a PR description | `pr-writer` | `git diff` output |
| Find security issues | `security-auditor` | files to audit + data flow context |
| Write tests (unit/integration/e2e) | `test-writer` | implementation or spec + test framework |
| Root cause an error | `error-detective` | stack trace or log output |
| Write docs for a module | `doc-writer` | the file + any design intent notes |
| Check architecture violations | `architecture-enforcer` | diff + layer map |
| Break down a task | `task-decomposer` | feature description + constraints |
| Schedule parallel work | `wave-planner` | task list from task-decomposer |

---

## Roadmap

| Milestone | Status |
|-----------|--------|
| M1 — Foundation | ✅ Done |
| M2 — Agent Roster | ✅ Done |
| M3 — Skills & Orchestration | ✅ Done |
| M4 — Stack Profiles | ✅ Done |
| M5 — Publish | ✅ Done |
| M6 — Auto-trigger & Project Hygiene | ✅ Done |
| M7 — Correctness, Validation & Polish | ✅ Done |
| M8 — Deploy & Use (gaps, debug, improve) | 🚧 In progress |
