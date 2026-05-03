# M2 — Agent Roster

## Goal
All 15 agents have complete system prompts: single mandate, output contract (summary + file:line refs + done condition), and scope discipline (flag adjacent issues, never act on them).

## Done condition
Every agent in agents/ has a non-empty body. Every agent's system prompt includes: its mandate, output format, and at least one explicit scope rule.

## Plan
→ [docs/superpowers/plans/2026-05-03-m2-agent-roster.md](../docs/superpowers/plans/2026-05-03-m2-agent-roster.md)

## Agents

### Planning (Sonnet)
- [x] task-decomposer
- [x] wave-planner
- [x] spec-writer

### Quality (Opus)
- [x] code-reviewer
- [x] architecture-enforcer
- [x] security-auditor

### Reasoning (Sonnet)
- [x] performance-auditor
- [x] debugger
- [x] error-detective

### Execution (Haiku)
- [x] test-writer
- [x] pr-writer
- [x] doc-writer
- [x] refactor-executor

### Orchestration (Sonnet)
- [x] project-manager
- [x] review-orchestrator
