---
name: g-team-doctor
description: Health check for g-team project setup. Verifies all 3 hooks installed, all hooks registered in settings.json, G-Team Rules block in CLAUDE.md, G-RULES.md present and referenced, no stale sentinel. Reports ✓/✗ per check with fix instructions.
---

Announce: "Using g-team-doctor to check project health."

Run all 9 checks below against the current working directory, then output the report in the exact format specified.

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
  → Run `/g-team init` or `/g-team update` to install the workflow checkpoint hook.

**3. post-commit hook**
Check if `.claude/hooks/post-commit-cleanup.sh` exists.
- Pass: ✓ post-commit hook installed
- Fail: ✗ post-commit hook missing
  → Run `/g-team init` or `/g-team update` to install the post-commit cleanup hook.

**4. PreToolUse registered**
Read `.claude/settings.json` and check if it contains a `PreToolUse` hook entry pointing to `check-commit.sh`.
- Pass: ✓ PreToolUse hook registered
- Fail: ✗ PreToolUse hook not registered
  → Run `/g-team init` or `/g-team update` to register the commit gate hook.

**5. UserPromptSubmit registered**
Read `.claude/settings.json` and check if it contains a `UserPromptSubmit` hook entry pointing to `workflow-checkpoint.sh`.
- Pass: ✓ UserPromptSubmit hook registered
- Fail: ✗ UserPromptSubmit hook not registered
  → Run `/g-team init` or `/g-team update` to register the workflow checkpoint hook.

**6. G-Team Rules block**
Read `CLAUDE.md` and check if it contains the string `<!-- G-Team Rules`.
- Pass: ✓ G-Team Rules block present in CLAUDE.md
- Fail: ✗ G-Team Rules block missing from CLAUDE.md
  → Run `/g-team init` to inject G-Team rules into CLAUDE.md.

**7. G-RULES.md present**
Check if `G-RULES.md` exists at the project root.
- Pass: ✓ G-RULES.md present
- Fail: ✗ G-RULES.md missing
  → Run `/g-team init` or `/g-team update` to install G-RULES.md.

**8. @G-RULES.md referenced in CLAUDE.md**
Read `CLAUDE.md` and check if it contains `@G-RULES.md`.
- Pass: ✓ @G-RULES.md reference present in CLAUDE.md
- Fail: ✗ @G-RULES.md reference missing from CLAUDE.md
  → Run `/g-team init` or `/g-team update` to add the @G-RULES.md reference.

**9. No stale sentinel**
Check if `.claude/g-team-approved` exists. It should NOT exist (it is auto-cleared after each commit).
- Pass (file absent): ✓ No stale approval sentinel
- Fail (file present): ✗ Stale approval sentinel found
  → A stale approval sentinel exists. Delete it: `rm .claude/g-team-approved`

**Note:** Milestone alignment is no longer a numbered check — it is contextual and covered by `/g-team status`. Doctor focuses on hook and rules infrastructure only.

## Output format

Print the report exactly as shown:

```
G-Team Doctor ─────────────────────────────────
  [✓/✗ line for check 1]
  [✓/✗ line for check 2]
    [→ fix instruction if failed]
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
  [✓/✗ line for check 8]
    [→ fix instruction if failed]
  [✓/✗ line for check 9]
    [→ fix instruction if failed]
────────────────────────────────────────────────
[N/9 checks passed]
```

Fix instructions are indented with four spaces and prefixed with `→ `, and appear only on failing checks.

After the summary count line, add one blank line, then:
- If all checks passed: `All checks passed. Project is healthy.`
- If any check failed: `Fix the issues above, then re-run /g-team doctor.`
