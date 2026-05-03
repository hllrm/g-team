---
name: g-team-specialize
description: Determine which stack profiles to apply by reading the project brief, roadmap, and dependency files. Handles multi-stack projects. Consults code-lead when the picture is ambiguous or risky. Installs architect agents and architecture rules. Supported stacks: vue-pinia, node-ts, fastapi.
argument-hint: [stack]
---

**Announce:** "Using g-team-specialize to apply the stack profile."

You are wiring stack-specific architect agents into this project. The agent files and rules will be project-native after this runs — no plugin dependency required.

## Step 1 — Gather context

Build a picture of the project's stack and integrations from all available sources. Read every source that exists — skip silently if a file is absent.

**Source 1 — project_brief.md (highest confidence)**

Read `project_brief.md` if it exists. Extract:
- The "Tech decisions" table — each row is a confirmed stack component
- The "Technical constraints" section if present
- Any stack names mentioned in the text

Note every distinct runtime/framework/language. A project might have multiple (e.g., Vue 3 frontend + FastAPI backend in a monorepo).

**Source 2 — ROADMAP.md**

Read `ROADMAP.md` if it exists. Look for tech mentions in milestone descriptions or backlog items that indicate planned stack additions not yet in deps.

**Source 3 — Dependency files**

Read whichever of these exist in the current working directory:
- `package.json` — check `dependencies` and `devDependencies`
  - Contains `vue` + `pinia` → vue-pinia candidate
  - Contains `typescript` or `ts-node` + (`express` or `fastify` or `koa` or `hono`) → node-ts candidate
  - Contains `typescript` or `ts-node` without a web framework → node-ts candidate (flag: no web framework detected)
- `requirements.txt` or `pyproject.toml` — read full contents
  - Contains `fastapi` → fastapi candidate
  - Contains `flask` or `django` → note as unsupported stack

**Synthesise:**

After reading all sources, build this picture:
```
Stacks detected:    [list — e.g. vue-pinia, fastapi]
Source confidence:  [brief / deps / roadmap / inferred]
Unsupported stacks: [list — e.g. django]
Conflicts:          [e.g. "brief says Vue 3, no package.json found yet"]
Profiles to apply:  [list of supported stacks to install]
```

## Step 2 — Handle edge cases before confirming

**If an explicit stack argument was provided** (e.g. `/g-team specialize vue-pinia`):
- Validate it is one of: `vue-pinia`, `node-ts`, `fastapi`. If not, say: "Unknown stack '[arg]'. Supported: vue-pinia, node-ts, fastapi." and stop.
- Use this as the confirmed profile list, skipping further detection.

**If no brief and no dependency files exist:**
- Ask the developer: "I couldn't find a project_brief.md or any dependency files. Which profile(s) should I apply? Options: vue-pinia, node-ts, fastapi"
- Wait for answer. Use it as the confirmed profile list.

**If unsupported stacks were detected (flask, django, etc.):**
- Note them in the confirmation: "I detected [stack] which doesn't have a G-Team profile yet. I'll skip that one. Supported: vue-pinia, node-ts, fastapi."

**If the picture is ambiguous or there are conflicts:**

Ambiguous means: stacks detected from different sources that don't agree, or a brief that mentions a stack with no corresponding deps and no clear explanation.

Before asking the user, dispatch `code-lead` with:
- The synthesised picture from Step 1
- The relevant excerpt from project_brief.md (tech decisions table if present)
- The dependency file contents

Ask code-lead:
> "Based on this project's brief and dependencies, which G-Team stack profiles should be applied? The options are: vue-pinia, node-ts, fastapi. If the project is multi-stack, list all that apply. Flag anything that looks like a mismatch or a risky stack choice."

Present code-lead's response to the developer: "Here is code-lead's stack read — does this match what you're building?"

**If the brief lists a stack with a code-lead risk flag (Medium or High):**
- Surface it to the developer before proceeding: "code-lead flagged [stack choice] as [risk level]: [reason]. Do you want to proceed with this profile, or reconsider the stack first?"
- Wait for answer. Proceed only after confirmation.

## Step 3 — Confirm with developer

Present the full list of profiles to apply:

```
Based on [brief / deps / your input], I'll apply these profiles:

  • vue-pinia  →  vue-architect agent + Vue 3 + Pinia architecture rules
  • fastapi    →  fastapi-architect agent + FastAPI architecture rules

This will:
  ✦ Write [N] agent file(s) to .claude/agents/
  ✦ Append architecture rules for each stack to CLAUDE.md

Continue? (y/n)
```

Wait for confirmation before writing anything.

## Step 4 — Locate profile files

For each profile to apply:

The profile files live in the g-team plugin directory. The base directory of this skill is shown at the top of your context as "Base directory for this skill: [path]".

Navigate from that path: go up two directory levels to reach the plugin root, then look in `profiles/[stack]/`.

For example, if the base directory is `/home/user/.claude/plugins/cache/hllrm-g-team/skills/g-team-specialize`, the plugin root is `/home/user/.claude/plugins/cache/hllrm-g-team/` and the vue-pinia profile is at `/home/user/.claude/plugins/cache/hllrm-g-team/profiles/vue-pinia/`.

Stack → file mapping:
- `vue-pinia`  →  `profiles/vue-pinia/agents/vue-architect.md`  +  `profiles/vue-pinia/rules/architecture.md`
- `node-ts`    →  `profiles/node-ts/agents/node-architect.md`   +  `profiles/node-ts/rules/architecture.md`
- `fastapi`    →  `profiles/fastapi/agents/fastapi-architect.md` + `profiles/fastapi/rules/architecture.md`

Read both files for each profile before writing anything.

## Step 5 — Write agents to .claude/agents/

Create `.claude/agents/` directory if it does not exist.

For each profile:

Write the agent file content to `.claude/agents/[agent-name].md`.

Agent filename mapping:
- `vue-pinia` → `.claude/agents/vue-architect.md`
- `node-ts`   → `.claude/agents/node-architect.md`
- `fastapi`   → `.claude/agents/fastapi-architect.md`

If the file already exists, read it first. If the `name:` field in frontmatter matches, tell the developer: "[agent-name] is already installed. Overwrite? (y/n)" and wait for confirmation before proceeding.

## Step 6 — Append architecture rules to CLAUDE.md

Read `CLAUDE.md` in the current project root. If it does not exist, create it with just a `# [Project]` header first.

For each profile, check whether rules are already present by searching for `<!-- G-Team [stack] Architecture Rules -->`. If found, tell the developer: "Architecture rules for [stack] already in CLAUDE.md. Skipping." and skip that profile's rules.

For each profile whose rules are not yet present, append:

```
<!-- G-Team [stack] Architecture Rules — injected by /g-team specialize. Do not edit manually. -->
[full content of profiles/[stack]/rules/architecture.md]
<!-- End G-Team [stack] Architecture Rules -->
```

## Step 7 — Report

```
Stack profiles applied ✓

  ✓ .claude/agents/vue-architect.md    — vue-pinia architect installed
  ✓ .claude/agents/fastapi-architect.md — fastapi architect installed
  ✓ CLAUDE.md — Vue 3 + Pinia architecture rules appended
  ✓ CLAUDE.md — FastAPI architecture rules appended

These agents are now project-native. They will appear in Claude Code's agent list.
Dispatch them during any review or planning task that touches their stack.
```

List only the profiles that were actually applied.

## Rules
- Never write any file before the developer confirms in Step 3.
- Never overwrite an existing agent without user confirmation.
- Profile files are read from the plugin directory — never embedded or hardcoded here.
- If the plugin directory cannot be located, tell the developer the expected path and ask them to verify the plugin is installed.
- code-lead is consulted only when the picture is ambiguous or a brief flags a risky stack choice — not on every run.
- If the developer provides an explicit stack arg, skip all detection and go straight to Step 3.
