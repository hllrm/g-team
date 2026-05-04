---
name: g-team-skill-validate
description: Validate a skill or agent file against G-Team structural rules. Checks SKILL.md format, command file, router registration, and agent frontmatter. Issues VALID or NEEDS FIXES verdict.
---

**Announce:** "Using g-team-skill-validate to validate the skill."

You are validating a G-Team skill or agent against structural rules. Run all checks, produce a ✓/✗ checklist, and issue a final verdict.

## Step 1 — Identify what to validate

If a skill name was provided as an argument (e.g. the user typed `/g-team skill-validate g-team-foo`), use that name.

If no argument was provided, ask:

> "Which skill or agent do you want to validate? Provide the skill name (e.g. `g-team-foo`) or agent filename (e.g. `code-reviewer.md`)."

Wait for input.

Determine from the name whether this is a skill (look for `skills/[name]/SKILL.md`) or an agent (look for `agents/[name]`).

## Step 2 — Validate SKILL.md (skills only)

Locate `skills/[name]/SKILL.md`. If the file does not exist, record: ✗ SKILL.md not found — skip remaining skill checks and go to Step 6.

Run these checks and record ✓ or ✗ for each:

**Frontmatter checks:**
- `name:` field present
- `description:` field present
- `argument-hint:` is NOT present (its presence is a violation — breaks skill loading)

**Body checks:**
- `**Announce:**` line present (must appear before the first step)
- At least 2 numbered steps present (`## Step N —` format)
- `## Rules` section present
- No `Skill()` invocations anywhere in the file (search for `Skill(`)
- No hardcoded absolute paths starting with `/home/`, `/Users/`, `C:\`, `D:\` (use Glob to discover paths instead)

## Step 3 — Validate command file (skills only)

Locate `commands/[name].md`. If absent, record: ✗ command file missing.

If present, check and record ✓ or ✗:
- YAML frontmatter with `description:` present
- File uses Glob+Read pattern to load SKILL.md (contains "Glob" and "SKILL.md")
- No Skill() invocations (search for `Skill(`)

## Step 4 — Validate router registration (skills only)

Read `commands/g-team.md`. Check and record ✓ or ✗:
- Subcommand name appears in the routing table (the `- \`[name]\`` lines)
- Subcommand name appears in the description list at the bottom

## Step 5 — Validate agent file (agents only)

If validating an agent, locate the agent file in `agents/`. If absent, record: ✗ agent file not found — skip to Step 6.

If present, check and record ✓ or ✗:

**Frontmatter checks:**
- `name:` field present
- `description:` field present
- `model:` field present (must be `haiku`, `sonnet`, or `opus`)
- `tools:` field present

**Body checks:**
- Output Format section present (agents must define their report structure)
- Tools listed do not include Write, Edit, or Bash (agents are read-only)
- Body describes findings, not fixes (look for imperative "fix" language that shouldn't be there)

## Step 6 — Report

Output the full checklist, then issue the verdict:

```
## Skill Validation: [name]

### SKILL.md
✓ name: present
✓ description: present
✗ argument-hint: found on line 3 (must be removed — breaks skill loading)
✓ Announce line present
✓ Numbered steps (4 found)
✓ Rules section present
✗ Skill() invocation found on line 23 (remove — causes infinite loop)
✓ No hardcoded absolute paths

### Command file (commands/[name].md)
✓ description: in frontmatter
✓ Glob+Read pattern used
✓ No Skill() invocations

### Router (commands/g-team.md)
✓ Routing table entry present
✗ Description list entry missing

---
VERDICT: NEEDS FIXES — 3 issues found
```

If all checks pass:

```
---
VERDICT: VALID — all checks passed
```

## Rules
- Run all checks before issuing the verdict — do not stop at the first failure.
- Never fix the issues yourself — report only. The developer fixes and re-runs validation.
- If the target file does not exist, the verdict is NEEDS FIXES with "file not found" as the finding.
- For skills: validate SKILL.md + command file + router together — not just SKILL.md alone.
- For agents: validate agent file only (no command file or router check needed).
