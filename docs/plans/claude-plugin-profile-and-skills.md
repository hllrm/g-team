# Plan: claude-plugin Profile + Vibecoding Skills

> Created: 2026-05-05

## Tasks

| # | Task | Scope | Done condition |
|---|------|-------|----------------|
| 1 | claude-plugin architect agent | `profiles/claude-plugin/agents/claude-plugin-architect.md` | File exists with correct frontmatter, layer map, prohibited patterns, output format |
| 2 | claude-plugin architecture rules | `profiles/claude-plugin/rules/architecture.md` | File exists with layer map, skill format rules, agent format rules, prohibited patterns, output contract rule |
| 3 | skill-design SKILL.md | `skills/g-team-skill-design/SKILL.md` | File exists; announce line; 6 steps; rules section; no Skill() invocations |
| 4 | skill-validate SKILL.md | `skills/g-team-skill-validate/SKILL.md` | File exists; announce line; SKILL.md checklist; agent checklist; ✓/✗ output; VALID or NEEDS FIXES verdict |
| 5 | g-team-skill-design command file | `commands/g-team-skill-design.md` | File exists; Glob+Read pattern; matches g-team-kickoff.md structure |
| 6 | g-team-skill-validate command file | `commands/g-team-skill-validate.md` | File exists; Glob+Read pattern; matches g-team-kickoff.md structure |
| 7 | Add both to g-team router | `commands/g-team.md` | Router contains skill-design and skill-validate entries |
| 8 | Add claude-plugin to specialize frontmatter | `skills/g-team-specialize/SKILL.md` | claude-plugin in description frontmatter stacks list |
| 9 | Add claude-plugin detection to specialize Step 1 | `skills/g-team-specialize/SKILL.md` | Detection via .claude-plugin/plugin.json or plugin.json schema |
| 10 | Add claude-plugin to specialize Step 4 mapping | `skills/g-team-specialize/SKILL.md` | Mapping entry points to correct profile files |

## Wave Schedule

### Wave 1
- Task 1 — claude-plugin architect agent
- Task 2 — claude-plugin architecture rules
- Task 3 — skill-design SKILL.md
- Task 4 — skill-validate SKILL.md
- Task 5 — g-team-skill-design command file
- Task 6 — g-team-skill-validate command file
- Task 7 — Add both to g-team router
- Task 8 — Add claude-plugin to specialize frontmatter

### Wave 2
- Task 9 — Add claude-plugin detection to specialize Step 1

### Wave 3
- Task 10 — Add claude-plugin to specialize Step 4 mapping

## Progress

| Wave | Status | Notes |
|------|--------|-------|
| 1 | complete | 8 files created/updated |
| 2 | complete | claude-plugin detection added to specialize Step 1 |
| 3 | complete | claude-plugin added to specialize Step 4 mapping |
