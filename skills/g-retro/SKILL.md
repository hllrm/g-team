---
name: g-retro
description: Save a structured session retrospective to docs/retros/YYYY-MM-DD-topic.md — captures what was done, decisions made, patterns that worked or failed, and cold-start context for the next session.
context: [task, sprint, institutional]
---

**Announce:** "Using g-retro to record a session retrospective."

## Step 1 — Determine topic

If the user provided a topic argument, use it as the slug (lowercase, hyphen-separated, e.g. `auth-refactor`).

Otherwise, read `todo.md` (Handoff block) and run `git log --oneline -5` in parallel. From those two sources, infer a short descriptive slug that captures the session's main theme (e.g. `precompact-hook`, `review-gate-fix`, `m3-wave2`). Keep it under 30 characters.

Confirm with the developer before continuing:

> "Recording retro for: **[topic]** — correct? (reply with the topic to change it, or say 'yes' / 'y' to confirm)"

Wait for confirmation. If the developer replies with a different topic, use that instead.

## Step 2 — Gather session context

Read the following in parallel:

- `todo.md` — full file (Handoff block + Tasks table)
- `todo-done.md` — last 10 entries (read from the end of the file)
- Run `git log --oneline -10` via Bash

From these sources extract:

- **What was built or fixed** — commits and closed tasks from this session
- **What was deferred** — open tasks still in `todo.md` Tasks table
- **Any blockers hit** — mentioned in the Handoff block or visible in the commit history (e.g. reverts, fix-of-fix commits)
- **Key files touched** — unique file names appearing across the 10 commits (strip paths to basename, deduplicate)
- **Current branch** — from `git branch --show-current`
- **Active milestone** — from the Handoff block in `todo.md`, or from `ROADMAP.md` if not present in `todo.md`

## Step 3 — Interview for patterns and decisions

Ask the developer the following questions, one at a time. Wait for the answer to each before asking the next.

**Question 1:**
> "Any decisions made this session worth recording? (tech choices, approach changes, anything you'd want to remember next time — or 'none')"

Wait for answer.

**Question 2:**
> "Any patterns that worked well or failed? Anything to do differently next time? (or 'none')"

Wait for answer.

**Question 3 (conditional — only if a forecast file exists for the active plan):**

Before asking, derive the plan slug for this session using the following deterministic order:

1. **Branch name** — if the current branch matches `feat/<slug>`, `fix/<slug>`, `refactor/<slug>`, or `chore/<slug>`, strip the prefix and use `<slug>` as the candidate.
2. **Forecast directory** — check whether `docs/forecasts/<candidate>.md` exists. If yes, that is the active plan.
3. **Fallback** — if no match by branch, find the most-recently-modified file under `docs/forecasts/*.md` whose corresponding `docs/plans/<slug>.md` has at least one wave in the Progress table not yet marked `complete`. If no such file exists, skip Question 3 silently.

When a forecast file is identified, ask:

> "Forecast for this milestone predicted the following scenarios — for each, did it actually happen? (yes / no / partial)
> 1. [scenario 1 from forecast]
> 2. [scenario 2 from forecast]
> ..."

Wait for answer. Then update the `## Outcome` table in the identified forecast file with the developer's verdict for each row. This closes the feedback loop — `/g-patterns` reads these outcomes to weight pattern confidence in future runs.

If derivation yields no forecast file, skip Question 3 silently — it is conditional and only fires when a forecast exists to verify.

## Step 4 — Write the retro file

Create `docs/retros/` if it does not exist. Use today's date in `YYYY-MM-DD` format and the confirmed topic slug to form the filename: `docs/retros/YYYY-MM-DD-[topic].md`.

Write the file with this exact structure:

```markdown
# Retro: [topic] — [YYYY-MM-DD]

## What was done
[bullet list derived from git log + closed todo-done.md entries — one bullet per logical unit of work, not per commit]

## Decisions made
[developer's answer from Question 1, or "None recorded."]

## Patterns
### Worked well
[from developer's answer to Question 2 — items that helped; or "None recorded."]
### Avoid / do differently
[from developer's answer to Question 2 — items to stop or change; or "None recorded."]

## Cold-start context
**Branch:** [current branch]
**Active milestone:** [milestone name and status, e.g. "M3 — Hooks + Init · In progress"]
**Next up:** [Handoff "Next up" line from todo.md, verbatim]
**Key files touched:** [comma-separated list of files from git log this session]
**Carry-over context:** [any in-flight logic, state, gotchas, or partial work from the Handoff "Active context" line in todo.md]
```

Do not add extra sections. Do not summarise the interview answers beyond what the developer said.

## Step 5 — Surface the file

Report the file path and print the Cold-start context section verbatim so the developer can verify it is accurate:

```
Retro written: docs/retros/YYYY-MM-DD-[topic].md

--- Cold-start context ---
[paste the Cold-start context block here]
```

If the developer requests a correction, edit the file and re-print only the corrected section.

## Step 6 — Pattern suggestions (informational)

After writing the retro, surface any patterns that just-written retro contributes to. This closes the loop with `/g-patterns` without requiring a separate invocation.

Run a lightweight pattern-mine pass:
1. Read every retro under `docs/retros/`, including the one you just wrote.
2. Apply the `None recorded.` sentinel filter from `/g-patterns` Step 2a.
3. Extract bullets under `Avoid / do differently` and group by normalised label.
4. Count distinct source files per label.

If any label now has ≥2 source files, print:

```
Pattern signal — labels reaching ≥2 occurrences after this retro:
  · [label]  — sources: [filenames]
  · [label]  — sources: [filenames]

Run /g-patterns to triage these into proposed rule edits.
```

If no label reaches ≥2 — print nothing. Pattern-suggestion is silent when there's no signal worth surfacing.

Do not modify any rule files from inside `/g-retro` — surfacing is the cap of this skill's responsibility. `/g-patterns` is the only entry point that proposes edits.

## Rules

- Never write the retro file before receiving explicit confirmation in Step 1
- Never skip Step 3 — the interview is mandatory even if the developer says they have nothing to add ("none" is a valid answer and must be recorded as-is)
- Use today's date for the filename — never infer the date from git history
- One retro file per session — if a retro file already exists for today's topic, ask before overwriting
- Do not commit the retro file — writing the file is the done condition; committing is the developer's choice
- Keep bullet points in "What was done" at the logical-work level, not the commit level — group related commits into one bullet
- If `todo.md` or `todo-done.md` is missing, note the gap and proceed with whatever is available from git log
- Never add opinions, suggestions, or follow-up recommendations to the retro file — it is a factual record only
