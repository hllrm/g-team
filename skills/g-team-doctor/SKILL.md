---
name: g-team-doctor
description: Health check for g-team project setup. Verifies hooks, settings, CLAUDE.md rules block, commit sentinel, plan files, and milestone alignment. Reports ✓/✗ per check with fix instructions.
---

Announce: "Using g-team-doctor to check project health."

Run all 7 checks below against the current working directory, then output the report in the exact format specified.

## Checks

**1. commit hook**
Check if `.claude/hooks/check-commit.sh` exists.
- Pass: ✓ commit hook installed
- Fail: ✗ commit hook missing
  → Run `/g-team init` to install hooks.

**2. workflow hook**
Check if `.claude/hooks/workflow-checkpoint.sh` exists.
- Pass: ✓ workflow hook installed
- Fail: ✗ workflow hook missing
  → Run `/g-team update` to install the workflow checkpoint hook.

**3. PreToolUse registered**
Read `.claude/settings.json` and check if it contains a `PreToolUse` hook entry pointing to `check-commit.sh`.
- Pass: ✓ PreToolUse hook registered
- Fail: ✗ PreToolUse hook not registered
  → Run `/g-team init` or `/g-team update` to register the commit gate hook.

**4. UserPromptSubmit registered**
Read `.claude/settings.json` and check if it contains a `UserPromptSubmit` hook entry pointing to `workflow-checkpoint.sh`.
- Pass: ✓ UserPromptSubmit hook registered
- Fail: ✗ UserPromptSubmit hook not registered
  → Run `/g-team update` to register the workflow checkpoint hook.

**5. G-Team Rules block**
Read `CLAUDE.md` and check if it contains the string `<!-- G-Team Rules`.
- Pass: ✓ G-Team Rules block present in CLAUDE.md
- Fail: ✗ G-Team Rules block missing from CLAUDE.md
  → Run `/g-team init` to inject G-Team rules into CLAUDE.md.

**6. No stale sentinel**
Check if `.claude/g-team-approved` exists. It should NOT exist (it is auto-cleared after each commit).
- Pass (file absent): ✓ No stale approval sentinel
- Fail (file present): ✗ Stale approval sentinel found
  → A stale approval sentinel exists. Delete it: `rm .claude/g-team-approved`

**7. Milestone alignment**
If `milestones/` does not exist, skip this check and report ✓ Milestone check skipped (no milestones/ directory).
Otherwise, read `ROADMAP.md` and find all entries marked `🚧 In progress`. For each such entry, derive a slug (lowercase, spaces replaced with hyphens, non-alphanumeric characters removed) and check if a corresponding file exists in `milestones/`. If all present (or none are in-progress):
- Pass: ✓ Milestone files aligned with ROADMAP.md
- Fail (one or more missing): ✗ Milestone file missing for [name]
  → Create `milestones/[slug].md` or run `/g-team init`.
  (Report one ✗ line per missing milestone file.)

## Output format

Print the report exactly as shown:

```
G-Team Doctor ─────────────────────────────────
  [✓/✗ line for check 1]
  [✓/✗ line for check 2]
  [✓/✗ line for check 3]
    [→ fix instruction if failed]
  [✓/✗ line for check 4]
    [→ fix instruction if failed]
  [✓/✗ line for check 5]
    [→ fix instruction if failed]
  [✓/✗ line for check 6]
    [→ fix instruction if failed]
  [✓/✗ line for check 7]
    [→ fix instruction if failed]
────────────────────────────────────────────────
[N/7 checks passed]
```

Fix instructions are indented with four spaces and prefixed with `→ `, and appear only on failing checks.

After the summary count line, add one blank line, then:
- If all checks passed: `All checks passed. Project is healthy.`
- If any check failed: `Fix the issues above, then re-run /g-team doctor.`
