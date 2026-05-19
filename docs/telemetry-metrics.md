# Telemetry Metrics

The 8 reliability metrics G-Forge tracks. Each metric is defined here; `/g-telemetry` computes them from observable artifacts (retros, forecasts, todo-done, git log, review-holds counter). All values are session-local approximations — no remote telemetry, no daemon, no background collection.

## How to read this file

- **What it measures** — the failure mode the metric is trying to catch.
- **Source** — files or commands the value is computed from.
- **Formula** — the exact computation, in pseudo-bash.
- **Range** — typical observed values; out-of-range values surface as `⚠`.
- **Used by** — which skill or hook adjusts behavior when this metric goes outside range.

---

## 1. Hallucination rate

**What it measures.** Fraction of agent outputs that referenced non-existent files, functions, or APIs and required correction.

**Source.** `docs/retros/*.md` — bullets under `Avoid / do differently` matching the labels `hallucinated-`, `nonexistent-`, `wrong-api`, `bad-citation`.

**Formula.**
```
hallucination_rate = count(matching_bullets) / count(retros) * 100
```

**Range.** Expected 0–10%. ⚠ above 15%.

**Used by.** `/g-execute` — bumps reviewer count when hallucination rate is high; `/g-review` — adds an extra `code-reviewer` pass.

---

## 2. Review catch rate

**What it measures.** Fraction of `/g-review` cycles that caught at least one Major or Critical finding before the merge gate opened.

**Source.** `docs/retros/*.md` — bullets mentioning `review caught`, `code-lead caught`, `architect caught`. Negative signal: bullets matching `bug missed by review`, `review didn't catch`.

**Formula.**
```
review_catch_rate = (caught_bullets / (caught_bullets + missed_bullets)) * 100
```
If denominator is 0, report `n/a`.

**Range.** Expected 70–100%. ⚠ below 60%.

**Used by.** `/g-review` — declining catch rate triggers a 2nd code-reviewer pass with stricter instructions.

---

## 3. Regression frequency

**What it measures.** How often a closed task is reopened or a fix is followed by a fix-of-fix within the same milestone.

**Source.** `git log --oneline -200` — count of commits matching the rework regex used by `workflow-checkpoint.sh`.

**Formula.**
```
regression_frequency = rework_commits_last_50 / 50 * 100
```

**Range.** Expected 0–8%. ⚠ above 12%.

**Used by.** `/g-execute` — high regression triggers smaller wave sizes (max 2 agents/wave).

---

## 4. Rework rate

**What it measures.** Fraction of merged PRs that required a follow-up fix within the same week, **plus** review-time HOLDs that did not produce a clean review on first attempt.

**Source.** `git log --oneline -200` for commits; `.claude/review-holds` for the running HOLD counter (written by `/g-review` Step 4 on any HOLD verdict).

**Formula.**
```
fix_after_feat       = count of `fix:` commits within 7 commits after a `feat:` commit (last 200)
feat_commits         = count of `feat:` commits (last 200)
review_holds         = value in .claude/review-holds (default 0 if absent)
rework_signal        = fix_after_feat + review_holds
rework_rate          = (rework_signal / max(feat_commits, 1)) * 100
```

**Reset policy:** `.claude/review-holds` is reset to `0` whenever `/g-telemetry` derives a `stable` profile — a stable run means accumulated HOLDs are stale and should not bias the next snapshot.

**Range.** Expected 0–15%. ⚠ above 20%.

**Used by.** `/g-review` — high rework rate adds a `debugger` agent pre-review. `/g-review` also increments `.claude/review-holds` on every HOLD verdict regardless of profile (the increment is unconditional; only the *consumption* changes with profile).

---

## 5. Spec deviation

**What it measures.** How often executors deviated from the approved spec — e.g. added unscoped files, refactored adjacent code, scope-crept.

**Source.** `docs/retros/*.md` — `Avoid / do differently` bullets matching `scope creep`, `unscoped`, `refactored adjacent`, `out of plan`, `deviated`.

**Formula.**
```
spec_deviation = count(matching_bullets) / count(retros) * 100
```

**Range.** Expected 0–10%. ⚠ above 15%.

**Used by.** `/g-execute` — high deviation appends a stricter scope-boundary reminder to every agent prompt.

---

## 6. Escalation frequency

**What it measures.** How often a task escalated to a higher model tier (Sonnet → Opus) due to repeated failure.

**Source.** `.claude/escalation-log` — a plain-text counter written by `/g-execute` whenever the Three-Strikes rule (G-RULES.md §A7) escalates a task. One line per escalation: `YYYY-MM-DD <task-id-or-label>`. `docs/retros/*.md` bullets matching `escalated`, `bumped to opus`, `three-strikes` are read as a fallback for sessions before `.claude/escalation-log` was introduced.

**Formula.**
```
escalations  = wc -l of .claude/escalation-log  (or retro-bullet count if log absent)
dispatches   = total commits in this branch's history (cheap proxy for total work)
escalation_frequency = (escalations / max(dispatches, 1)) * 100
```

The window is intentionally **all-time** — escalations are rare events and a 30-day window produces noisy ratios on small corpora.

**Range.** Expected 0–5%. ⚠ above 10%.

**Used by.** `/g-execute` — high escalation triggers Opus-default for the next dispatch in this milestone. `/g-execute` also writes a new line to `.claude/escalation-log` whenever it applies Three-Strikes, so this metric is self-feeding.

---

## 7. Token efficiency

**What it measures.** Average context tokens used per closed task — proxied by reading the average commit diff size for the last 30 commits and the number of tool calls observed in retros (when noted).

**Source.** `git log --stat -30` for diff size; retros for tool-count notes (often "many parallel agents", "single dispatch", etc.).

**Formula.**
```
avg_diff_size = sum(insertions + deletions, last 30 commits) / 30
efficiency_score = clamp(0, 100, 100 - (avg_diff_size - 50) / 5)
```
Higher is better. A tight 50-line average commit is 100%; a 500-line commit average is 10%.

**Range.** Expected 50–100. ⚠ below 40.

**Used by.** Surfaces in `/g-help` as a hint to refactor or split waves; not auto-actioned.

---

## 8. Retry dependency

**What it measures.** Fraction of dispatched agent waves that required a re-dispatch with corrections.

**Source.** `docs/retros/*.md` — bullets matching `re-dispatched`, `wave 2 take 2`, `had to retry the agent`, `agent returned empty`.

**Formula.**
```
retry_dependency = count(matching_bullets) / count(retros) * 100
```

**Range.** Expected 0–8%. ⚠ above 12%.

**Used by.** `/g-execute` — high retry dependency adds an explicit pre-dispatch verification step.

---

## Health profile derivation

`/g-telemetry` aggregates the metrics into one of four health profiles. Profiles are derived from the **ratio** of ⚠ metrics to **computable** metrics, not the absolute count — so a project with several `n/a` (insufficient-data) metrics still has a meaningful health profile.

```
computable = count of metrics whose status is ✓ or ⚠ (excludes n/a)
warn_ratio = ⚠ count / max(computable, 1)
```

| Profile | Trigger | Effect |
|---------|---------|--------|
| `stable` | `warn_ratio == 0` (all computable metrics in range) | Default behavior — no adaptive changes. Also resets `.claude/review-holds` to 0. |
| `cautious` | `0 < warn_ratio ≤ 0.25` (small fraction ⚠) | One extra reviewer added to `/g-review`; no model changes |
| `defensive` | `0.25 < warn_ratio ≤ 0.50` | `/g-execute` bumps model tier on next dispatch; `/g-review` adds 2 reviewers and a `debugger` pre-pass |
| `recovery` | `warn_ratio > 0.50` (majority ⚠) | `/g-execute` reduces wave size to 1 agent; `/g-review` adds all reviewers regardless of diff; `/g-help` surfaces a "consider /g-audit" suggestion |

Floor: if `computable < 3`, force `stable` regardless of ratio — too few signals to classify reliably. This subsumes the bootstrapping case (≤2 computable metrics is the same condition).

The profile is written to `.claude/telemetry-profile` (single-line, value is the profile name). `/g-execute` Step 0 and `/g-review` Step 0 read it; absence of the file is equivalent to `stable`.

---

## Bootstrapping note

On a project with fewer than 3 retros and fewer than 30 commits, telemetry derivation is unreliable. `/g-telemetry` emits `cold-start — too thin to compute` for any metric whose source has insufficient data, and the profile defaults to `stable`.
