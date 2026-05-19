---
name: g-adr
description: Capture an architectural decision record. Interactive prompts gather context, decision, alternatives considered, and consequences. Writes to docs/decisions/NNN-title.md in standard ADR format. Run when making a significant technical choice — stack selection, new pattern, new external dependency, layer restructure.
argument-hint: [short decision title]
---

**Announce:** "Using g-adr to record an architectural decision."

Architectural decisions undocumented become invisible. New team members re-litigate settled choices. Drift happens without anyone knowing why the original constraint existed. This skill captures decisions while the context is fresh.

## Step 1 — Establish the title

**If an argument was provided** (e.g. `/g-adr "use PostgreSQL instead of SQLite"`):
- Use it as the working title. Confirm with developer: "Recording ADR: '[title]' — is that the right framing?"
- Wait for confirmation or correction.

**If no argument was provided**, ask:
> "What decision are you recording? Give it a short, verb-first title — e.g. 'Use Pinia over Vuex', 'Adopt server-side rendering for marketing pages', 'Keep auth stateless with JWTs'."

Wait for the title. Proceed.

## Step 2 — Gather context interactively

Ask each question in sequence. Wait for the answer before asking the next. Do not batch them.

**Question 1 — Context:**
> "What is the situation, problem, or requirement that forced this decision? Include any constraints (performance, team skill, cost, existing infrastructure) that shaped the options."

**Question 2 — Decision:**
> "What did you decide, specifically? Name the technology, pattern, or approach chosen. Be concrete — 'use X' not 'improve Y'."

**Question 3 — Alternatives considered:**
> "What other options did you evaluate? For each, why did you reject it? (Even if you only considered one alternative, name it and say why it lost.)"

**Question 4 — Consequences:**
> "What becomes easier as a result? What becomes harder or is now off the table? Any risks, trade-offs, or follow-up decisions this creates?"

**Question 5 — Status:**
> "What is the status of this decision?
> - **Accepted** — in effect, team has agreed
> - **Proposed** — under discussion, not yet confirmed
> - **Deprecated** — was accepted but is being phased out
> - **Superseded** — replaced by a newer ADR (which one?)"

**Question 6 — Rejected alternatives:**
> "What alternatives did you seriously consider and reject? For each, what was the deciding factor against it?"

**Question 7 — Assumptions that held:**
> "What assumptions is this decision relying on? Which of these are most likely to be invalidated later?"

**Question 8 — Constraints that drove the decision:**
> "What constraints (time, team, compatibility, compliance, cost) were the primary drivers? Would you decide differently without them?"

## Step 3 — Determine ADR number

```bash
find . -path "*/docs/decisions/*.md" -not -path "*/node_modules/*" | sort
```

If `docs/decisions/` does not exist, create it.

Count existing ADRs. Next number = highest existing number + 1, zero-padded to 3 digits (001, 002, ... 099, 100).

If no existing ADRs, start at 001.

## Step 4 — Write the ADR

Derive a kebab-case filename from the title. Examples:
- "Use PostgreSQL instead of SQLite" → `001-use-postgresql-instead-of-sqlite.md`
- "Adopt server-side rendering for marketing pages" → `002-adopt-ssr-for-marketing-pages.md`

Write to `docs/decisions/[NNN]-[kebab-title].md`:

```markdown
# ADR-[NNN]: [Title]

**Date:** [YYYY-MM-DD]
**Status:** [Accepted | Proposed | Deprecated | Superseded by ADR-NNN]
**Context:** [project name or area this applies to]

## Context

[Developer's answer to Question 1 — situation, problem, constraints. 2–5 sentences.]

## Decision

[Developer's answer to Question 2 — what was chosen, specifically. 1–3 sentences.]

## Alternatives considered

| Option | Why rejected |
|--------|-------------|
| [alternative 1] | [reason] |
| [alternative 2] | [reason] |

## Consequences

**Easier:** [what this enables]
**Harder / constrained:** [what this makes more difficult or rules out]
**Follow-up decisions:** [any decisions this creates or defers — or "none"]
**Risks:** [known risks — or "none identified"]

## Rejected Alternatives

| Alternative | Why rejected |
|-------------|--------------|
| [name] | [deciding factor] |

## Assumptions That Held

- [assumption and its fragility]

## Constraints That Drove This Decision

- [constraint: time/team/compliance/cost/etc.]
```

## Step 5 — Surface follow-up actions

After writing the ADR, check whether any downstream files should be updated:

- If the decision affects the project's architecture: "Does this decision change the layer map or import rules in CLAUDE.md? If so, update it or run `/g-specialize` to reinstall the profile."
- If the decision involves a new external dependency: "Consider adding this dependency to `project_brief.md`'s tech decisions table."
- If the decision deprecates a previous approach: "Is there an existing ADR for the old approach? If so, update its status to Deprecated and add a 'Superseded by ADR-[NNN]' note."

Report:
```
ADR-[NNN] written: docs/decisions/[NNN]-[title].md
Status: [Accepted | Proposed | ...]

[Follow-up actions if any, or "No follow-up actions identified."]
```

## Rules
- Never reconstruct past decisions from code alone — the developer must provide the context.
- If the developer cannot articulate why the decision was made, record what is known and mark the Context section with `[Note: rationale partially reconstructed — verify with original decision-makers]`.
- Do not editorialize or second-guess the decision in the ADR — record it faithfully.
- If a decision is still being debated, use status **Proposed** and record the current leading option — update to **Accepted** when confirmed.
- ADR numbers are permanent. Never renumber existing ADRs.
- ADRs written before M9 (v0.10.0) are pre-lineage — they do not have Rejected Alternatives, Assumptions, or Constraints sections. No backfill is required.
