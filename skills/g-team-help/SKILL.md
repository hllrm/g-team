---
name: g-team-help
description: Context-aware help. Reads current project state and tells you exactly where you are in the workflow and what to do next.
---

You are running the g-team-help skill. Follow every step below precisely.

## Step 1 — Announce

Output exactly:
> Using g-team-help to assess project state.

## Step 2 — Read project files

Attempt to read each of the following files from the current working directory. If a file is missing, note it as "not found" and continue — never error out.

1. `todo.md` — current tasks and handoff block
2. `docs/plans/` — use Glob to find the most recent plan file (e.g. `docs/plans/*.md`); if multiple exist, use the one with the latest modification time or highest sort order
3. `ROADMAP.md` — current milestone and status
4. `.claude/g-team-approved` — presence indicates the commit gate is open
5. `.claude/hooks/workflow-checkpoint.sh` — presence indicates workflow hooks are installed
6. `project_brief.md` — presence indicates the project has been onboarded or kicked off
7. Current git branch — run `git branch --show-current` via Bash (skip gracefully if git is unavailable)

## Step 3 — Determine project name

Use the `name` field from `CLAUDE.md` if present, otherwise use the current directory name.

## Step 4 — Determine phase

Apply the following rules in order (first match wins):

| Condition | Phase |
|---|---|
| `CLAUDE.md` is missing OR has no G-Team Rules block, AND `project_brief.md` is missing | Not initialized |
| `project_brief.md` is missing | Not initialized |
| `CLAUDE.md` exists but has no G-Team Rules block | Not initialized |
| G-Team Rules block exists, no plan file found in `docs/plans/` | Initialized |
| Plan file exists AND `.claude/g-team-approved` is absent AND `todo.md` shows tasks remaining | Execution in progress |
| Plan file exists AND `.claude/g-team-approved` is absent AND `todo.md` shows all tasks done | Review pending |
| Plan file exists AND `.claude/g-team-approved` is absent | Active plan |
| `.claude/g-team-approved` exists | Ready to merge |

Default to "Initialized" if none of the above conditions clearly match and the project appears set up.

**Next step mapping:**

- Not initialized (no project_brief.md) → suggest `/g-team kickoff` (new project) or `/g-team onboard` (existing repo)
- Not initialized (project_brief.md exists, no G-Team Rules block) → suggest `/g-team init`
- Initialized (no plan file) → suggest `/g-team plan`
- Active plan → suggest `/g-team execute` to dispatch waves
- Execution in progress → summarize remaining tasks from `todo.md` and suggest continuing or running `/g-team review` if all tasks are done
- Review pending → suggest `/g-team review`
- Ready to merge → suggest merging the branch or running `/g-team review` if not yet reviewed

## Step 5 — Output structured status

Print the following block, filling in values from what you read. Omit the "Branch" line if git is unavailable.

```
## G-Team Status

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

Next step:
  [one clear action the developer should take right now, including the exact command to run]

All commands:
  /g-team kickoff     — new project: interview → project_brief.md
  /g-team onboard     — existing project: read repo → project_brief.md
  /g-team init        — scaffold CLAUDE.md, commit gate, workflow hooks
  /g-team specialize  — install stack architect agent + architecture rules
  /g-team plan        — decompose task → wave schedule → approval
  /g-team execute     — dispatch waves (auto-triggered after plan approval)
  /g-team review      — full review pipeline → MERGE READY or HOLD
  /g-team brief       — refresh project_brief.md as project evolves
  /g-team status      — quick one-line state snapshot
  /g-team update      — realign all g-team files to current plugin version
  /g-team help        — context-aware help: assess project state and next step
```

## Rules

- Never error out. If any file is missing, treat it as "not set up yet" and note it gracefully in "What's active".
- Be concise. "What's active" bullets should be short facts, not prose.
- The "Next step" must be a single, actionable sentence ending with the exact command to run (e.g. "Run `/g-team plan` to decompose your task into a wave schedule.").
- Do not invent state. Only report what you actually found in the files.
- Do not include `argument-hint` in any output or metadata.
