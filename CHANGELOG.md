# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

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
