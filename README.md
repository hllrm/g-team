# G-Forge

> Multi-agent Claude Code plugin — planned execution, production architecture, enforced review.

G-Forge installs a structured development workflow into any Claude Code project: decompose tasks into parallel waves, implement with specialist agents, gate every commit behind a full review pipeline.

---

## Why G-Forge

Most AI coding tools are built around a single idea: automate as much as possible and get the human out of the loop. The result is tools that are complex to configure, fragmented across a dozen commands, and optimised for the appearance of productivity — not for whether the project actually succeeds.

G-Forge is built on a different assumption: **the human is the most valuable part of the loop.** Claude handles the structured, repetitive, and cost-optimisable work. The decisions that determine whether a project succeeds — what to build, in what order, and whether it's actually done — stay with you.

That means:

- **Project management is a first-class concern.** `/g-roadmap` doesn't fill in a template — it challenges your feature list, narrates its grouping assumptions, justifies the milestone sequence, and plans version targets before writing a single line. `/g-kickoff` questions scope before it becomes a commitment. The plan approval gate means nothing executes until you've seen the full wave schedule and said yes.
- **Every merge decision requires human sign-off.** The commit gate is locked until `/g-review` issues MERGE READY. HOLD means fix everything listed, no partial merges. Tier 3 smoke testing is yours — Claude collects findings but never substitutes your judgment on whether the app actually works.
- **Token cost is optimised, not token count.** Haiku handles reads and searches, Sonnet implements, Opus reviews. The same work costs less because it lands on the right model tier. Structured planning eliminates the back-and-forth and rework cycles that burn expensive tokens without producing output.

The goal isn't to automate your project. It's to give it a better chance of succeeding.

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

All 16 G-Forge agents, 24 skills, 45 stack profiles, and 7 combo profiles become available globally across all your projects.

#### Desktop app, VS Code, JetBrains

`/plugin` is not available in these interfaces. Use the CLI to install — the plugin is registered globally and will be available in all Claude Code interfaces once installed:

```bash
# In a terminal:
claude
/plugin marketplace add hllrm/g-team
/plugin install g-team
```

Then open the desktop app or IDE extension as normal — the agents and skills will be available.

### Update the plugin

Run `/g-update` inside any project that uses G-Forge. It does everything in one pass:

1. Compares the installed cache version against GitHub
2. `git pull`s the plugin cache if behind
3. Syncs all project-level files (hooks, CLAUDE.md rules, G-RULES.md, architect agents, architecture rules) to the new version

G-Forge also checks for updates automatically. The `workflow-checkpoint.sh` hook fetches the latest version from GitHub once per day (background, zero latency) and surfaces a notice in every session until you update:

```
⚡ g-team update available: 0.4.4 → 0.5.0 — run /g-update to pull and sync
```

If `/g-update`'s git pull fails (cache is not a git clone), it will tell you to reinstall manually:

```bash
/plugin marketplace add hllrm/g-team
/plugin install g-team
```

#### Load per-session (without installing)

For development or one-off use, load directly via the `--plugin-dir` flag:

```bash
git clone https://github.com/hllrm/g-team.git
claude --plugin-dir ./g-team
```

This loads G-Forge for that session only. Re-run with `--plugin-dir` each time, or use the CLI install above for permanent access.

### Verify

Type `/g-help` in any Claude Code session. You should see the current project state and a full command reference. Commands follow the `/g-<name>` pattern: `/g-plan`, `/g-execute`, `/g-review`, `/g-afk`, `/g-init`, `/g-kickoff`, `/g-onboard`, `/g-specialize`, `/g-roadmap`, `/g-brief`, `/g-listen`, `/g-help`, `/g-status`, `/g-doctor`, `/g-update`, `/g-skill-design`, `/g-skill-validate`, `/g-audit`, `/g-optimize`, `/g-refactor`, `/g-docs`, `/g-adr`, `/g-retro`, `/g-patterns`.

### Set up a new project

Run these three commands in order inside your project directory:

```bash
/g-kickoff     # interview → scope challenge → brief → project_brief.md
/g-init        # scaffold CLAUDE.md (G-rules injected), G-RULES.md, milestones/, commit gate
/g-roadmap     # intake features → cluster → sequence → write ROADMAP.md
/g-specialize  # detect stack → install architect agent + architecture rules
```

After `/g-init`, `git commit` is gated — it will block until `/g-review` issues MERGE READY.

### Add to an existing project

Run onboard first to read the repo and capture current state:

```bash
/g-onboard     # read repo → present findings → interview → project_brief.md
/g-init        # safe on existing projects — appends G-rules if CLAUDE.md exists, creates missing files
/g-specialize  # reads project_brief.md and detects stack automatically
```

Or skip onboard if you already know your scope and don't need a project_brief.md:

```bash
/g-init
/g-specialize
```

### Uninstall

```bash
/plugin uninstall g-team
```

Removes the plugin globally. Per-project commit hooks (installed in `.claude/hooks/` and registered in `.claude/settings.json`) must be removed manually from each project.

---

## G-RULES.md

`/g-init` installs `G-RULES.md` at the project root and references it from `CLAUDE.md` via `@G-RULES.md`. This gives Claude full session discipline without bloating `CLAUDE.md`.

G-RULES.md has seven sections:

| Section | What it governs |
|---------|----------------|
| **A — Session Rules** | Model selection, planning discipline, token optimisation, delivery standards, Three-Strikes escalation |
| **B — G-Forge Workflow** | Project lifecycle (kickoff → roadmap → init → specialize); per-task auto-trigger loop (plan/execute/review); maintenance skills reference table; hard stops |
| **C — Agent Discipline** | HQ vs. agent boundaries; wave model; when to spawn vs. inline; agent prompt requirements; agent caps |
| **D — Code Quality** | Style (const/let/var), naming conventions, comments, error handling, testing standards, component structure, branch discipline, versioning & release flow |
| **E — Architecture Gate** | Mandatory plan-first sequence for non-trivial changes; import direction validation; state ownership; hard stops |
| **F — Design Patterns** | Universal principles and anti-patterns (see below) |
| **G — Testing Protocol** | Three-tier test model (automated gates / tooling-assisted / human-driven); QA panel integration and currency enforcement; Tier 3 listen-mode protocol |

### Section F — Design Patterns

Section F encodes six universal principles: **composition over inheritance**, **explicit over implicit**, **YAGNI**, **fail-fast at boundaries**, **observer/event-driven**, and **state machine for discrete modes**. It also lists eight anti-patterns to refuse by default (god object, prop drilling, business logic in UI, mutable module-level state, premature abstraction, magic values, circular dependencies, catch-and-continue).

Stack-specific patterns — including object pooling rules for game-dev profiles and framework-specific idioms for web, mobile, and systems targets — live in `.claude/rules/architecture-<stack>.md`, installed by `/g-specialize`.

---

## Workflow

```
New project:
/g-kickoff     →   project_brief.md  (goals, scope, tech decisions)

Existing project:
/g-onboard     →   project_brief.md  (current state + planned work)

Then for both:
/g-init        →   scaffolded project + commit gate + workflow hooks
/g-roadmap     →   features → milestones → ROADMAP.md
/g-specialize  →   stack architect agent + architecture rules

Day-to-day (auto-triggered — no command needed):
/g-plan        →   approved wave schedule  →  saved to docs/plans/
/g-execute     →   parallel agent swarming, wave by wave
/g-review      →   MERGE READY or HOLD  →  milestone tasks auto-closed → /g-retro auto-runs → /g-doctor every other milestone
git commit          →   gate clears, sentinel removed

Unattended execution (requires approved plan):
/g-afk         →   all waves + review, no check-ins  →  handoff report when done

Project hygiene:
/g-brief       →   refresh project_brief.md as project evolves
/g-help        →   where am I + what to do next
/g-status      →   fast state snapshot
/g-doctor      →   verify hooks, settings, rules block, milestone alignment
/g-update      →   pull latest G-Forge rules into this project
```

Full orchestration pattern reference: [docs/orchestration-patterns.md](docs/orchestration-patterns.md)

---

## Commit Enforcement

Once `/g-init` is run in a project, three hooks are installed:

**`workflow-checkpoint.sh`** (`UserPromptSubmit`) — fires on every message. Reports the current branch (warns if on `main`), active milestone context, review gate status, listen mode item count (from `.claude/tier3-active`), and any available plugin update. Claude reads this and auto-triggers `/g-plan`, `/g-execute`, or `/g-review` based on current state.

**`check-commit.sh`** (`PreToolUse`) — blocks `git commit` unless `.claude/g-team-approved` exists. Prints a non-blocking advisory when committing directly to `main` with approval.

**`post-commit-cleanup.sh`** (`PostToolUse`) — clears `.claude/g-team-approved` after a successful commit.

The sentinel is written by `/g-review` only on a MERGE READY verdict, and removed automatically after each commit. Every commit goes through the full review pipeline — no exceptions. Subagents are prohibited from committing; HQ commits once after MERGE READY.

To bypass in an emergency (not recommended):

```bash
rm .claude/hooks/check-commit.sh   # removes the gate for this project
```

---

## Skills

| Skill | What it does |
|-------|-------------|
| `/g-help` | Context-aware state reader — detects current phase and outputs next action + full command reference |
| `/g-status` | Fast structured snapshot: milestone · active plan/wave · review gate · handoff line |
| `/g-doctor` | 9-point health check: all 3 hooks installed, all hooks registered in settings.json, G-Forge Rules block, G-RULES.md present and referenced, no stale sentinel — ✓/✗ with fix instructions |
| `/g-kickoff` | Interview → scope challenge → stack deep dive → project_brief.md |
| `/g-onboard` | Read existing repo → present findings → interview → optional architecture audit → project_brief.md |
| `/g-roadmap` | Four-phase milestone planner: feature dump → cluster (narrated) → sequence with dependency + version justification → approve → ROADMAP.md. Assigns a target semver version to every milestone and writes a version plan. Auto-triggers on any feature idea or empty milestone list. |
| `/g-brief` | Refresh project_brief.md incrementally — reads current state, targeted Q&A, no full re-onboard |
| `/g-init` | Scaffold CLAUDE.md, G-RULES.md, ROADMAP.md, milestones/, commit enforcement hooks |
| `/g-specialize [stack]` | Detect stack from brief + deps → install architect agent + rules |
| `/g-plan` | QA scope prerequisite (compile docs/qa-scope/<milestone>.md) → project-manager challenge gate → task-decomposer → wave-planner → approval gate → saves plan to docs/plans/ |
| `/g-execute [wave]` | Dispatch parallel agents per wave; hold boundary until each wave completes; resume from a specific wave |
| `/g-review` | test suite → code-lead → full review pipeline → Tier 3 smoke test (listen mode) → MERGE READY or HOLD → auto-closes milestone tasks |
| `/g-update` | Pull latest plugin from GitHub, then realign all g-team-managed files (CLAUDE.md rules, G-RULES.md, agents, architecture rules, hooks) to the new version |
| `/g-afk` | Autonomous milestone executor — runs all pending waves + review unattended. Requires approved plan. Safety net blocks remote push, recursive delete, and publish commands. Structured cycle-break report on any stop. |
| `/g-listen` | Enter listen mode — collect notes, issues, or observations without acting; triage everything when you say "done" |
| `/g-skill-design` | Design a new g-team skill from scratch — requirements gathering, step drafting, SKILL.md + command file + router wiring |
| `/g-skill-validate [name]` | Validate a skill or agent against structural rules — ✓/✗ checklist, VALID or NEEDS FIXES verdict |
| `/g-retro` | Save a structured session retrospective to `docs/retros/YYYY-MM-DD-topic.md` — what was done, decisions made, patterns that worked/failed, and cold-start context for the next session |
| `/g-patterns` | Mine `docs/retros/` and `todo-done.md` for recurring failure patterns; bucket by frequency (isolated / emerging / systemic); propose concrete profile-rule edits for any ≥2-occurrence pattern with apply/defer/dismiss per suggestion |

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

Installed per-project by `/g-specialize`. Each profile adds a stack-specific architect agent and appends architecture rules to `CLAUDE.md`. Once installed, the agent is project-native — no plugin required at runtime.

45 profiles ship with the plugin. Auto-detected from your project's dependency files when you run `/g-specialize`.

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

### Combo Profiles

7 combo profiles are detected automatically by `/g-specialize` when your project uses two stacks that have emergent cross-stack patterns — patterns that aren't in either tool's docs alone.

| Combo | Required stacks | Patterns covered |
|-------|-----------------|-----------------|
| `electron-react` | electron + react | contextBridge API layer, IPC channel constants, cross-window state |
| `electron-vue-pinia` | electron + vue-pinia | contextBridge + Pinia IPC integration, cross-window state |
| `react-tauri` | react + tauri | `invoke()` typed API layer, Tauri event hooks in React, capability scoping |
| `tauri-vue-pinia` | tauri + vue-pinia | `invoke()` typed API layer, Pinia + Tauri event subscriptions, capability scoping |
| `astro-react` | astro + react | Island isolation, serializable prop contract, cross-island state via nanostores, React hydration directives |
| `astro-vue` | astro + vue-pinia | Island isolation, serializable prop contract, cross-island state via nanostores, Vue hydration directives |
| `astro-svelte` | astro + sveltekit | Island isolation, serializable prop contract, native Svelte store sharing across islands, hydration directives |

Combo profiles install rules only — no architect agent. Detected automatically; no explicit argument needed.

---

## Playbook

Quick reference for the most common workflows.

### Starting a new project

```
/g-kickoff      Groups 1–4: problem → scope → stack surface → stack deep dive + integration map
                     Challenges each feature and tech choice honestly
                     Dispatches project-manager (scope) + code-lead (stack validation)
                     Produces project_brief.md with tech decisions table

/g-init         Creates CLAUDE.md with G-rules, G-RULES.md, ROADMAP.md, milestones/M1.md, todo.md
                     Installs .claude/hooks/workflow-checkpoint.sh (UserPromptSubmit)
                               .claude/hooks/check-commit.sh (PreToolUse — commit gate)
                               .claude/hooks/post-commit-cleanup.sh (PostToolUse — sentinel cleanup)
                     Registers all three in .claude/settings.json

/g-specialize   Reads project_brief.md → detects stacks → confirms → installs architect agents
```

### Planning the roadmap

```
/g-roadmap      Feature dump: tell it everything you want to build, in any order
                     PM groups features into clusters and narrates why — common
                       surfaces, shared deps, release cohesion
                     Sequences clusters into milestones and explains every ordering
                       decision — what blocks what, where the MVP cut is
                     Four gated phases: dump → cluster → sequence → approve
                     Writes ROADMAP.md only after you type "approve"

                     Reads current version (plugin.json / package.json /
                       pyproject.toml / Cargo.toml) as the baseline
                     Assigns a target version to every milestone during
                       sequencing — minor for new capabilities, patch for
                       fixes, major for breaking changes
                     Buy-in gate shows the full version plan:
                       v[current] → v[M1] → v[M2] → ...
                     Writes **Version:** field to each milestone in ROADMAP.md

Auto-triggers:  — no ROADMAP.md exists in the project
                — no active (🔄) or unstarted (⬜) milestones in ROADMAP.md
                — any feature idea is mentioned in conversation
```

### Onboarding an existing project

```
/g-onboard      Reads the repo first: stack, structure, tests, entry points
                     Presents findings and asks you to confirm before continuing
                     Interviews: what's next, constraints, known fragile areas
                     Optional: dispatches code-lead for architecture audit
                     Produces project_brief.md with current state + planned work

/g-init         Installs commit enforcement, injects G-rules into CLAUDE.md, installs G-RULES.md
/g-specialize   Reads project_brief.md → installs architect agent + rules
```

### Where am I?

```
/g-help         Reads project state (todo.md, ROADMAP.md, plan files, hooks)
                     Detects current phase and outputs one clear next action
                     + full command reference

/g-status       Fast structured snapshot — no narrative, just facts:
                     Milestone · Active plan + wave · Review gate · Handoff line

/g-doctor       9-point health check — all 3 hooks installed, all hooks wired in
                     settings.json, G-Forge Rules block in CLAUDE.md, G-RULES.md
                     present and referenced, no stale sentinel
                     Reports ✓/✗ per check with a one-line fix instruction
```

### Planning a feature

`/g-plan`, `/g-execute`, and `/g-review` are **auto-triggered** — Claude detects task complexity and initiates them without you typing the commands. The `workflow-checkpoint.sh` hook fires on every message and reports current state (including active wave progress); G-RULES.md tells Claude what to do with it.

You can still invoke them manually if needed:

```
/g-plan         Step 0: QA scope prerequisite — confirm or compile
                       docs/qa-scope/<milestone>.md (Tier 3 DoD for the milestone)
                     Step 1: project-manager challenges the feature request (3 questions,
                       one verdict — bug fixes and refactors skip this gate)
                     Dispatches task-decomposer → wave-planner
                     Presents wave schedule for approval
                     Saves approved plan to docs/plans/<feature-slug>.md
                     On approval: hands off to /g-execute

/g-execute      Dispatches all Wave 1 tasks in parallel, waits for completion
                     Then Wave 2, Wave 3, etc. — holds boundary between waves
                     Stops immediately on any BLOCKED signal
                     Resume a partial run: /g-execute 2

/g-review       Step 1: runs the test suite — failures block with HOLD immediately
                       No test suite? Must dispatch test-writer or explicitly override
                     Dispatches code-lead → review-orchestrator → parallel reviewers
                     On MERGE READY: enters Tier 3 listen mode — prompts smoke test
                       against QA panel; collects bug reports; triages after "done this round"
                       Repeats until a clean round, then writes sentinel
                     Issues MERGE READY or HOLD with fix list
                     On MERGE READY: auto-closes completed milestone tasks in ROADMAP.md
```

### Keeping the brief current

```
/g-brief        Refresh project_brief.md as the project evolves
                     Reads current ROADMAP.md, todo.md, recent git log
                     Asks at most 4 targeted questions — no full re-onboard
```

### Going AFK — unattended milestone execution

```
/g-afk          Pre-checks: approved plan must exist in docs/plans/
                     Configures permissions.allow (no tool prompts) +
                       permissions.deny (safety net):
                       blocks git push, rm -rf, all publish commands,
                       and writes outside the project folder
                     One final confirmation, then goes heads-down:
                       executes all pending waves in sequence
                       runs /g-review automatically after the last wave
                     Only stops for: BLOCKED task or safety violation
                     Both produce a structured cycle-break report:
                       what completed · what was written · exact violation ·
                       two resume options
                     Ends with full handoff: verdict · Tier 3 test plan ·
                       open items

Tip: for fully unattended mode (no prompts at all), start the session with:
  claude --dangerously-skip-permissions
then run /g-afk
```

### Day-to-day commit flow

```
git checkout -b feat/<slug>   # branch before non-trivial work
[implement feature or fix]
/g-review       → runs tests, then full pipeline → MERGE READY unlocks the gate
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
5. /g-review → commit
```

### Refactoring safely

```
1. Dispatch spec-writer with the refactor description and scope boundary
2. Dispatch architecture-enforcer with the spec + layer map
3. Dispatch refactor-executor with the approved spec
4. Dispatch code-reviewer with the resulting diff
5. /g-review → commit
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
| M8 — Deploy & Use | ✅ Done |
| M9 — Intelligence Foundation | ✅ Done |
| M10 — Organizational Learning Loop | ✅ Done |
| M11 — Planning Intelligence | ⬜ Not started |
| M12 — Reliability & Adaptive Systems | ⬜ Not started |
| M13 — Profile Additions | ⬜ Not started |
| M14 — Advanced Production Modeling | ⬜ Not started |
| M15 — Hook / Behavioral Integration Pass | ⬜ Not started |
