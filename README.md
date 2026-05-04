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

#### Via Claude Code (any interface)

The `/plugin` commands work in every Claude Code interface — CLI, desktop app, VS Code, and JetBrains. Open a Claude Code session and run:

```bash
/plugin marketplace add hllrm/g-team
/plugin install g-team
```

- **CLI:** open a terminal and run `claude`, then type the commands
- **Desktop app (Mac/Windows):** open Claude Code → start a conversation → type the commands
- **VS Code:** open the Command Palette → `Claude: Open Chat` → type the commands
- **JetBrains:** open the Claude tool window → type the commands

All 15 G-Team agents and 6 skills become available globally across all your projects.

#### Manual install (no plugin system)

If you prefer to install directly without the `/plugin` commands:

```bash
# 1. Clone the repo into Claude's plugin cache
#    Mac/Linux:
git clone https://github.com/hllrm/g-team.git \
  ~/.claude/plugins/cache/hllrm/g-team/0.1.0

#    Windows (PowerShell):
git clone https://github.com/hllrm/g-team.git `
  "$env:USERPROFILE\.claude\plugins\cache\hllrm\g-team\0.1.0"
```

Then register it by adding this entry to `~/.claude/plugins/installed_plugins.json` (Windows: `%USERPROFILE%\.claude\plugins\installed_plugins.json`) inside the `"plugins"` object:

```json
"g-team@hllrm": [
  {
    "scope": "user",
    "installPath": "/home/<you>/.claude/plugins/cache/hllrm/g-team/0.1.0",
    "version": "0.1.0",
    "installedAt": "<current ISO timestamp>",
    "lastUpdated": "<current ISO timestamp>",
    "gitCommitSha": ""
  }
]
```

Replace `installPath` with the absolute path where you cloned the repo (use backslashes on Windows). Restart Claude Code after editing the file.

To update manually: `git pull` inside the cloned directory.

### Verify

Type `/g-team` in any Claude Code session. You should see: `kickoff`, `onboard`, `init`, `plan`, `review`, `specialize`.

### Set up a new project

Run these three commands in order inside your project directory:

```bash
/g-team kickoff     # interview → scope challenge → brief → project_brief.md
/g-team init        # scaffold CLAUDE.md (G-rules injected), ROADMAP.md, milestones/, commit gate
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

## Playbook

Quick reference for the most common workflows.

### Starting a new project

```
/g-team kickoff      Groups 1–4: problem → scope → stack surface → stack deep dive + integration map
                     Challenges each feature and tech choice honestly
                     Dispatches project-manager (scope) + code-lead (stack validation)
                     Produces project_brief.md with tech decisions table

/g-team init         Creates CLAUDE.md with G-rules, ROADMAP.md, milestones/M1.md, todo.md
                     Installs .claude/hooks/check-commit.sh and registers it in .claude/settings.json

/g-team specialize   Reads project_brief.md → detects stacks → confirms → installs architect agents
```

### Onboarding an existing project

```
/g-team onboard      Reads the repo first: stack, structure, tests, entry points
                     Presents findings and asks you to confirm before continuing
                     Interviews: what's next, constraints, known fragile areas
                     Optional: dispatches code-lead for architecture audit
                     Produces project_brief.md with current state + planned work

/g-team init         Installs commit enforcement, injects G-rules into CLAUDE.md
/g-team specialize   Reads project_brief.md → installs architect agent + rules
```

### Planning a feature

```
/g-team plan         Dispatches task-decomposer → wave-planner
                     Presents wave schedule for approval
                     On approval: execute Wave 1 tasks in parallel, then Wave 2, etc.

/g-team review       Run after all waves complete, before committing
                     Dispatches code-lead → review-orchestrator → parallel reviewers
                     Issues MERGE READY or HOLD with fix list
```

### Day-to-day commit flow

```
[implement feature or fix]
/g-team review       → MERGE READY unlocks the gate
git commit -m "..."  → gate clears, sentinel auto-removed
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
| Write tests for a function | `test-writer` | function signature + test framework |
| Root cause an error | `error-detective` | stack trace or log output |
| Write docs for a module | `doc-writer` | the file + any design intent notes |
| Check architecture violations | `architecture-enforcer` | diff + layer map |
| Break down a task | `task-decomposer` | feature description + constraints |
| Schedule parallel work | `wave-planner` | task list from task-decomposer |

---

## Skills

| Skill | What it does |
|-------|-------------|
| `/g-team kickoff` | Interview → scope challenge → stack deep dive → project_brief.md |
| `/g-team onboard` | Read existing repo → present findings → interview → optional architecture audit → project_brief.md |
| `/g-team init` | Scaffold CLAUDE.md, ROADMAP.md, milestones/, commit enforcement hooks |
| `/g-team specialize [stack]` | Detect stack from brief + deps → install architect agent + rules |
| `/g-team plan` | task-decomposer → wave-planner → approval gate → wave execution |
| `/g-team review` | code-lead → full review pipeline → MERGE READY or HOLD |

---

## Agents

15 agents ship with every install. Full reference: [docs/agents.md](docs/agents.md)

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
| `project-manager` | Sonnet | End-to-end feature lifecycle coordination |
| `review-orchestrator` | Sonnet | Parallel review pipeline aggregation |
| `code-lead` | Opus | Technical sign-off, merge gate verdict |
| `test-writer` | Haiku | Unit tests from specs, fixed data only |
| `doc-writer` | Haiku | Inline docs explaining WHY not WHAT |
| `pr-writer` | Haiku | PR descriptions from git diff |
| `refactor-executor` | Haiku | Spec-exact refactoring, no scope creep |

---

## Stack Profiles

Installed per-project by `/g-team specialize`. Each profile adds a stack-specific architect agent and appends architecture rules to `CLAUDE.md`. Once installed, the agent is project-native — no plugin required.

| Profile | Agent | Stack |
|---------|-------|-------|
| `vue-pinia` | `vue-architect` | Vue 3, Pinia, Vite, TypeScript |
| `node-ts` | `node-architect` | Node.js, TypeScript, Express/Fastify |
| `fastapi` | `fastapi-architect` | FastAPI, Pydantic, SQLAlchemy, async Python |

Planned: `react`, `tauri`

Each architect agent knows its stack's layer map, import rules, and anti-patterns. Dispatch it during any review or planning task that touches stack-specific code.

---

## Commit Enforcement

Once `/g-team init` is run in a project, `git commit` is blocked unless `.claude/g-team-approved` exists.

- The sentinel is written by `/g-team review` only on a MERGE READY verdict
- It is automatically cleared after the commit by the PostToolUse hook
- This means every commit goes through the full review pipeline — no exceptions

To bypass in an emergency (not recommended):
```bash
rm .claude/hooks/check-commit.sh   # removes the gate for this project
```

---

## Workflow

```
New project:
/g-team kickoff     →   project_brief.md  (goals, scope, tech decisions)

Existing project:
/g-team onboard     →   project_brief.md  (current state + planned work)

Then for both:
/g-team init        →   scaffolded project + commit gate
/g-team specialize  →   stack architect agent + architecture rules
/g-team plan        →   approved wave schedule
execute waves       →   parallel agent implementation
/g-team review      →   MERGE READY or HOLD
git commit          →   gate clears, sentinel removed
```

Full orchestration pattern reference: [docs/orchestration-patterns.md](docs/orchestration-patterns.md)

---

## Roadmap

| Milestone | Status |
|-----------|--------|
| M1 — Foundation | ✅ Done |
| M2 — Agent Roster | ✅ Done |
| M3 — Skills & Orchestration | ✅ Done |
| M4 — Stack Profiles | ✅ Done |
| M5 — Publish | ✅ Done |
