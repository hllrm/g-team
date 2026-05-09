---
name: g-listen
description: Enter listen mode — collect user reports and information without acting, then synthesize and triage when the user signals done
---

**Announce:** "Entering listen mode. Share everything you need — notes, issues, observations, anything. I won't act, suggest, or edit files until you say done."

## Step 1 — Initialize

If `.claude/tier3-active` already exists, read its value and report:
> "Listen mode is already active (N items logged so far). Continue sharing, or say 'reset listen mode' to start fresh."
Then stop — do not re-initialize.

Otherwise: write `0` to `.claude/tier3-active`.

Tell the user:
> Listen mode active. Go ahead — share whatever you have. I'll collect it all and process when you say "done".

## Step 2 — Listen loop

On every user message while `.claude/tier3-active` exists and the user has not signalled done:

1. Read `.claude/tier3-active` to get the current count N.
2. Increment N by 1. Write the new value back to `.claude/tier3-active`.
3. Acknowledge with exactly one line: `Got it (N) — [3–5 word label describing what was shared].`
4. If N is a multiple of 3, append on a new line:
   > *(Still in listen mode — say "done" when you're ready for me to process.)*

Hard stops during the listen loop — violation of any of these ends the session with an apology and reset:
- No file edits, no agent dispatches, no code changes
- No suggestions, no analysis, no offering to "quickly fix" something
- No clarifying questions (collect and defer — questions can be listed as items)
- If the user asks a direct yes/no question, answer in one sentence max, then immediately return to listen mode

## Step 3 — Process on done

When the user says "done", "process now", "go ahead", "that's it", "analyze this", or any unambiguous signal to proceed:

1. Delete `.claude/tier3-active`.
2. Review every user message since listen mode began and extract all distinct items.
3. Group by type or theme:
   - **Systemic** — same class or root appearing ≥ 2 times → treat as one grouped item
   - **Isolated** — one-off items with no close parallel

4. Present the triage before doing anything:

```
## Listen session — N items

**Systemic (address first)**
1. [grouped theme / root cause]
2. …

**Isolated**
1. [single item]
2. …

Proceed with this plan?
```

5. Wait for explicit user approval. Do not touch any file until the user confirms.

## Step 4 — Reset (optional)

If the user says "reset listen mode":
1. Write `0` to `.claude/tier3-active` (overwrite).
2. Confirm: "Listen mode reset — items cleared. Start sharing again."

## Rules

- Never exit listen mode unless the user explicitly signals done or reset
- Never make file changes while `.claude/tier3-active` exists
- Acknowledge every message — no silent turns in listen mode
- The 3-item reminder is mandatory; never skip it
- Triage first, act only after explicit user approval
- Systemic items are always addressed before isolated ones
