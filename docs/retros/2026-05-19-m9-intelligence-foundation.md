# Retro: m9-intelligence-foundation — 2026-05-19

## What was done

- **Rename pass (G-Team → G-Forge)** — all display name occurrences replaced across 21 files: README.md, CLAUDE.md, G-RULES.md, ROADMAP.md, CHANGELOG.md, project_brief.md, templates/CLAUDE.md, 9 SKILL.md files (g-init, g-update, g-onboard, g-specialize, g-doctor, g-help, g-skill-validate, g-skill-design, g-status), 3 command files (g-team.md, g-onboard.md, g-skill-validate.md), and 2 doc files (agents.md, orchestration-patterns.md)
- **Manifest identifiers updated** — `plugin.json` and `marketplace.json` `name` fields changed from `g-team` to `g-forge`; GitHub URLs intentionally preserved
- **docs/memory-taxonomy.md created** — 6-tier memory layer taxonomy (Working, Task, Sprint, Architectural, Institutional, Human Preference) with lifetime, audience, what belongs in each tier, and example content; includes Frontmatter Usage section documenting the `context:` field convention
- **Context profiles v1** — `context:` field added to frontmatter of g-plan (`[task, sprint, architectural]`), g-execute (`[task, sprint]`), g-review (`[task, sprint, architectural]`), and g-retro (`[task, sprint, institutional]`)
- **G-RULES.md § I · Memory Layers** — new section referencing the taxonomy and the `context:` convention; tier table with lifetime and scope per tier
- **ADR lineage fields** — g-adr/SKILL.md updated with 3 new interview questions (Q6 rejected alternatives, Q7 assumptions that held, Q8 constraints that drove the decision), 3 matching template sections, and a pre-lineage note in Rules (ADRs before M9/v0.10.0 require no backfill)
- **Version bump to 0.10.0** — plugin.json and marketplace.json updated; CHANGELOG [0.10.0] entry added; M9 status marked ✅ Complete in ROADMAP.md and milestones/M9-intelligence-foundation.md

## Decisions made

None recorded.

## Patterns

### Worked well

None recorded.

### Avoid / do differently

None recorded.

## Cold-start context

**Branch:** main
**Active milestone:** M9 — Intelligence Foundation · ✅ Complete
**Next up:** M10 — Organizational Learning Loop (G-Forge detects recurring failure patterns and proposes self-corrections)
**Key files touched:** README.md, CLAUDE.md, G-RULES.md, ROADMAP.md, CHANGELOG.md, project_brief.md, templates/CLAUDE.md, plugin.json, marketplace.json, docs/memory-taxonomy.md, skills/g-adr/SKILL.md, skills/g-plan/SKILL.md, skills/g-execute/SKILL.md, skills/g-review/SKILL.md, skills/g-retro/SKILL.md, skills/g-init/SKILL.md, skills/g-update/SKILL.md, skills/g-onboard/SKILL.md, skills/g-specialize/SKILL.md, skills/g-doctor/SKILL.md, skills/g-help/SKILL.md, skills/g-skill-validate/SKILL.md, skills/g-skill-design/SKILL.md, skills/g-status/SKILL.md, commands/g-team.md, commands/g-onboard.md, commands/g-skill-validate.md, docs/agents.md, docs/orchestration-patterns.md
**Carry-over context:** All M9 work is uncommitted (working tree). Commit gate is open (.claude/g-team-approved written). Four non-blocking warnings from code-lead: ROADMAP.md:91 scope description reads "G-Forge → G-Forge" instead of "G-Team → G-Forge"; Handoff block is stale (still says M9 not started); g-doctor/g-update downstream migration concern for old G-Team marker strings; g-adr template has duplicate alternatives sections (legacy + new).
