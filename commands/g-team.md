---
description: G-Team workflow commands. Subcommands: init, kickoff, onboard, plan, review, specialize.
argument-hint: <init|kickoff|onboard|plan|review|specialize> [args]
---

Route to the correct G-Team skill based on the subcommand in $ARGUMENTS.

- If $ARGUMENTS starts with `init` → invoke skill `g-team:g-team-init`
- If $ARGUMENTS starts with `kickoff` → invoke skill `g-team:g-team-kickoff`
- If $ARGUMENTS starts with `onboard` → invoke skill `g-team:g-team-onboard`
- If $ARGUMENTS starts with `plan` → invoke skill `g-team:g-team-plan`
- If $ARGUMENTS starts with `review` → invoke skill `g-team:g-team-review`
- If $ARGUMENTS starts with `specialize` → invoke skill `g-team:g-team-specialize` (pass any remaining args)
- If $ARGUMENTS is empty or unrecognized → list available subcommands:
  - `init` — scaffold CLAUDE.md, ROADMAP.md, milestones/, todo.md, and commit hooks
  - `kickoff` — interview about goals and stack; produce project_brief.md
  - `onboard` — onboard onto an existing codebase; produce project_brief.md
  - `plan` — decompose request into atomic tasks and parallel wave schedule
  - `review` — run full review pipeline; issues MERGE READY or HOLD
  - `specialize [stack]` — apply stack profile (vue-pinia, node-ts, fastapi)
