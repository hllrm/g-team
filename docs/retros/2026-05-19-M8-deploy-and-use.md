# Retro: M8-deploy-and-use — 2026-05-19

## What was done
- Audited M8 scope against repo state — found that claude-plugin profile, /g-skill-design, /g-skill-validate, and router registration were already complete from prior sessions; only three items remained
- Installed `pre-compact.sh` to `.claude/hooks/` and registered the `PreCompact` event in `.claude/settings.json` — the final missing hook for 10/10 g-doctor
- Created retroactive milestone files `milestones/M6-auto-trigger.md` and `milestones/M7-correctness.md` to complete the M1–M8 file history
- Bumped version to v0.9.0 in `plugin.json` and `marketplace.json`; corrected marketplace description (skills 18→23, combo profiles 4→7)
- Added CHANGELOG `[0.9.0]` entry covering all M8 deliverables
- Updated `ROADMAP.md` M8 status to ✅ Complete and reformatted milestone list from compact table to per-section format (pre-existing uncommitted working-tree change from a prior session, shipped in the same commit)
- Ran `/g-review` → MERGE READY (code-lead verified all 9 done conditions); committed `969b732` and pushed

## Decisions made
None recorded.

## Patterns
### Worked well
None recorded.
### Avoid / do differently
- `/g-retro` should be kickstarted by Claude reading backwards through git log, todo.md, and commit history, then offering a pre-filled summary and retro notes for the developer to review and correct — rather than starting from a blank slate and interviewing. The interview should be a confirmation pass, not the primary input mechanism.

## Cold-start context
**Branch:** main
**Active milestone:** M8 — Deploy & Use · Complete (v0.9.0)
**Next up:** M9 — Intelligence Foundation (context profiles v1 + memory layer taxonomy + ADR lineage)
**Key files touched:** plugin.json, marketplace.json, CHANGELOG.md, ROADMAP.md, settings.json, pre-compact.sh, M6-auto-trigger.md, M7-correctness.md, M8-deploy-and-use.md, todo.md
**Carry-over context:** All M8 tasks closed; /g-doctor reports 10/10; M9 not started — first task is to define the context profiles v1 schema
