---
name: g-team-brief
description: Refresh project_brief.md as the project evolves — reads current state, asks targeted questions, and updates the brief without a full re-onboard.
---

**Announce:** "Using g-team-brief to refresh the project brief."

Incrementally update `project_brief.md`. This skill is lighter than `/g-team onboard` — it assumes an existing brief and a project already in progress.

## Step 1 — Read current state

If `project_brief.md` does not exist, tell the developer: "No project_brief.md found. Run /g-team kickoff or /g-team onboard first to create one." and stop.

Read the following (skip gracefully if missing):
- `project_brief.md` — current brief (capture the tech decisions table and goals)
- `ROADMAP.md` — milestone status
- `todo.md` — handoff block and open tasks
- Run `git log --oneline -20` via Bash — last 20 commits

Present a summary of what you found:

```
Current brief: [date if present / unknown]
Milestone:     [current milestone + status]
Open tasks:    [count from todo.md]
Recent commits: [count] — last: "[most recent commit message]"
```

## Step 2 — Targeted interview

Ask only the questions that are actually uncertain based on Step 1. Never ask about things already answered in the existing brief. At most 4 questions, one at a time.

Always ask:
1. "What has changed since the last brief? (new features shipped, decisions changed, scope added/removed)"

Ask only if unclear from Step 1:
2. "What's the current milestone goal and is it still accurate?"
3. "Are there any new technical constraints or stack changes?"
4. "Any known fragile areas or active blockers I should capture?"

Wait for answers before proceeding.

## Step 3 — Update project_brief.md

Rewrite `project_brief.md` preserving:
- Original project name and one-line description
- Tech decisions table (update any entries that changed)
- Stack and architecture notes

Update:
- Current milestone and status (from ROADMAP.md + answers)
- What's been built (from git log + answers)
- What's next (from todo.md + answers)
- Any new constraints, fragile areas, or decisions from the interview

Add at the top: `Last updated: [today's date]`

Never drop information from the previous brief without asking. Keep the brief concise — add only what's new, don't inflate.

## Step 4 — Report

```
project_brief.md updated ✓

Changes:
  · [bullet list of what changed vs the previous brief]
```
