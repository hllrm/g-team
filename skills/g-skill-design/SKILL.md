---
name: g-skill-design
description: Design a new g-team skill from scratch. Gathers requirements, drafts SKILL.md with correct structure, creates the companion command file, and adds it to the g-team router.
---

**Announce:** "Using g-skill-design to design the new skill."

You are designing a new G-Forge skill. Follow these steps in order.

## Step 1 — Understand the skill's purpose

Ask the developer:

> "What should this skill do? Describe:
> 1. The trigger — what user action or workflow state invokes it?
> 2. The output — what does running this skill produce? (files, reports, modified state, user guidance)
> 3. The name — what will the slash command be? (e.g. `foo` → command `/g-foo`, files `commands/g-foo.md` + `skills/g-foo/SKILL.md`)"

Wait for answers before continuing.

## Step 2 — Check for existing similar skills

Use Glob to list `skills/*/SKILL.md`. Read the `description:` line from the frontmatter of each. If a skill with substantially similar purpose already exists, tell the developer:

> "A similar skill already exists: [name] — [description]. Should we extend that one or create a new one?"

Wait for answer. If extending, stop here and provide notes on what to change; do not write a new file.

## Step 3 — Draft the skill steps

From the developer's answers, draft the numbered steps the skill will follow. Each step must:
- Have a clear single responsibility (read, ask, draft, write, dispatch, or report)
- Specify wait points (when to pause for user input before proceeding)
- Not invoke the Skill() tool (use Glob+Read on the target SKILL.md instead)
- Not write a file before reading it first

Present the step outline to the developer:

> "Here is the proposed step outline — does this match what you want?"

Wait for approval or revision before writing anything.

## Step 4 — Write the SKILL.md

Write `skills/g-team-[name]/SKILL.md` with this structure:

```
---
name: g-team-[name]
description: [One sentence: what it does and when to use it.]
---

**Announce:** "Using g-team-[name] to [purpose]."

[Intro sentence describing what this skill does.]

## Step 1 — [Verb phrase]
[Step body]

## Step 2 — [Verb phrase]
[Step body]

[... remaining steps ...]

## Rules
- [Rule protecting against the most common mistake]
- [Rule protecting against the second most common mistake]
[... additional rules as needed ...]
```

**Required elements — verify before writing:**
- YAML frontmatter with `name:` and `description:` only (no `argument-hint`)
- `**Announce:**` line immediately after the closing `---` of frontmatter
- All steps numbered `## Step N — [Verb phrase]`
- At least one rule in `## Rules`
- No Skill() tool invocations anywhere in the file
- No hardcoded absolute paths (use Glob to discover dynamic paths)

## Step 5 — Write the command file

Write `commands/g-team-[name].md` with this content:

```
---
description: [Same one-sentence description as in SKILL.md.]
---

Use Glob to find `skills/g-team-[name]/SKILL.md` inside `~/.claude/plugins/cache/g-team/g-team/` and read it, then follow its instructions exactly.
```

## Step 6 — Add to the g-team router

Read `commands/g-team.md`. Make three additions:

1. In the `argument-hint` value: append `|[name]` to the pipe-separated list
2. In the routing table: add a new line `- \`[name]\`       → \`skills/g-team-[name]/SKILL.md\``
3. In the subcommand description list at the bottom: add `- \`[name]\` — [one-line description]`

Write the updated file.

## Step 7 — Report

```
Skill created ✓

  ✓ skills/g-team-[name]/SKILL.md — skill workflow written
  ✓ commands/g-team-[name].md    — command routing file written
  ✓ commands/g-team.md           — router updated

Run /g-skill-validate [name] to validate the new skill's structure.
```

## Rules
- Never write SKILL.md before Step 3 approval — the step outline must be confirmed first.
- Never use Skill() tool invocations in the generated SKILL.md.
- Never add argument-hint to SKILL.md frontmatter.
- If a similar skill already exists, surface it before drafting — do not create duplicates.
- The command file must use the Glob+Read pattern — never embed instructions directly.
- Router update must preserve all existing entries — read before writing.
