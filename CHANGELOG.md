# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [0.11.0] — 2026-05-19

### Added
- **`/g-patterns`** — organisational-learning skill. Mines `docs/retros/` and `todo-done.md` for recurring failure modes, buckets them by frequency (✓ isolated · ⚠ emerging · ✗ systemic), and proposes concrete profile-rule edits for any pattern observed ≥2 times. Per-suggestion apply/defer/dismiss flow — no edits applied without explicit developer choice. Deferrals logged to `docs/patterns-deferred.md`. Surfaces reinforced "worked well" patterns as a separate positive-signal bucket.
- **Self-evolution: rule-edit suggestions** — for every Emerging or Systemic pattern, the skill maps the failure class to a candidate fix target (G-RULES section, stack architecture rules, agent system prompt, or skill Rules section) and drafts a concrete edit: target file, target section, exact text, and a one-line rationale citing source retros.

## [0.10.0] — 2026-05-19

### Added
- **Rename: G-Forge** — project renamed from G-Team to G-Forge across all display strings, docs, and manifest name fields
- **Memory layer taxonomy** — `docs/memory-taxonomy.md` defining 6 tiers (Working, Task, Sprint, Architectural, Institutional, Human Preference) with lifetime, audience, and example content
- **Context profiles v1** — `context:` frontmatter field for skills and agents; g-plan, g-execute, g-review, and g-retro updated with appropriate tier declarations
- **ADR lineage fields** — `/g-adr` now captures rejected alternatives, assumptions, and constraints that drove the decision; template updated with corresponding sections; pre-M9 ADRs are pre-lineage
- **Memory taxonomy in G-RULES** — new § I · Memory Layers section referencing the taxonomy and the `context:` convention

## [0.9.0] — 2026-05-19

### Added

- **G-Forge self-hosting** — the g-team plugin repo now runs on its own tooling. `CLAUDE.md`, `G-RULES.md`, hooks (`check-commit.sh`, `post-commit-cleanup.sh`, `workflow-checkpoint.sh`, `pre-compact.sh`), and `settings.json` are installed and active on the repo itself.
- **`pre-compact.sh` installed** — PreCompact hook wired into `.claude/hooks/` and registered in `.claude/settings.json`. Fires before context compression; writes `.claude/compact-state.md` with branch, last 5 commits, and the Handoff block from `todo.md`.
- **Retroactive milestone files** — `milestones/M6-auto-trigger.md` and `milestones/M7-correctness.md` added to complete the milestone file history (M1–M8 now all present).
- **`claude-plugin` stack profile** — architect agent (`profiles/claude-plugin/agents/claude-plugin-architect.md`) validates skill structure, command routing, agent format, hook design, and manifest; architecture rules (`profiles/claude-plugin/rules/architecture.md`) cover all 6 layers with explicit Skill, Agent, Command, and Version rules. Profile is auto-detected by `/g-specialize` via `.claude-plugin/plugin.json` presence.
- **`/g-skill-design`** — 7-step skill for designing new g-team skills from scratch: gather requirements, check for existing similar skills, draft and confirm step outline, write SKILL.md, write command file, update router, report.
- **`/g-skill-validate [name]`** — 6-step validation skill: full ✓/✗ checklist across SKILL.md format, command file Glob+Read pattern, router registration, and agent frontmatter; issues VALID or NEEDS FIXES verdict.

## [0.8.1] — 2026-05-15

### Added

- **Versioning & release flow rules** in `G-RULES.md` §D — codifies the project's existing semver conventions: `MAJOR.MINOR.PATCH[a]` format, dual version source rule (`plugin.json` + `marketplace.json`), milestone-scoped bumps, hotfix `a` suffix convention, 7-step release commit sequence, mid-milestone scope-creep policy, and git tag stance.

## [0.8.0] — 2026-05-12

### Added

- **`/g-retro`** — session retrospective skill. After any non-trivial session, saves a structured retro to `docs/retros/YYYY-MM-DD-topic.md` capturing: what was done, decisions made, patterns that worked/failed, and a cold-start context block (branch, active milestone, next up, key files touched, carry-over context). Interactive: infers the topic from `todo.md` + `git log`, confirms with the developer, interviews for decisions and patterns, then writes and surfaces the file.
- **`pre-compact.sh` hook (`PreCompact` event)** — fires before Claude context compression. Writes `.claude/compact-state.md` containing the current branch, last 5 commits, and the Handoff block from `todo.md` at the moment of compaction. Exits 0 always — never blocks compression. Registered in `hooks/hooks.json` and wired into per-project `settings.json` by `/g-init`.
- **MCP recommendations in `/g-init`** — Step 8 report now lists recommended MCPs (`context7`, `github`, `supabase`) with descriptions and installation guidance.
- **PreCompact hook check in `/g-doctor`** — new check 10 verifies that `.claude/hooks/pre-compact.sh` is installed and `PreCompact` is registered in `settings.json`.

## [0.7.5] — 2026-05-11

### Added

- **SOLID principles as coding standards** — `G-RULES.md` §D now has a dedicated SOLID block with one concrete, actionable rule per principle (SRP, OCP, LSP, ISP, DIP), replacing the previous single SRP one-liner. `code-reviewer` gains a SOLID violations checklist with per-principle severity guidance (LSP = Critical, SRP/OCP/DIP = Major, ISP = Minor). `architecture-enforcer` gains OCP and DIP architectural checks covering type-switch dispatchers and wrong-direction imports from concrete adapters.
- **`/g-audit [path|all]`** — code quality audit skill. Grep-based parallel scanner covering SOLID violations, code smells, dead code markers, and test coverage gaps. Each finding is scored `(severity × impact) / change_risk` and bucketed into P0–P3 priority tiers. Targeted mode produces an inline report; whole-codebase mode writes a prioritised `milestones/M-audit-YYYY-MM.md` and appends a milestone entry to `ROADMAP.md`.
- **`/g-optimize [path|all]`** — performance audit skill. Detects O(n²) nested loops, N+1 queries, regex construction in hot functions, deep clones on state change, re-render waste (React inline object props, Vue whole-store subscriptions), listener/timer leaks without cleanup, and whole-library imports. Stack-aware: UI checks only run when a UI framework is detected; N+1 checks only when an ORM is detected. Same two-mode output and roadmap integration as `/g-audit`.
- **`/g-refactor [path|milestone]`** — guided refactor orchestration skill. Accepts a file/path scope or an audit/optimize milestone file. Pipeline: test coverage check (offers `test-writer` if thin) → parallel pre-analysis (`code-reviewer` + `architecture-enforcer`) → `spec-writer` dispatch → human approval gate → wave execution via `refactor-executor` with Tier 1 gates between waves → `/g-review` merge gate → milestone file updated if launched from an audit milestone.
- **Live stable/LTS research in `/g-specialize`** — new Step 2 runs `WebSearch` for each detected stack before installation. Scope is strict: stable and LTS releases only; alpha/beta/RC/canary/experimental results are ignored. Findings (confirmed version, material best-practice changes since prior major) are shown in the confirmation prompt and appended as a dated addendum to the installed architect agent file.
- **Astro island combo profiles** — three new combo profiles (`astro-react`, `astro-vue`, `astro-svelte`) covering patterns that emerge only when using island frameworks with Astro: island placement convention (`src/islands/` not `src/components/`), serializable prop contract, island isolation rules (React Context / Pinia instances don't cross island boundaries), cross-island state strategy (nanostores for React and Vue; native Svelte module-scope stores also work for Svelte islands), hydration directive defaults (`client:visible` not `client:load`), and the callout that `$app/*` SvelteKit APIs are unavailable in Astro context.

### Fixed

- **`next-js` architect agent filename** — `g-specialize` referenced `next-architect.md`; actual file is `next-js-architect.md`. Would have silently failed to install the Next.js architect on every project.
- **React Router v7 not detected** — Remix rebranded to React Router v7 (`react-router` package + `@react-router/dev` in devDependencies, or `react-router.config.ts` present). Added detection path mapping to the existing `remix` profile (file-based routing + loader/action architecture is identical).

- **`/g-docs [path|all]`** — documentation audit and generation skill. Scans for missing or stale JSDoc/docstrings, missing module headers, incomplete README sections, undocumented environment variables, CHANGELOG gaps, missing ADRs, and absent API reference docs. Targeted mode invokes `doc-writer` on each gap immediately. Whole-codebase mode produces a prioritised debt report (P0–P2) and optionally writes a `milestones/M-docs-YYYY-MM.md` roadmap entry.
- **`/g-adr [title]`** — architectural decision record skill. Interactive five-question flow (context, decision, alternatives, consequences, status) writes a standard ADR to `docs/decisions/NNN-title.md`. Auto-suggests follow-up actions (CLAUDE.md update, project_brief.md tech table, superseding previous ADRs). Auto-suggested by `spec-writer` when a task involves an architectural choice.
- **`G-RULES.md §G — Documentation Standards`** — new section covering all documentation layers: code-level (JSDoc/docstrings/doc comments, module headers, format by language), architecture-level (ADRs in `docs/decisions/`, currency rule), project-level (README completeness checklist, CHANGELOG currency, env var reference), API-level (OpenAPI spec, SDK reference), and operational-level (deployment guide, runbook). Currency rule: any PR that changes a signature, behaviour, or public API must update the corresponding docs in the same PR. Former §G (Testing Protocol) renumbered to §H.

### Changed

- `G-RULES.md` §B maintenance skills table updated with `/g-audit`, `/g-optimize`, `/g-refactor`, `/g-docs`, `/g-adr` entries.
- `G-RULES.md` Project Tracking file hierarchy updated with `docs/decisions/`, `docs/env-vars.md`, and `CHANGELOG.md` entries.
- `agents/code-reviewer.md`: added Documentation coverage checklist — missing public API docs (Major), stale docs (Major), missing README update (Major), missing CHANGELOG entry (Major), missing env var documentation (Major), missing ADR (Major), missing module header (Minor), redundant docs (Minor).
- `agents/review-orchestrator.md`: added conditional `doc-writer` dispatch when diff touches exported symbols — writes missing/stale JSDoc in the same review pass rather than issuing a HOLD.
- `agents/spec-writer.md`: added Documentation done conditions section — JSDoc for new exports, README for user-facing features, env var reference, ADR for architectural decisions, CHANGELOG entry for significant changes.
- `g-specialize` combo detection table and combo file mapping extended with the three Astro combos.
- README: skill count 17 → 22, combo profile count 4 → 7, command list updated.

---

## [0.3.5a] — 2026-05-08

### Fixed

- `g-team-init` Step 7: hook commands now use `bash -c 'bash "$(git rev-parse --git-common-dir)/../.claude/hooks/X.sh"'` instead of bare relative paths — resolves hook lookup failures when Claude Code runs inside a git worktree (worktree CWD ≠ main repo root where `.claude/hooks/` lives)

## [0.3.4] — 2026-05-06

### Added

- `G-RULES.md` Section G — Testing Protocol: three-tier test model (Tier 1 automated gates / Tier 2 tooling-assisted / Tier 3 human-driven); QA panel integration policy (scope doc per milestone, currency enforcement as a hard done condition); Tier 3 listen-mode protocol with `.claude/tier3-active` state file
- `g-team-plan` Step 0: Tier 3 DoD prerequisite — asks if project has a QA panel, compiles `docs/qa-scope/<milestone-slug>.md` mapping in-scope groups to pass criteria; no Tier 3 DoD = milestone not started
- `g-team-plan` Step 2: task-decomposer now receives QA panel context; any task adding or changing user-facing surface must include "QA panel updated" as an explicit done condition
- `workflow-checkpoint.sh`: surfaces Tier 3 listen mode status and logged bug count when `.claude/tier3-active` exists — fires on every prompt so listen mode is never invisible

### Changed

- README: G-RULES.md section count updated to seven; Section G added to table; `workflow-checkpoint.sh` description updated; `/g-team plan` description updated in Skills table and Playbook

## [0.3.3a] — 2026-05-05

### Fixed

- `g-team-specialize` Step 4: replaced fragile "go up two directory levels" path navigation with the same Glob-based plugin root discovery used by `g-team-update` — fixes profile lookup failures (affected tauri and all other profiles) when the plugin cache path structure differed from what the agent navigated manually

## [0.3.3] — 2026-05-05

### Added

- `claude-plugin` stack profile: architect agent (`profiles/claude-plugin/agents/claude-plugin-architect.md`) validates skill structure, command routing, agent format, hook design, and manifest; architecture rules (`profiles/claude-plugin/rules/architecture.md`) cover all 6 layers with explicit Skill, Agent, Command, and Version rules
- `/g-team skill-design` — 7-step skill for designing new skills from scratch: gather requirements, check for duplicates, draft and confirm step outline, write SKILL.md, write command file, update router, report
- `/g-team skill-validate [name]` — 6-step skill for validating skills and agents against structural rules: ✓/✗ checklist across SKILL.md, command file, router registration, and agent frontmatter; issues VALID or NEEDS FIXES verdict
- `g-team-specialize`: added `claude-plugin` to supported stacks list, detection via `.claude-plugin/plugin.json` or `plugin.json` schema field, and Step 4 file mapping

## [0.3.2] — 2026-05-05

### Added

- Branch discipline enforced: `G-RULES.md` Section D requires feature branches (`feat/`, `fix/`, `refactor/`, `chore/<slug>`) for non-trivial work; MERGE READY on a branch triggers merge/PR to main; direct main commits limited to hotfixes, docs, and version bumps
- `workflow-checkpoint.sh` now reports current branch name on every message; warns to stderr when on `main` or `master`
- `check-commit.sh` adds a non-blocking advisory when committing directly to `main` with approval
- `project-manager` agent gains a **Feature Challenge gate**: asks 3 questions before accepting any new feature scope; bug fixes and refactors are exempt; one round, one verdict, then proceeds
- `g-team-plan` Step 1 now dispatches project-manager challenge before task-decomposer fires (bug fixes/refactors skip it)
- `g-team-review` Step 1 now runs the full test suite before any code review; test failures produce immediate HOLD with no sentinel write; no-test-suite case requires explicit test-writer dispatch or one-time developer override
- `test-writer` agent expanded: now covers unit, integration, and e2e tests; chooses test type based on what is being tested; handles projects with no obvious test framework by asking the developer

### Fixed

- G-RULES.md Section D branch discipline replaced generic "never commit to main" with specific naming convention, MERGE READY flow, and main-branch exception list
- `skills/g-team-init/SKILL.md` hook templates synced with updated live scripts

## [0.3.1] — 2026-05-04

### Added

- `g-team-doctor` expanded from 7 to 9 checks: added `post-commit-cleanup.sh` hook check, `G-RULES.md` present check, `@G-RULES.md` referenced in `CLAUDE.md` check

### Fixed

- `g-team-update`: `post-commit-cleanup.sh` now created and registered if missing (previously skipped silently — pre-0.3.0 projects would never get it installed)
- `g-team-doctor` check 4 fix instruction: now correctly references `/g-team init` as well as `/g-team update`
- `g-team-doctor` check 5 fix instruction: corrected from "Run `/g-team update`" to "Run `/g-team init` or `/g-team update`"
- ROADMAP.md: updated to reflect M6-M8 milestones (was stale at M1-M5 only)

## [0.3.0] — 2026-05-04

### Added

- Section F — Design Patterns in `G-RULES.md`: 6 universal principles (composition over inheritance, explicit over implicit, YAGNI, fail-fast at boundaries, observer/event-driven, state machine for discrete modes) and 8 anti-patterns refused by default
- Object pooling and state machine architecture rules in all 5 game-dev profiles: `unity`, `godot-gdscript`, `godot-csharp`, `unreal`, `cpp-cmake`
- `G-RULES.md` now installed per-project by `/g-team init` (Step 2a) — `@G-RULES.md` reference added to `CLAUDE.md`
- `/g-team update` now refreshes per-project `G-RULES.md` from plugin (Step 3a)
- `/g-team doctor` — 7-point health check: hooks installed, all hooks registered in settings.json, G-Forge Rules block present, no stale sentinel, milestone alignment

### Fixed

- `g-team-kickoff` Step 7: removed false claim that `/g-team init` auto-triggers plan/execute/review in sequence
- `g-team-review` Step 2: fixed stale path `docs/superpowers/plans/*.md` → `docs/plans/`
- `g-team-plan` Step 5: removed user-facing reference to `superpowers:dispatching-parallel-agents`
- `code-reviewer` agent: added Section F anti-patterns to "What to look for" (god object, prop drilling, business logic in UI, mutable state, premature abstraction, magic values, catch-and-continue)
- `architecture-enforcer` agent: added circular dependency detection and god object violation checks
- `go-fiber` architect agent filename collision with `go-gin` profile (renamed to `go-fiber-architect.md`)
- `g-team-update` Step 7: now verifies and adds UserPromptSubmit hook in settings.json when `workflow-checkpoint.sh` already exists
- `marketplace.json`: corrected agent and skill counts

### Changed

- README fully rewritten for 0.3.0: G-RULES.md section, Section F callout, game-dev profile notes, all 3 commit hooks documented, complete skills and agents tables

## [0.2.8] — 2026-05-04

### Fixed

- `g-team-execute` Step 4: now immediately invokes `/g-team review` via Glob+Read after all waves complete (was previously a print suggestion only)
- `g-team-execute` rules: explicit prohibition on instructing subagents to run `git commit`
- `g-team-execute` Step 2: wave auto-detection now reads Progress table in plan file (4 rules: absent/all-pending→Wave1, all-complete→stop, in-progress→confirm, mix→auto-resume)
- G-RULES.md Section B: added commit prohibition to hard stops; updated auto-trigger language

## [0.2.7] — 2026-05-04

### Added

- `/g-team doctor` skill — 7-point health check with ✓/✗ per check and fix instructions
- CHANGELOG.md — change history tracking from 0.1.0

### Fixed

- `g-team-help`: added missing "Review pending" workflow phase; 7th source is git branch; `/g-team help` added to All commands table
- `g-team-brief`: added missing announce line; guard check moved to top of Step 1
- `g-team-plan`: Progress table initial values corrected to `pending`

## [0.2.6] — 2026-05-04

### Added

- `/g-team help` — context-aware state reader; detects workflow phase and outputs next action + full command reference
- `/g-team status` — fast structured snapshot: milestone, active plan/wave, review gate, handoff line
- `/g-team brief` — incremental project_brief.md refresh; targeted Q&A, no full re-onboard
- Plan file format schema: approved plans saved to `docs/plans/<feature-slug>.md` with Tasks, Wave Schedule, and Progress tables
- `workflow-checkpoint.sh` now parses plan file to report current wave number and total waves
- g-team-review auto-closes completed milestone tasks and updates ROADMAP.md on MERGE READY

### Fixed

- g-team-kickoff: aligned auto-trigger language with rest of plugin

## [0.2.5] — 2026-05-04

### Added

- `workflow-checkpoint.sh` UserPromptSubmit hook: fires on every message, reports active plan and review state
- plan/execute/review now auto-triggered — Claude initiates them without user typing commands
- G-Rules compact block updated with auto-trigger language
- `/g-team update` installs `workflow-checkpoint.sh` on existing projects and registers UserPromptSubmit hook

## [0.2.4] — 2026-05-04

### Fixed

- Compact G-Rules block (injected by `/g-team init`) now explicitly names `/g-team-execute` and prohibits `superpowers:dispatching-parallel-agents`
- `g-team-execute` SKILL.md gains authority assertion declaring it the sole wave dispatcher

## [0.2.3] — 2026-05-03

### Added

- `/g-team execute` skill for wave-based agent swarming
- `/g-team update` skill to realign installed project files to current plugin version
- G-RULES.md now tracked in git (was previously gitignored)

### Fixed

- Removed all `Skill(...)` tool invocations from all command and skill files — were causing infinite "Launching skill" loops with no content loaded
- All commands now use Glob+Read pattern on SKILL.md directly
- Removed `argument-hint` from SKILL.md frontmatter files (was preventing skill content from loading)

## [0.2.1] — 2026-05-03

### Added

- `/g-team onboard` — fully rewritten to handle mature projects; maturity classification (mature/early-stage/greenfield); resolves existing `.claude/rules`, `.claude/agents`, `CLAUDE.md` conflicts before interviewing; targeted interview for mature projects

## [0.2.0] — 2026-05-03

### Added

- 44 stack profiles (up from 3): covers Web Frontend, Node/Go/Rust Backend, Python/Ruby/PHP, JVM/.NET, Mobile/Desktop, Game Dev & Systems
- Each profile has a stack-specific architect agent and architecture rules
- Auto-detection from dependency files (`package.json`, `requirements.txt`, `Cargo.toml`, etc.)

## [0.1.0] — initial release

### Added

- Core plugin structure: `commands/`, `skills/`, `agents/`, `profiles/`, `hooks/`
- 16 specialist agents: task-decomposer, wave-planner, spec-writer, code-reviewer, security-auditor, architecture-enforcer, performance-auditor, debugger, error-detective, project-manager, review-orchestrator, code-lead, test-writer, doc-writer, pr-writer, refactor-executor
- Skills: kickoff, init, specialize, plan, review
- Commit enforcement: PreToolUse hook blocks git commit without `.claude/g-team-approved` sentinel
- G-RULES.md: full session discipline rules (models, workflow, agent discipline, code quality, architecture gate, project tracking)
- 3 initial stack profiles: vue-pinia, node-ts, fastapi
