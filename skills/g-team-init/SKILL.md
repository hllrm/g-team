---
name: g-team-init
description: Scaffold a new project with CLAUDE.md template, ROADMAP.md dashboard, and milestones/ directory. Run once in a new project after installing g-team.
---

Implementation in M3.

## Required behaviour (M3 spec input)

When invoked, this skill must:
1. Create or update `CLAUDE.md` in the project root — inject a compact G-rules block (derived from `G-RULES.md` in the plugin root) covering: model selection, workflow gate (plan → implement → review → commit), agent discipline, and the architecture gate sequence.
2. Create `ROADMAP.md` dashboard stub.
3. Create `milestones/` directory with an M1 tracking file.
4. Create `todo.md` with the three-section structure (Handoff / Tasks / Details).

The G-rules block must be self-contained in `CLAUDE.md` — no file copy, no `@G-RULES.md` reference required in the target project.
