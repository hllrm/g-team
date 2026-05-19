---
description: G-Forge workflow commands. Subcommands: help, status, doctor, init, kickoff, onboard, brief, roadmap, plan, execute, review, afk, specialize, update, skill-design, skill-validate, patterns.
argument-hint: <help|status|doctor|init|kickoff|onboard|brief|roadmap|plan|execute|review|afk|specialize|update|skill-design|skill-validate|patterns> [args]
---

Route to the correct skill file based on the subcommand in $ARGUMENTS.

For each subcommand, use Glob to find the corresponding SKILL.md inside `~/.claude/plugins/cache/g-team/g-team/` and read it, then follow its instructions exactly.

- `help`       → `skills/g-help/SKILL.md`
- `status`     → `skills/g-status/SKILL.md`
- `doctor`     → `skills/g-doctor/SKILL.md`
- `init`       → `skills/g-init/SKILL.md`
- `kickoff`    → `skills/g-kickoff/SKILL.md`
- `onboard`    → `skills/g-onboard/SKILL.md`
- `brief`      → `skills/g-brief/SKILL.md`
- `roadmap`    → `skills/g-roadmap/SKILL.md`
- `plan`       → `skills/g-plan/SKILL.md`
- `execute`    → `skills/g-execute/SKILL.md`  (remaining args: $ARGUMENTS)
- `review`     → `skills/g-review/SKILL.md`
- `afk`        → `skills/g-afk/SKILL.md`
- `specialize` → `skills/g-specialize/SKILL.md`  (remaining args: $ARGUMENTS)
- `update`     → `skills/g-update/SKILL.md`
- `skill-design` → `skills/g-skill-design/SKILL.md`
- `skill-validate` → `skills/g-skill-validate/SKILL.md`  (remaining args: $ARGUMENTS)
- `patterns`   → `skills/g-patterns/SKILL.md`

If $ARGUMENTS is empty or unrecognized, list available subcommands:
  - `help` — show current project state and next recommended action
  - `status` — quick one-line workflow snapshot (milestone, plan, review gate)
  - `doctor` — validate project setup health (hooks, settings, CLAUDE.md, milestone alignment)
  - `init` — scaffold CLAUDE.md, ROADMAP.md, milestones/, todo.md, and commit hooks
  - `kickoff` — interview about goals and stack; produce project_brief.md
  - `onboard` — onboard onto an existing codebase; produce project_brief.md
  - `brief` — refresh project_brief.md as the project evolves
  - `roadmap` — intake features, cluster and sequence into milestones, write ROADMAP.md
  - `plan` — decompose request into atomic tasks and parallel wave schedule
  - `execute [wave]` — dispatch parallel agents per wave; optionally resume from a specific wave number
  - `review` — run full review pipeline; issues MERGE READY or HOLD
  - `afk` — autonomous milestone executor: runs all waves + review unattended, requires approved plan
  - `specialize [stack]` — auto-detect or apply a named stack profile
  - `update` — realign all g-team-managed files to the current plugin version
  - `skill-design` — design a new skill from scratch (SKILL.md, command file, router entry)
  - `skill-validate [name]` — validate a skill or agent against G-Forge structural rules
  - `patterns` — mine docs/retros/ and todo-done.md for recurring failure patterns; propose rule edits
