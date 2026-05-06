@G-RULES.md

# G-Team

Multi-agent Claude Code plugin — planned execution, production architecture, enforced review.

<!-- G-Team Rules — injected by /g-team init. Do not edit manually. -->
## G-Team Workflow

**Models**: Haiku for reads/search · Sonnet for implementation · Opus only after 2 failed attempts on the same task.

**Workflow — auto-triggered, no command needed**:
Claude detects task complexity and initiates the workflow automatically — never wait for the user to type a command:
- Non-trivial task? (≥3 files, new feature, layer-boundary change, unclear bug, public API change) → run `/g-team plan` before any file changes
- Plan approved → run `/g-team execute` to dispatch waves
- Implementation complete / user wants to merge → run `/g-team review`
All three steps are mandatory. Skipping any requires explicit developer override.

**Agent discipline**: HQ orchestrates only — dispatches agents, collects results, integrates. Never does grunt work an agent can do. Hard limit: 7 agents per task.

**Architecture gate**: ≥3 files, layer-boundary change, new component, or public API change → plan first (no writes), validate import directions, verify state ownership, get sign-off.

**Commit rule**: `git commit` is HQ-only, after MERGE READY. Never instruct subagents to commit — they implement and return results only. HQ commits once after review clears.

**Hard stops**: No merge without MERGE READY · No plan skip for non-trivial tasks · HOLD = fix all blocking items, re-review · Same bug class × 3 attempts = stop, escalate, try a different mechanism.
<!-- End G-Team Rules -->

<!-- G-Team claude-plugin Architecture Rules — injected by /g-team specialize. Do not edit manually. -->
## Claude Code Plugin Architecture Rules

**Layer map:**
- `commands/` — thin routing .md files; Glob+Read to SKILL.md; no hardcoded logic; no Skill() calls
- `skills/<name>/SKILL.md` — multi-step workflow instructions; no Skill() invocations; must have Announce line and Rules section; no argument-hint in frontmatter
- `agents/` — specialist .md agents; Read, Glob, Grep tools only; output findings, never fixes; must include name, description, model, tools frontmatter
- `profiles/<stack>/` — stack architect agent + architecture rules; installed per-project by /g-team specialize; architect agent must be read-only
- `hooks/` — standalone bash scripts; read stdin JSON; exit 1 to block; no Claude runtime dependency; must have #!/bin/bash shebang
- `.claude-plugin/` — plugin.json + marketplace.json; schema-valid; version numbers must match across both files

**Skill rule:** Every SKILL.md must have: YAML frontmatter (name + description only — no argument-hint), `**Announce:**` line immediately after frontmatter, numbered steps (`## Step N —`), and a `## Rules` section. No Skill() tool calls anywhere in skill files.

**Agent rule:** Agents are reviewers only. Tools: Read, Glob, Grep — never Write, Edit, or Bash. Must include name, description, model, tools in frontmatter. Output format must distinguish BLOCKING, WARNING, and PASS findings.

**Command rule:** Command files are routers only. Must Glob+Read the corresponding SKILL.md inside the plugin cache. Never embed instructions or skill content directly in the command file.

**Version rule:** `.claude-plugin/plugin.json` version and `marketplace.json` plugin version must be identical on every release.
<!-- End G-Team claude-plugin Architecture Rules -->
