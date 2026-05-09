---
name: g-team-status
description: Quick one-shot snapshot of current workflow state: active plan, wave progress, review gate, current milestone.
---

Produce a single structured status block. Fast — no interviews, no back-and-forth.

**Step 1.** Announce: "Using g-team-status to snapshot project state."

**Step 2.** Read the following files from the project root (skip gracefully if any are missing):

- `ROADMAP.md` — extract the current milestone name and its status (in progress / done)
- `docs/plans/` — find the most recently modified `.md` file; extract wave count and task list if present
- `todo.md` — extract the Handoff block (first section), specifically the first "Next up" line
- `.claude/g-team-approved` — note whether this file exists

**Step 3.** Output exactly this block, filling each field or writing "—" if the information is unavailable:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
G-Team Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Milestone:    [M1 — Name · 🚧 In progress / ✅ Done]
Plan:         [docs/plans/filename.md · Wave N of M / none]
Review gate:  [open (MERGE READY) / locked]
Handoff:      [first "Next up" line from todo.md / —]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Rules:**
- Output only the status block — no extra explanation unless a critical misconfiguration is detected (e.g. hooks not installed)
- If `.claude/g-team-approved` exists → review gate is "open (MERGE READY)"; otherwise → "locked"
- If a plan file exists → show its filename and wave info if parseable; otherwise → "none"
- Never error out on missing files — skip them silently and fill the field with "—"
