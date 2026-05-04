# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [0.3.1] — 2026-05-04

### Added

- `g-team-doctor` expanded from 7 to 9 checks: added `post-commit-cleanup.sh` hook check, `G-RULES.md` present check, `@G-RULES.md` referenced in `CLAUDE.md` check

### Fixed

- `g-team-update`: `post-commit-cleanup.sh` now created and registered if missing (previously skipped silently — pre-0.3.0 projects would never get it installed)
- `g-team-doctor` check 4 fix instruction: now correctly references `/g-team init` as well as `/g-team update`
- `g-team-doctor` check 5 fix instruction: corrected from "Run `/g-team update`" to "Run `/g-team init` or `/g-team update`"
- ROADMAP.md: updated to reflect M6-M8 milestones (was stale at M1-M5 only)

## [0.3.0] — 2026-05-04

### Added

- Section F — Design Patterns in `G-RULES.md`: 6 universal principles (composition over inheritance, explicit over implicit, YAGNI, fail-fast at boundaries, observer/event-driven, state machine for discrete modes) and 8 anti-patterns refused by default
- Object pooling and state machine architecture rules in all 5 game-dev profiles: `unity`, `godot-gdscript`, `godot-csharp`, `unreal`, `cpp-cmake`
- `G-RULES.md` now installed per-project by `/g-team init` (Step 2a) — `@G-RULES.md` reference added to `CLAUDE.md`
- `/g-team update` now refreshes per-project `G-RULES.md` from plugin (Step 3a)
- `/g-team doctor` — 7-point health check: hooks installed, all hooks registered in settings.json, G-Team Rules block present, no stale sentinel, milestone alignment

### Fixed

- `g-team-kickoff` Step 7: removed false claim that `/g-team init` auto-triggers plan/execute/review in sequence
- `g-team-review` Step 2: fixed stale path `docs/superpowers/plans/*.md` → `docs/plans/`
- `g-team-plan` Step 5: removed user-facing reference to `superpowers:dispatching-parallel-agents`
- `code-reviewer` agent: added Section F anti-patterns to "What to look for" (god object, prop drilling, business logic in UI, mutable state, premature abstraction, magic values, catch-and-continue)
- `architecture-enforcer` agent: added circular dependency detection and god object violation checks
- `go-fiber` architect agent filename collision with `go-gin` profile (renamed to `go-fiber-architect.md`)
- `g-team-update` Step 7: now verifies and adds UserPromptSubmit hook in settings.json when `workflow-checkpoint.sh` already exists
- `marketplace.json`: corrected agent and skill counts

### Changed

- README fully rewritten for 0.3.0: G-RULES.md section, Section F callout, game-dev profile notes, all 3 commit hooks documented, complete skills and agents tables

## [0.2.8] — 2026-05-04

### Fixed

- `g-team-execute` Step 4: now immediately invokes `/g-team review` via Glob+Read after all waves complete (was previously a print suggestion only)
- `g-team-execute` rules: explicit prohibition on instructing subagents to run `git commit`
- `g-team-execute` Step 2: wave auto-detection now reads Progress table in plan file (4 rules: absent/all-pending→Wave1, all-complete→stop, in-progress→confirm, mix→auto-resume)
- G-RULES.md Section B: added commit prohibition to hard stops; updated auto-trigger language

## [0.2.7] — 2026-05-04

### Added

- `/g-team doctor` skill — 7-point health check with ✓/✗ per check and fix instructions
- CHANGELOG.md — change history tracking from 0.1.0

### Fixed

- `g-team-help`: added missing "Review pending" workflow phase; 7th source is git branch; `/g-team help` added to All commands table
- `g-team-brief`: added missing announce line; guard check moved to top of Step 1
- `g-team-plan`: Progress table initial values corrected to `pending`

## [0.2.6] — 2026-05-04

### Added

- `/g-team help` — context-aware state reader; detects workflow phase and outputs next action + full command reference
- `/g-team status` — fast structured snapshot: milestone, active plan/wave, review gate, handoff line
- `/g-team brief` — incremental project_brief.md refresh; targeted Q&A, no full re-onboard
- Plan file format schema: approved plans saved to `docs/plans/<feature-slug>.md` with Tasks, Wave Schedule, and Progress tables
- `workflow-checkpoint.sh` now parses plan file to report current wave number and total waves
- g-team-review auto-closes completed milestone tasks and updates ROADMAP.md on MERGE READY

### Fixed

- g-team-kickoff: aligned auto-trigger language with rest of plugin

## [0.2.5] — 2026-05-04

### Added

- `workflow-checkpoint.sh` UserPromptSubmit hook: fires on every message, reports active plan and review state
- plan/execute/review now auto-triggered — Claude initiates them without user typing commands
- G-Rules compact block updated with auto-trigger language
- `/g-team update` installs `workflow-checkpoint.sh` on existing projects and registers UserPromptSubmit hook

## [0.2.4] — 2026-05-04

### Fixed

- Compact G-Rules block (injected by `/g-team init`) now explicitly names `/g-team-execute` and prohibits `superpowers:dispatching-parallel-agents`
- `g-team-execute` SKILL.md gains authority assertion declaring it the sole wave dispatcher

## [0.2.3] — 2026-05-03

### Added

- `/g-team execute` skill for wave-based agent swarming
- `/g-team update` skill to realign installed project files to current plugin version
- G-RULES.md now tracked in git (was previously gitignored)

### Fixed

- Removed all `Skill(...)` tool invocations from all command and skill files — were causing infinite "Launching skill" loops with no content loaded
- All commands now use Glob+Read pattern on SKILL.md directly
- Removed `argument-hint` from SKILL.md frontmatter files (was preventing skill content from loading)

## [0.2.1] — 2026-05-03

### Added

- `/g-team onboard` — fully rewritten to handle mature projects; maturity classification (mature/early-stage/greenfield); resolves existing `.claude/rules`, `.claude/agents`, `CLAUDE.md` conflicts before interviewing; targeted interview for mature projects

## [0.2.0] — 2026-05-03

### Added

- 44 stack profiles (up from 3): covers Web Frontend, Node/Go/Rust Backend, Python/Ruby/PHP, JVM/.NET, Mobile/Desktop, Game Dev & Systems
- Each profile has a stack-specific architect agent and architecture rules
- Auto-detection from dependency files (`package.json`, `requirements.txt`, `Cargo.toml`, etc.)

## [0.1.0] — initial release

### Added

- Core plugin structure: `commands/`, `skills/`, `agents/`, `profiles/`, `hooks/`
- 16 specialist agents: task-decomposer, wave-planner, spec-writer, code-reviewer, security-auditor, architecture-enforcer, performance-auditor, debugger, error-detective, project-manager, review-orchestrator, code-lead, test-writer, doc-writer, pr-writer, refactor-executor
- Skills: kickoff, init, specialize, plan, review
- Commit enforcement: PreToolUse hook blocks git commit without `.claude/g-team-approved` sentinel
- G-RULES.md: full session discipline rules (models, workflow, agent discipline, code quality, architecture gate, project tracking)
- 3 initial stack profiles: vue-pinia, node-ts, fastapi
