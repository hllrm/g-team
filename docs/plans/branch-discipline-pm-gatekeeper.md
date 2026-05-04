# Plan: Branch Discipline + Project-Manager Gatekeeper

> Created: 2026-05-05

## Tasks

| # | Task | Scope | Done condition |
|---|------|-------|----------------|
| 1 | Branch discipline rule in G-RULES.md | `G-RULES.md` Section D | Section D contains naming convention (feat/fix/refactor slugs), MERGE READY on branch = merge/PR to main, main-only exception for hotfixes/docs |
| 2 | Branch output in workflow-checkpoint.sh | `.claude/hooks/workflow-checkpoint.sh` | Script outputs `Branch: <name>`; when on main prints `⚠  on main — non-trivial work should be on a feature branch` |
| 3 | Main-branch advisory in check-commit.sh | `hooks/check-commit.sh` | When commit + approved + on main → prints advisory to stderr, exits 0. Block without approval unchanged. |
| 4 | Sync workflow-checkpoint.sh template in g-team-init | `skills/g-team-init/SKILL.md` | Template block matches updated `.claude/hooks/workflow-checkpoint.sh` |
| 5 | Sync check-commit.sh template in g-team-init | `skills/g-team-init/SKILL.md` | Template block matches updated `hooks/check-commit.sh` |
| 6 | Project-manager challenge-gate role | `agents/project-manager.md` | Agent has challenge mode: 3 questions before accepting scope |
| 7 | g-team-plan dispatches PM challenge before task-decomposer | `skills/g-team-plan/SKILL.md` | Step 1 dispatches project-manager; developer must answer before task-decomposer fires |

## Wave Schedule

### Wave 1
- Task 1 — Branch discipline rule in G-RULES.md
- Task 2 — Branch output in workflow-checkpoint.sh
- Task 3 — Main-branch advisory in check-commit.sh
- Task 6 — Project-manager challenge-gate role

### Wave 2
- Task 4 — Sync workflow-checkpoint.sh template in g-team-init
- Task 7 — g-team-plan dispatches PM challenge

### Wave 3
- Task 5 — Sync check-commit.sh template in g-team-init

## Progress

| Wave | Status | Notes |
|------|--------|-------|
| 1 | complete | G-RULES.md, workflow-checkpoint.sh, check-commit.sh, project-manager.md |
| 2 | complete | g-team-init template sync, g-team-plan PM challenge step |
| 3 | complete | g-team-init check-commit sync, g-team-review test step, test-writer expanded |
