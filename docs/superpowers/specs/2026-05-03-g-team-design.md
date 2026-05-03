# G-Team — Design Spec

**Date:** 2026-05-03  
**Status:** Approved — ready for implementation planning  
**Author:** Gianmarco Palma

---

## 1. What Is G-Team

G-Team is a Claude Code plugin that provides a managed multi-agent system focused on code quality, production-grade architecture, and planned execution. It is a GitHub-hosted plugin installable via Claude Code's plugin marketplace in one line.

**Personal-first, open-source later.** Built as the author's own Claude Code environment, designed as a reference implementation worth publishing.

**Not a ruleset. A system.** G-Sharp's G-Rules enforced discipline through mandate (176-line document you had to remember). G-Team encodes the same philosophy into agent design — the system behaves correctly by construction, not by convention.

---

## 2. Design Principles

- **One agent, one mandate.** Every agent has a single, narrow job. No swiss-army agents.
- **Model by task nature.** Opus for critical judgment (review, security, architecture). Sonnet for complex reasoning and orchestration. Haiku for deterministic execution (generate from spec, write tests, run ops). Never escalation-based — the right model is assigned upfront.
- **Orchestrators never execute.** `dev-orchestrator` and `review-orchestrator` dispatch and integrate. They touch no files themselves.
- **Sonnet/Opus reasons → Haiku executes.** Every workflow chains a reasoning agent producing a spec, then Haiku agents consuming it.
- **Output contracts.** Every agent returns: summary + `file:line` refs. Never raw file dumps. Always includes a verifiable done condition.
- **Scope discipline.** Agents flag adjacent issues, never act on them. Only touch what they were asked.
- **Specialization on demand.** Core agents are domain-agnostic. `/g-team specialize` detects the project stack and writes stack-specific agents natively into `.claude/agents/` — after that they are project-native, not plugin-dependent.

---

## 3. Repository Structure

```
g-team/
├── .claude-plugin/
│   └── plugin.json                  # Plugin manifest
├── agents/                          # 15 universal agents — always installed
│   ├── task-decomposer.md
│   ├── wave-planner.md
│   ├── spec-writer.md
│   ├── code-reviewer.md
│   ├── architecture-enforcer.md
│   ├── security-auditor.md
│   ├── performance-auditor.md
│   ├── debugger.md
│   ├── error-detective.md
│   ├── test-writer.md
│   ├── pr-writer.md
│   ├── doc-writer.md
│   ├── refactor-executor.md
│   ├── dev-orchestrator.md
│   └── review-orchestrator.md
├── skills/
│   ├── g-team-init/SKILL.md         # /g-team init
│   ├── g-team-plan/SKILL.md         # /g-team plan
│   ├── g-team-review/SKILL.md       # /g-team review
│   └── g-team-specialize/SKILL.md   # /g-team specialize
├── profiles/                        # Stack profiles — written into project on specialize
│   ├── vue-pinia/
│   │   ├── agents/vue-architect.md
│   │   └── rules/architecture.md
│   ├── react/
│   │   ├── agents/react-architect.md
│   │   └── rules/architecture.md
│   ├── node-ts/
│   │   ├── agents/node-architect.md
│   │   └── rules/architecture.md
│   ├── fastapi/
│   │   ├── agents/fastapi-architect.md
│   │   └── rules/architecture.md
│   └── tauri/
│       ├── agents/tauri-architect.md
│       └── rules/architecture.md
├── hooks/
│   └── hooks.json                   # SubagentStart/Stop stubs
├── docs/
│   ├── agents.md                    # Agent reference + model rationale
│   └── orchestration-patterns.md   # Workflow pattern reference
├── milestones/
│   ├── M1-foundation.md             # Fully specced
│   ├── M2-agent-roster.md           # Fully specced
│   ├── M3-orchestration.md          # Goal defined
│   ├── M4-profiles.md               # Goal defined
│   └── M5-publish.md                # Goal defined
├── ROADMAP.md                       # Project dashboard — human-controlled
└── README.md
```

---

## 4. Plugin Manifest

**`.claude-plugin/plugin.json`**

```json
{
  "name": "g-team",
  "version": "0.1.0",
  "description": "Specialized multi-agent system for code quality, production architecture, and planned execution",
  "repository": "https://github.com/gianmarco-palma/g-team",
  "license": "MIT",
  "agents": "./agents/",
  "skills": "./skills/",
  "hooks": "./hooks/hooks.json"
}
```

**Install:**
```bash
/plugin marketplace add gianmarco-palma/g-team
/plugin install g-team
```

---

## 5. Agent Roster

### Planning (Sonnet)

| Agent | Mandate |
|---|---|
| `task-decomposer` | Breaks a request into atomic, verifiable tasks. Each task includes: what to do, what file(s) to touch, and a done condition. |
| `wave-planner` | Reads a task list. Classifies each as independent / dependent / serial-by-file. Outputs a wave schedule: Wave 1 = all parallel starters, Wave 2+ = unblocked by prior wave. |
| `spec-writer` | Produces an implementation spec from a brief. Precise enough that a Haiku agent can execute it without judgment calls. Includes: inputs, outputs, constraints, file paths. |

### Quality (Opus)

| Agent | Mandate |
|---|---|
| `code-reviewer` | Reviews code for logic errors, code smells, DRY violations, edge cases, and production reliability. Does not fix — reports with `file:line` refs and severity. |
| `architecture-enforcer` | Validates layer boundary integrity, import directions, separation of concerns, and SRP. Cites violations by file:line. Does not fix. |
| `security-auditor` | Audits for OWASP Top 10, injection vectors, secrets exposure, auth flaws, insecure dependencies. Reports findings with severity and remediation guidance. |

### Reasoning (Sonnet)

| Agent | Mandate |
|---|---|
| `performance-auditor` | Flags algorithmic complexity issues (O(n²) on critical paths), N+1 queries, unnecessary re-renders, and expensive computations in hot paths. |
| `debugger` | Given a failing test or bug report: reproduces the issue, traces the root cause, proposes a fix strategy. Does not implement the fix. |
| `error-detective` | Parses logs, stack traces, and error output. Identifies patterns, narrows down to probable root causes, distinguishes symptom from cause. |

### Execution (Haiku)

| Agent | Mandate |
|---|---|
| `test-writer` | Writes unit tests given a function signature or spec. Fixed data only — no `Date.now()` or random values. Tests happy path + boundary + error cases. |
| `pr-writer` | Generates a PR description from `git diff`. Format: summary, what changed, why, test plan. |
| `doc-writer` | Writes inline documentation and README sections from code. Explains WHY not WHAT. |
| `refactor-executor` | Executes a written refactor spec exactly. No scope creep, no judgment calls, no adjacent improvements. |

### Orchestration (Sonnet)

| Agent | Mandate |
|---|---|
| `dev-orchestrator` | Coordinates the full feature development pipeline: plan → spec → implement → test → review → PR. Dispatches to specialist agents per phase. Touches no files itself. |
| `review-orchestrator` | Coordinates the full review pipeline: code review + architecture + security + performance in parallel. Aggregates findings into a single report. Touches no files itself. |

---

## 6. Agent Frontmatter Schema

Every agent file follows this format:

```markdown
---
name: code-reviewer
description: Reviews code for logic errors, code smells, DRY violations, and edge cases. Use when changes are ready for quality review before merge.
model: opus
tools: Read, Glob, Grep
---

[system prompt body]
```

**Required fields:** `name`, `description`, `model`  
**Optional:** `tools` (omit to inherit all), `disallowedTools`, `permissionMode`, `color`

**Model values:** `opus` | `sonnet` | `haiku` | full model ID

---

## 7. Orchestration Patterns

### Pattern 1 — Feature Build (`/g-team plan`)

```
task-decomposer (Sonnet)     → atomic task list with done conditions
wave-planner (Sonnet)        → dependency graph → wave schedule
spec-writer (Sonnet)         → implementation spec per component
  ↓ Wave 1 (parallel)
[stack profile agents or HQ] → implement per spec
  ↓ Wave 2 (parallel)
test-writer (Haiku)          → unit tests from spec
doc-writer (Haiku)           → inline docs
  ↓ Wave 3
review-orchestrator (Sonnet) → full review pipeline
pr-writer (Haiku)            → PR description
```

### Pattern 2 — Full Review (`/g-team review`)

```
review-orchestrator (Sonnet)
  ↓ parallel
code-reviewer (Opus) + security-auditor (Opus) + performance-auditor (Sonnet)
  ↓ conditional
architecture-enforcer (Opus) [if layer-boundary files were touched]
```

### Pattern 3 — Debug

```
error-detective (Sonnet)  → parse logs, identify pattern, narrow root cause
  ↓
debugger (Sonnet)         → reproduce + fix strategy
  ↓
test-writer (Haiku)       → regression test for the bug class
```

### Pattern 4 — Planned Refactor

```
spec-writer (Sonnet)         → refactor spec with explicit scope boundary
  ↓
architecture-enforcer (Opus) → validate it doesn't break layer rules
  ↓
refactor-executor (Haiku)    → execute spec exactly, nothing extra
  ↓
code-reviewer (Opus)         → confirm result quality
```

---

## 8. Commands (`/g-team`)

### `/g-team init`
Scaffolds a new project with:
- `CLAUDE.md` template (stack TBD, filled in after specialize)
- `ROADMAP.md` with milestone table skeleton
- `milestones/` directory with M1 template

### `/g-team plan`
Runs `task-decomposer` → `wave-planner` on the current request. Outputs a wave schedule in the conversation. User reviews and approves before execution begins.

### `/g-team review`
Runs `review-orchestrator` → parallel review pipeline on the current branch diff. Returns an aggregated findings report with severity, file:line refs, and recommended actions.

### `/g-team specialize [stack]`
1. If no arg: reads `package.json`, `Cargo.toml`, `requirements.txt`, `pyproject.toml`, `go.mod` to detect stack
2. Presents: "Detected Vue 3 + Pinia + Tauri. Apply `vue-pinia` + `tauri` profiles? (y/n)"
3. On confirm: copies `profiles/{stack}/agents/*.md` → `.claude/agents/`
4. Appends `profiles/{stack}/rules/architecture.md` content to project `CLAUDE.md`
5. Stack agents are now native to that project — independent of the plugin

**Supported profiles at launch:** `vue-pinia`, `react`, `node-ts`, `fastapi`, `tauri`

---

## 9. Stack Profiles

Each profile lives in `profiles/{stack}/` and contains:

```
profiles/vue-pinia/
├── agents/
│   └── vue-architect.md     # Sonnet — Vue 3 + Pinia layer rules, SFC patterns
└── rules/
    └── architecture.md      # Layer map, import rules, store ownership rules
```

Profile agents are stack-specific specialists (e.g., `vue-architect` knows Vue 3 Composition API, Pinia store patterns, SFC conventions). They are written into the target project by `/g-team specialize` — after that they live in `.claude/agents/` and require no plugin to function.

**M4 launch profiles:** vue-pinia, node-ts, fastapi  
**Planned (post-M4):** react, tauri, django, rails, svelte, flutter

---

## 10. Project Tracking

### `ROADMAP.md` — Project Dashboard

The user's primary interface to project state. Updated by humans. Agents may propose changes, never write directly.

```markdown
# G-Team

> Multi-agent Claude Code plugin — code quality, production architecture, planned execution.

---

## Current: M1 — Foundation  🟡 In Progress

Repo scaffold, plugin manifest, agent skeleton, hooks stub.

→ [milestones/M1-foundation.md](milestones/M1-foundation.md)

---

## Milestones

| # | Milestone | Goal | Status |
|---|---|---|---|
| M1 | Foundation | Repo, plugin.json, agents/ skeleton, skills/ scaffold, hooks | 🟡 In Progress |
| M2 | Agent Roster | 15 agents with system prompts, model tiers, output contracts | ⬜ Planned |
| M3 | Skills & Orchestration | /g-team plan, review, init, specialize wired and tested | ⬜ Goal defined |
| M4 | Stack Profiles | /g-team specialize + vue-pinia, node-ts, fastapi profiles | ⬜ Goal defined |
| M5 | Publish | README, docs/agents.md, marketplace listing | ⬜ Goal defined |

---

## Backlog
- [ ] tauri profile
- [ ] react profile  
- [ ] dependency-auditor agent
- [ ] /g-team health — project-level audit snapshot
```

### `milestones/*.md` — Agent Work Orders

Each milestone file is technically precise: file paths, done conditions, task list. Agents execute against these. Two milestones are fully specced at any time; the rest hold goal definitions until the preceding milestone closes.

**Fully specced format:**
```markdown
# M1 — Foundation

## Goal
Scaffolded repo with valid plugin structure that loads in Claude Code.

## Done condition
`/plugin install g-team` succeeds in a test project. All 15 agent files and 4 skill directories present.

## Tasks
- [ ] Init git repo, .gitignore
- [ ] Write .claude-plugin/plugin.json
- [ ] Create agents/ with 15 placeholder .md files (correct frontmatter, empty body)
- [ ] Create skills/ with 4 directories, each with empty SKILL.md
- [ ] Write hooks/hooks.json with SubagentStart/Stop stubs
- [ ] Create profiles/ with 5 stack directories (empty)
- [ ] Write ROADMAP.md
- [ ] Write milestones/M1-foundation.md and M2-agent-roster.md (fully specced)
- [ ] Write milestones/M3 through M5 (goal defined only)
- [ ] Validate plugin loads
```

---

## 11. G-Rules → G-Team Mapping

G-Sharp's G-RULES.md enforced discipline through a 176-line mandate. G-Team encodes the same philosophy into agent design.

| G-Rules concept | G-Team equivalent |
|---|---|
| Model selection rules | Model locked in agent frontmatter — enforced structurally |
| Wave model + dependency graph | `wave-planner` — produces this automatically on every plan |
| Context hygiene (file:line refs, no dumps) | Output contract baked into every agent's system prompt |
| Three-strikes mechanism | `debugger` + `error-detective` agents replace patch-looping |
| Architecture gate | `architecture-enforcer` — runs in every review pipeline |
| Parallel-first | `wave-planner` output format always produces parallel groups |
| todo.md tracking | Replaced by ROADMAP.md dashboard + milestone specs |

---

## 12. Milestones Summary

| Milestone | Deliverables |
|---|---|
| **M1 — Foundation** | git repo, plugin.json, 15 agent stubs, 4 skill dirs, hooks stub, ROADMAP.md, milestone files |
| **M2 — Agent Roster** | Full system prompts for all 15 agents, output contracts, model tiers validated |
| **M3 — Skills & Orchestration** | 4 SKILL.md files implemented, orchestration patterns wired, end-to-end `/g-team plan` + `/g-team review` working |
| **M4 — Stack Profiles** | `/g-team specialize` implemented, 3 launch profiles complete (vue-pinia, node-ts, fastapi) |
| **M5 — Publish** | README (generated by `doc-writer` from docs/agents.md + orchestration-patterns.md — public-facing: install guide, agent reference, profile guide, orchestration patterns), marketplace listing |

---

## 13. What This Is Not

- Not a fork of wshobson/agents — informed by it, not derived from it
- Not a mandate system — agents enforce quality by design, not by rules you must remember
- Not a monolith — install one plugin, specialize per project, profiles become project-native
- Not gamified UI — dropped from scope; focus is the agent system itself
