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
