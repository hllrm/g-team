---
description: G-Team workflow commands. Subcommands: help, status, doctor, init, kickoff, onboard, brief, plan, execute, review, specialize, update, skill-design, skill-validate.
argument-hint: <help|status|doctor|init|kickoff|onboard|brief|plan|execute|review|specialize|update|skill-design|skill-validate> [args]
---

Route to the correct skill file based on the subcommand in $ARGUMENTS.

For each subcommand, use Glob to find the corresponding SKILL.md inside `~/.claude/plugins/cache/g-team/g-team/` and read it, then follow its instructions exactly.

- `help`       → `skills/g-team-help/SKILL.md`
- `status`     → `skills/g-team-status/SKILL.md`
- `doctor`     → `skills/g-team-doctor/SKILL.md`
- `init`       → `skills/g-team-init/SKILL.md`
- `kickoff`    → `skills/g-team-kickoff/SKILL.md`
- `onboard`    → `skills/g-team-onboard/SKILL.md`
- `brief`      → `skills/g-team-brief/SKILL.md`
- `plan`       → `skills/g-team-plan/SKILL.md`
- `execute`    → `skills/g-team-execute/SKILL.md`  (remaining args: $ARGUMENTS)
- `review`     → `skills/g-team-review/SKILL.md`
- `specialize` → `skills/g-team-specialize/SKILL.md`  (remaining args: $ARGUMENTS)
- `update`     → `skills/g-team-update/SKILL.md`
- `skill-design` → `skills/g-team-skill-design/SKILL.md`
- `skill-validate` → `skills/g-team-skill-validate/SKILL.md`  (remaining args: $ARGUMENTS)

If $ARGUMENTS is empty or unrecognized, list available subcommands:
  - `help` — show current project state and next recommended action
  - `status` — quick one-line workflow snapshot (milestone, plan, review gate)
  - `doctor` — validate project setup health (hooks, settings, CLAUDE.md, milestone alignment)
  - `init` — scaffold CLAUDE.md, ROADMAP.md, milestones/, todo.md, and commit hooks
  - `kickoff` — interview about goals and stack; produce project_brief.md
  - `onboard` — onboard onto an existing codebase; produce project_brief.md
  - `brief` — refresh project_brief.md as the project evolves
  - `plan` — decompose request into atomic tasks and parallel wave schedule
  - `execute [wave]` — dispatch parallel agents per wave; optionally resume from a specific wave number
  - `review` — run full review pipeline; issues MERGE READY or HOLD
  - `specialize [stack]` — auto-detect or apply a named stack profile
  - `update` — realign all g-team-managed files to the current plugin version
  - `skill-design` — design a new skill from scratch (SKILL.md, command file, router entry)
  - `skill-validate [name]` — validate a skill or agent against G-Team structural rules
