---
name: g-help
description: Context-aware help. Reads current project state and tells you exactly where you are in the workflow and what to do next.
---

You are running the g-help skill. Follow every step below precisely.

## Step 1 — Announce

Output exactly:
> Using g-help to assess project state.

## Step 2 — Read project files

Attempt to read each of the following files from the current working directory. If a file is missing, note it as "not found" and continue — never error out.

1. `todo.md` — current tasks and handoff block
2. `docs/plans/` — use Glob to find the most recent plan file (e.g. `docs/plans/*.md`); if multiple exist, use the one with the latest modification time or highest sort order
3. `ROADMAP.md` — current milestone and status
4. `.claude/g-team-approved` — presence indicates the commit gate is open
5. `.claude/hooks/workflow-checkpoint.sh` — presence indicates workflow hooks are installed
6. `project_brief.md` — presence indicates the project has been onboarded or kicked off
7. Current git branch — run `git branch --show-current` via Bash (skip gracefully if git is unavailable)
8. `.claude/integration-tier` — active integration tier (default: `full`)
9. `.claude/voice-profile` — active voice profile (default: `dev`)
10. `.claude/telemetry-profile` — derived health profile from `/g-telemetry` (default: `stable`)
11. `docs/telemetry/` — Glob for most recent snapshot file (informational — shows date of last `/g-telemetry` run)
12. `docs/forecasts/` — Glob for most recent forecast file (informational — shows most recently forecast plan)
13. `docs/identity.md` — Read if present (informational — shows the project's last synthesised personality snapshot)

## Step 3 — Determine project name

Use the `name` field from `CLAUDE.md` if present, otherwise use the current directory name.

## Step 4 — Determine phase

Apply the following rules in order (first match wins):

| Condition | Phase |
|---|---|
| `CLAUDE.md` is missing OR has no G-Forge Rules block, AND `project_brief.md` is missing | Not initialized |
| `project_brief.md` is missing | Not initialized |
| `CLAUDE.md` exists but has no G-Forge Rules block | Not initialized |
| G-Forge Rules block exists, no plan file found in `docs/plans/` | Initialized |
| Plan file exists AND `.claude/g-team-approved` is absent AND `todo.md` shows tasks remaining | Execution in progress |
| Plan file exists AND `.claude/g-team-approved` is absent AND `todo.md` shows all tasks done | Review pending |
| Plan file exists AND `.claude/g-team-approved` is absent | Active plan |
| `.claude/g-team-approved` exists | Ready to merge |

Default to "Initialized" if none of the above conditions clearly match and the project appears set up.

**Next step mapping:**

- Not initialized (no project_brief.md) → suggest `/g-kickoff` (new project) or `/g-onboard` (existing repo)
- Not initialized (project_brief.md exists, no G-Forge Rules block) → suggest `/g-init`
- Initialized (no plan file) → suggest `/g-plan`
- Active plan → suggest `/g-execute` to dispatch waves
- Execution in progress → summarize remaining tasks from `todo.md` and suggest continuing or running `/g-review` if all tasks are done
- Review pending → suggest `/g-review`
- Ready to merge → suggest merging the branch or running `/g-review` if not yet reviewed

## Step 5 — Output structured status

Print the following block, filling in values from what you read. Omit the "Branch" line if git is unavailable.

```
## G-Forge Status

Project: [name]
Branch: [current git branch]

Phase: [phase]

What's active:
  - [milestone from ROADMAP.md, e.g. "M2: Workflow Engine — in progress"]
  - [plan file name if found, e.g. "docs/plans/wave-plan-2025-05-01.md"]
  - [wave info if detectable from plan file, e.g. "Wave 3 of 4"]
  - [count of remaining tasks from todo.md, e.g. "3 tasks remaining in todo.md"]
  - [workflow hooks: installed / not installed]
  - [commit gate: open / not set]
  - [project_brief.md: present / missing]

Configuration:
  - Tier:           [full / balanced / light] ([file present / using default])
  - Voice:          [dev / mid / eli5] ([file present / using default])
  - Health profile: [stable / cautious / defensive / recovery] ([from /g-telemetry])

Recent intelligence:
  - Last telemetry: [date of most recent docs/telemetry/*.md, or "never run — try /g-telemetry"]
  - Last forecast:  [most recent docs/forecasts/*.md slug, or "none — /g-forecast is auto-invoked by /g-plan"]
  - Identity:       [present (date of docs/identity.md) / not yet synthesised — try /g-identity]

Next step:
  [one clear action the developer should take right now, including the exact command to run]

All commands (grouped by purpose):

  Setup:
    /g-kickoff     — new project: interview → project_brief.md
    /g-onboard     — existing project: read repo → project_brief.md
    /g-init        — scaffold CLAUDE.md, commit gate, workflow hooks
    /g-specialize  — install stack architect agent + architecture rules

  Per-task loop (auto-triggered on `full` tier):
    /g-plan        — decompose task → wave schedule → approval
    /g-execute     — dispatch waves
    /g-review      — full review pipeline → MERGE READY or HOLD

  Intelligence:
    /g-patterns    — mine retros + todo-done for recurring failure patterns
    /g-forecast    — premortem + scope realism + token-cost band (auto in /g-plan)
    /g-telemetry   — 8 reliability metrics → health profile → adaptive orchestration
    /g-blast-radius — forward + reverse deps + per-file volatility for a change
    /g-identity    — narrative synthesis of the project's operational personality

  Configuration:
    /g-tier        — integration tier: full / balanced / light
    /g-voice       — voice profile: dev / mid / eli5

  Hygiene:
    /g-brief       — refresh project_brief.md as project evolves
    /g-status      — quick one-line state snapshot
    /g-doctor      — health check: hooks, settings, rules block
    /g-update      — realign all g-forge files to current plugin version
    /g-retro       — record session retrospective
    /g-adr         — capture an architectural decision record
    /g-help        — context-aware help (this skill)
    /g-listen      — Tier 3 listen mode for smoke testing
    /g-afk         — autonomous milestone executor (requires approved plan)

  Audit / refactor:
    /g-audit       — code quality audit (SOLID, smells, dead code, coverage)
    /g-optimize    — performance audit (complexity, N+1, re-render waste)
    /g-refactor    — guided refactor with spec + review gate
    /g-docs        — documentation audit and generation

  Skill development:
    /g-skill-design   — design a new g-team skill from scratch
    /g-skill-validate — validate a skill or agent against structural rules
```

## Rules

- Never error out. If any file is missing, treat it as "not set up yet" and note it gracefully in "What's active".
- Be concise. "What's active" bullets should be short facts, not prose.
- The "Next step" must be a single, actionable sentence ending with the exact command to run (e.g. "Run `/g-plan` to decompose your task into a wave schedule.").
- Do not invent state. Only report what you actually found in the files.
- Do not include `argument-hint` in any output or metadata.
