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
