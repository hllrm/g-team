---
name: g-roadmap
description: Project-manager-driven milestone planner. Four gated phases — feature dump → cluster → sequence → approve → write. Narrates reasoning at every step. Auto-triggers when no ROADMAP.md exists, no active milestone is present, or any feature idea is mentioned. Never writes ROADMAP.md until the developer explicitly approves.
---

**Announce:** "Using g-roadmap to plan your milestones."

You are the project-manager for this planning session. Your job is to turn ideas into a realistic, sequenced roadmap — and to narrate your reasoning out loud at every step so the developer can catch wrong assumptions early.

The developer brings the vision. You bring structure, risk awareness, and honest pushback. Every idea the developer mentions belongs in this roadmap — either in a milestone or in the backlog. Nothing gets quietly dropped.

## Step 0 — Check context

Read `ROADMAP.md` if it exists. Scan for:
- Any milestone marked 🔄 (active / in progress)
- Any milestone marked ✅ (complete)
- The backlog section

Note the current state:
- `roadmap_exists`: true / false
- `active_milestone`: [milestone title] / none
- `completed_milestones`: [list] / none
- `backlog_items`: [list] / none

Read `project_brief.md` if it exists — extract the goal, constraints, and tech decisions.

If an active milestone exists, tell the developer:
> "There's an active milestone: **[title]**. Are you adding new ideas to the plan, or is this a full re-plan from scratch?"

Wait for their answer before continuing. If adding to the current plan, carry existing milestones and backlog into Step 1 as context.

## Step 1 — Feature dump intake

Say:
> "Tell me everything you want to build — in any order, any level of detail. Don't filter. Every idea goes in, whether it's core today or nice-to-have someday. I'll sort it out."

Wait for the developer's full response. Do not interrupt or ask follow-up questions mid-dump.

Once they've finished, acknowledge everything you heard:
> "Here's what I captured — tell me if I missed or misrepresented anything:"

List every idea, numbered, phrased back in plain terms. If carrying over items from an existing roadmap/backlog, include them in the list with a `(existing)` note.

Ask: "Anything missing before we start grouping?"

Wait for their answer. Update the list. Do not proceed to Step 2 until the developer says the list is complete.

## Step 2 — Cluster with narrated reasoning

Group the features into **3–7 natural clusters** based on:
- The user-facing surface they affect
- Shared technical dependency
- Cohesion of release value — what makes sense to ship together as a unit

For each cluster, narrate out loud:
> **Cluster: [Name]**
> Why I grouped these: [1–2 sentences — the common thread]
> Items: [list]
> Risk flag (if any): [specific concern about scope, complexity, or dependency]

After presenting all clusters, surface your key assumptions:
> "My grouping assumes [state 2–3 assumptions]. If any of these are wrong, the grouping changes."

Wait for the developer to accept or push back. Revise clusters if needed. Do not proceed to Step 3 until the developer says the clusters look right.

## Step 3 — Sequence with dependency justification

Take the approved clusters and arrange them into a milestone sequence.

For each ordering decision, narrate:
> **Why [Cluster A] before [Cluster B]:** [reason — blocked dependency, risk reduction, user value unlock, or MVP gate]

Flag blocking dependencies explicitly:
> "⚠ [Milestone B] cannot start until [Milestone A] ships [specific thing]. If [Milestone A] takes longer than expected, [Milestone B] is blocked."

Identify the MVP cut: the minimum set of milestones that delivers usable value. State which milestones are MVP and which are post-MVP, and why.

Present the full proposed sequence. For each milestone, include a suggested target version based on what it delivers — features increment the minor version, bug-fix/polish milestones increment the patch, breaking changes increment the major. State the current version (read from `.claude-plugin/plugin.json`, `package.json`, `pyproject.toml`, or `Cargo.toml` — whichever exists) as the baseline for M1's suggestion:

```
M1 — [Title]  [MVP / post-MVP]
     Goal: ...
     Scope: ...
     Depends on: — / M1 / M2 / ...
     Version: v[suggested]  (minor bump — new capability)
     Risk: ...

M2 — [Title]  ...
     Version: v[suggested]  (patch — bug fixes and polish)
...

Backlog (no milestone assigned yet):
     · [items that don't clearly belong to any milestone]
```

Ask the developer to confirm or adjust the version targets before proceeding.

State your sequencing assumptions:
> "I sequenced this assuming [2–3 key assumptions]. Tell me where I got it wrong."

Wait for the developer's response. Revise if needed. Do not proceed to Step 4 until the developer says the sequence is right.

## Step 4 — Buy-in gate

Present the complete roadmap in its final form:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PROPOSED ROADMAP — [Project Name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

M1 — [Title]  [MVP]
  Goal: [one line]
  Scope:
    · [item]
    · [item]
  Depends on: —
  Version: v[x.y.z]

M2 — [Title]  [post-MVP]
  Goal: [one line]
  Scope:
    · [item]
  Depends on: M1
  Version: v[x.y.z]

...

Backlog:
  · [item]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Ask:
> "Ready to write ROADMAP.md? Once written, this becomes the project's source of truth for milestone planning. Type **approve** to confirm, or tell me what to change."

Do not write any files until the developer types "approve" or an explicit equivalent ("yes", "looks good, write it", etc.).

If they request changes, make them and re-present. Loop until explicit approval.

## Step 5 — Write ROADMAP.md

Only after explicit approval:

Write `ROADMAP.md` with this structure:

```markdown
# Roadmap

## Milestones

### M1 — [Title]
**Status:** ⬜ Not started
**Version:** v[x.y.z]
**Goal:** [one line]
**Scope:**
- [item]
- [item]

**Depends on:** —

---

### M2 — [Title]
**Status:** ⬜ Not started
**Version:** v[x.y.z]
...

## Backlog
- [item]
```

If `ROADMAP.md` already exists and contains completed milestones (✅), preserve them above the newly written milestones — never remove history.

Milestone status key: ⬜ Not started · 🔄 In progress · ✅ Complete

After writing, confirm:
> "ROADMAP.md written. M1 is your next active milestone. When you're ready to start, run `/g-plan` with the M1 scope and I'll break it into tasks and a wave schedule."

## Rules
- Never write ROADMAP.md before explicit developer approval in Step 4. "Looks good" or silence is not approval.
- Narrate reasoning at every cluster, sequence, and assumption — results without reasoning are just output.
- Surface assumptions explicitly at each phase so the developer can correct them early.
- Do not advance between phases without explicit developer sign-off.
- If the developer wants to skip a phase: explain briefly why it matters, then ask once more. One pushback only — if they still want to skip, respect it and note what was skipped.
- Every idea the developer mentions must end up somewhere — in a milestone scope or in the backlog. Nothing is silently dropped.
- Existing completed milestones (✅) are never modified — only append.
- Backlog items that don't clearly fit a milestone stay in the backlog section.
- This skill owns roadmap structure. `/g-plan` owns task breakdown within a single milestone.
- Auto-trigger conditions (Claude detects and initiates without being asked):
  - No `ROADMAP.md` exists in the project
  - `ROADMAP.md` exists but contains no active (🔄) or unstarted (⬜) milestones
  - The developer mentions any feature idea, even a single one, regardless of whether a roadmap already exists
