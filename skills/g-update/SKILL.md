---
name: g-update
description: Realign all g-team-managed files in this project to the current plugin version. Updates the G-Team Rules block in CLAUDE.md, all installed architect agents, all installed architecture rules, and commit hooks. Safe — only touches content between g-team markers.
---

**Announce:** "Using g-update to pull the latest plugin from GitHub and realign project files."

You are first updating the plugin cache from GitHub, then syncing g-team-managed content in this project against it. You only touch content that g-team originally injected — never user-written content.

---

## Step 0 — Update the plugin

1. Fetch the latest version from GitHub:
   ```bash
   curl -sf --max-time 10 https://raw.githubusercontent.com/hllrm/g-team/main/.claude-plugin/plugin.json | grep '"version"'
   ```
   If curl fails (no network, timeout), report: "⚠ Could not reach GitHub — skipping plugin update, syncing from installed cache." and continue to Step 1.

2. Find the installed version using Glob on `~/.claude/plugins/cache/g-team/g-team` for any `plugin.json` inside `.claude-plugin/`. Read it and extract the version. If nothing found, continue to Step 1.

3. If versions match, report: "Plugin already at latest ([version]) — proceeding with project sync." and continue to Step 1.

4. If they differ, run the plugin update:
   ```bash
   claude plugin update g-team
   ```

5. After the update attempt, re-fetch the installed version (same Glob as step 2) and compare to the GitHub version again.
   - If now matching: report `✓ Plugin updated [old] → [new]` and continue to Step 1.
   - If still behind: report:
     ```
     ⚠ Plugin is still at v[installed] — /plugin update did not pick up v[latest].
     To force the update:
       /plugin marketplace add hllrm/g-team
       /plugin install g-team
     Then re-run /g-update.
     ```
     Ask: "Continue syncing project files from the currently installed v[installed]? (y/n)"
     Wait for answer. On yes → continue to Step 1. On no → stop.

---

## Step 1 — Locate the plugin root

Use Glob to find the plugin's skill files:
```
~/.claude/plugins/cache/g-team/g-team/*/skills/g-init/SKILL.md
```

The parent of the `skills/` directory is the plugin root. Store this path — you will need it throughout.

If not found, tell the developer: "Could not find the g-team plugin in ~/.claude/plugins/cache/. Run `/plugin update g-team` first." and stop.

---

## Step 2 — Inventory what's installed in this project

Read and record:

**CLAUDE.md:**
- Does `<!-- G-Team Rules` marker exist? Note current content between markers.
- How many `<!-- G-Team [stack] Architecture Rules` blocks exist? List each stack name found.

**.claude/agents/:**
- List all `.md` files. For each, read the `name:` field from frontmatter.
- Flag any whose name matches a known g-team architect pattern: `*-architect` or `node-architect`.

**.claude/rules/:**
- List all `.md` files if directory exists.

**.claude/hooks/check-commit.sh:**
- Note if present.

**.claude/hooks/workflow-checkpoint.sh:**
- Note if present.

**G-RULES.md:**
- Note if present at project root.

Present a summary:
```
Installed g-team content:

  CLAUDE.md:
    G-Team Rules block:   [present / not found]
    Architecture stacks:  [vue-pinia, fastapi, ... / none]

  .claude/agents/:         [vue-architect.md, fastapi-architect.md, ... / none]
  .claude/rules/:          [architecture-vue-pinia.md, ... / none]
  .claude/hooks/:          [check-commit.sh present / not found] [workflow-checkpoint.sh present / not found]
  G-RULES.md:              [present / not found]
```

Ask: **"Ready to update all of the above to the current plugin version? (y/n)"**

Wait for confirmation.

---

## Step 3 — Update G-Team Rules block in CLAUDE.md

Read `[plugin-root]/skills/g-init/SKILL.md`.

Extract the content between:
```
<!-- G-Team Rules — injected by /g-init. Do not edit manually. -->
```
and:
```
<!-- End G-Team Rules -->
```
(inclusive of both marker lines).

Read `CLAUDE.md`. Find the same marker block. Replace it entirely with the extracted content from the plugin.

If the marker is not present in CLAUDE.md, append the block at the end of the file.

Report: `✓ CLAUDE.md — G-Team Rules updated`

---

## Step 3a — Update G-RULES.md

Read `[plugin-root]/G-RULES.md`.

If `G-RULES.md` exists at the project root: overwrite it with the plugin version.
If it does not exist: copy it from the plugin. Also ensure `CLAUDE.md` has `@G-RULES.md` near the top.

Report: `✓ G-RULES.md — realigned`

---

## Step 4 — Update architecture rules in CLAUDE.md

For each `<!-- G-Team [stack] Architecture Rules` block found in Step 2:

1. Extract the stack name from the marker (e.g. `vue-pinia`, `fastapi`)
2. Read the current rules from `[plugin-root]/profiles/[stack]/rules/architecture.md`
3. In CLAUDE.md, replace everything between:
   ```
   <!-- G-Team [stack] Architecture Rules — injected by /g-specialize. Do not edit manually. -->
   ```
   and:
   ```
   <!-- End G-Team [stack] Architecture Rules -->
   ```
   with the fresh content from the plugin (keeping both marker lines).

If a stack's profile no longer exists in the plugin (removed), tell the developer and skip it — do not delete the block.

Report: `✓ CLAUDE.md — [stack] architecture rules updated` for each stack.

---

## Step 5 — Update architect agents in .claude/agents/

For each g-team architect agent file found in Step 2:

1. Determine which profile it came from by matching the `name:` frontmatter field against the plugin's profile agent filenames:
   - Read each file in `[plugin-root]/profiles/*/agents/*.md`
   - Match by `name:` field
2. Replace the file content with the current version from the plugin.

If a match cannot be found (agent name doesn't match any current profile), tell the developer: "Could not find a current profile for `[name]` — skipping. It may have been renamed or removed." Do not delete the file.

Report: `✓ .claude/agents/[filename] — updated` for each agent.

---

## Step 6 — Update .claude/rules/ files

For each file in `.claude/rules/`:

1. Try to match it to a profile rules file in `[plugin-root]/profiles/*/rules/architecture.md` by reading the file content and comparing stack signatures (first heading or content keywords).
2. If matched, replace with the current plugin version.
3. If not matched (user-created rule file), skip it and report: "Skipping `.claude/rules/[filename]` — does not appear to be g-team managed."

Report: `✓ .claude/rules/[filename] — updated` for each updated file.

---

## Step 7 — Update hook scripts

Read `[plugin-root]/skills/g-init/SKILL.md` once. Extract each hook script's content from the code blocks in the init skill.

**check-commit.sh:** If `.claude/hooks/check-commit.sh` exists, replace with the extracted content. Report: `✓ .claude/hooks/check-commit.sh — updated`. If not present, skip silently.

**post-commit-cleanup.sh:** Two cases:

- **File exists:** Replace with the extracted content. Report: `✓ .claude/hooks/post-commit-cleanup.sh — updated`.
- **File does not exist:** Create it (along with `.claude/hooks/` if needed), write the content, and register the `PostToolUse` hook in `.claude/settings.json` if not already present (same merge-not-overwrite pattern as other hooks). Report: `✓ .claude/hooks/post-commit-cleanup.sh — created and registered`.

**workflow-checkpoint.sh:** Two cases:

- **File exists:** Replace with the extracted content. Report: `✓ .claude/hooks/workflow-checkpoint.sh — updated`. Then check whether `.claude/settings.json` already contains a `UserPromptSubmit` hook entry whose command references `workflow-checkpoint.sh`. If it does not, add it using the same merge-not-overwrite pattern (read the current JSON, insert the hook under `hooks.UserPromptSubmit`, write back without touching other keys). Report: `✓ .claude/settings.json — UserPromptSubmit hook verified` only if the entry was missing and was just added.

- **File does not exist:** Create it (along with `.claude/hooks/` if needed), write the content, and also register the `UserPromptSubmit` hook in `.claude/settings.json` if it isn't already present. Report: `✓ .claude/hooks/workflow-checkpoint.sh — created and registered`.

---

## Step 8 — Report

```
g-team update complete ✓

  ✓ CLAUDE.md — G-Team Rules realigned
  ✓ G-RULES.md — realigned
  ✓ CLAUDE.md — vue-pinia architecture rules realigned
  ✓ .claude/agents/vue-architect.md — realigned
  ✓ .claude/hooks/check-commit.sh — realigned
  ✓ .claude/hooks/workflow-checkpoint.sh — realigned
  [skipped] .claude/rules/my-custom-rules.md — not g-team managed

All g-team-managed content is now at plugin version [read version from plugin-root/.claude-plugin/plugin.json].
```

If nothing needed updating (all content already matched): "All g-team-managed content is already up to date."

---

## Rules

- Never modify content outside g-team markers in CLAUDE.md.
- Never delete or overwrite files not identified as g-team-managed.
- Never run without developer confirmation from Step 2.
- If the plugin root cannot be found, stop and tell the developer.
- Read the plugin files fresh each time — never use cached or assumed content.
