---
description: G-Team workflow commands. Subcommands: init, kickoff, onboard, plan, execute, review, specialize, update.
argument-hint: <init|kickoff|onboard|plan|execute|review|specialize|update> [args]
---

Route to the correct skill file based on the subcommand in $ARGUMENTS.

For each subcommand, use Glob to find the corresponding SKILL.md inside `~/.claude/plugins/cache/g-team/g-team/` and read it, then follow its instructions exactly.

- `init`       → `skills/g-team-init/SKILL.md`
- `kickoff`    → `skills/g-team-kickoff/SKILL.md`
- `onboard`    → `skills/g-team-onboard/SKILL.md`
- `plan`       → `skills/g-team-plan/SKILL.md`
- `execute`    → `skills/g-team-execute/SKILL.md`  (remaining args: $ARGUMENTS)
- `review`     → `skills/g-team-review/SKILL.md`
- `specialize` → `skills/g-team-specialize/SKILL.md`  (remaining args: $ARGUMENTS)
- `update`     → `skills/g-team-update/SKILL.md`

If $ARGUMENTS is empty or unrecognized, list available subcommands:
  - `init` — scaffold CLAUDE.md, ROADMAP.md, milestones/, todo.md, and commit hooks
  - `kickoff` — interview about goals and stack; produce project_brief.md
  - `onboard` — onboard onto an existing codebase; produce project_brief.md
  - `plan` — decompose request into atomic tasks and parallel wave schedule
  - `execute [wave]` — dispatch parallel agents per wave; optionally resume from a specific wave number
  - `review` — run full review pipeline; issues MERGE READY or HOLD
  - `specialize [stack]` — auto-detect or apply a named stack profile
  - `update` — realign all g-team-managed files to the current plugin version
