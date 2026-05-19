---
name: g-voice
description: Switch the G-Forge voice profile between `dev` (terse, jargon-dense — default), `mid` (explained-but-concise, glossary inline), and `eli5` (plain language, conversational). Writes `.claude/voice-profile`. Every G-Forge skill reads this and renders its output accordingly.
---

**Announce:** "Using g-voice to read or change the voice profile."

You manage how G-Forge talks to the developer. The profile changes rendering — never facts, never verdicts.

## Step 1 — Resolve intent

Inspect `$ARGUMENTS`:

1. **Empty** — read `.claude/voice-profile`. If absent, treat as `dev`. Print the status block (Step 5) including a 3-sample preview of how each profile renders the same example output. Do not write.
2. **One of `dev` / `mid` / `eli5`** — proceed to Step 2.
3. **Anything else** — print:
   ```
   ✗ Unknown profile '[arg]'. Valid: dev, mid, eli5.
   ```
   Stop.

## Step 2 — Apply the switch

Create `.claude/` if missing. Write the profile name as a single bare word followed by a newline to `.claude/voice-profile`. Overwrite any existing content.

## Step 3 — Confirmation rendering

The confirmation message is rendered using the profile value just written in Step 2 (no re-read needed — the value is known). This gives the developer an immediate sense of what they just opted into:

- `dev`:
  ```
  Voice: dev. Active.
  ```
- `mid`:
  ```
  Voice profile set to `mid`.
  Every skill report will now include a brief context sentence on important results — same facts, lightly explained.
  ```
- `eli5`:
  ```
  ✓ I'll talk to you in plain language from now on.

  When something important happens — a review passing, a risk surfacing,
  a wave finishing — I'll explain what it means, not just say the technical
  name for it. Same facts, plainer words.

  You can switch back any time with /g-voice dev (terse) or /g-voice mid
  (a middle ground).
  ```

## Step 4 — Show samples (read mode only)

If Step 1 was the read case, after printing the status block, render the same example report in all three profiles so the developer can compare. Use a short, neutral example like a `/g-review MERGE READY` summary. See `docs/voice-profiles.md` for canonical samples.

## Step 5 — Status block (read mode)

```
G-Forge voice status
  Active profile:  [dev / mid / eli5]
  Profile file:    .claude/voice-profile ([present / absent — using default])

  Samples — same content in each register:

  --- dev ---
  [terse sample]

  --- mid ---
  [explained sample]

  --- eli5 ---
  [plain-language sample]

  To switch:  /g-voice dev   |   /g-voice mid   |   /g-voice eli5
```

## Rules

- The voice profile changes **rendering only**. Never let a profile change the underlying verdict, the numeric values, or the file references in a skill report. A `HOLD` is a `HOLD` in every profile.
- All three profiles must surface the **same facts**. The eli5 profile adds explanation; it never withholds information that `dev` includes.
- File refs (`file:line`) appear in all three profiles. They are unconditionally useful and never replaced with prose.
- Switching is never destructive — no confirmation prompts, no warnings, no migration. Just write the file.
- Skills that read the profile should fall back to `dev` on absent or malformed file. Never crash on missing voice config.
- This skill is **always available** regardless of integration tier. Voice is independent of tier — a `light`-tier developer can still set `eli5`.
- Do not invent new profiles or register intermediate values (e.g. `dev-verbose`). Three discrete profiles, no spectrum.
