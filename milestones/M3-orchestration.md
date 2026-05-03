# M3 — Skills & Orchestration

## Goal
The four /g-team skills are implemented and working end-to-end: /g-team plan runs task-decomposer → wave-planner and presents a wave schedule; /g-team review runs review-orchestrator and returns an aggregated report; /g-team init scaffolds a new project correctly.

## Status
Goal defined. Will be fully specced when M2 closes.

## Scope additions (post-M2)

### Workflow enforcement
The master-orchestrates pattern must be enforced at the plugin level, not just described in agent prose:
- `hooks/hooks.json` — wire up hooks that intercept commits and require review sign-off
- Workflow contract: plan → implement → review → commit. Nothing gets committed without review agents having run and passed.

### /g-team init — CLAUDE.md G-rules injection
When `/g-team init` runs in a project, it must write a compact G-rules block into the project's `CLAUDE.md`. The G-rules encode the workflow contract in a form the main session loads at startup:
- Master session orchestrates: dispatches agents, collects results, checks outcomes
- Reviews gate commits: no commit without review-orchestrator sign-off
- Compact form — a few enforcing lines, not a wall of text
