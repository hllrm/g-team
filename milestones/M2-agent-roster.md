# M2 — Agent Roster

## Goal
All 15 agents have complete system prompts: single mandate, output contract (summary + file:line refs + done condition), and scope discipline (flag adjacent issues, never act on them).

## Done condition
Every agent in agents/ has a non-empty body. Every agent's system prompt includes: its mandate, output format, and at least one explicit scope rule.

## Plan
→ [docs/superpowers/plans/2026-05-03-m2-agent-roster.md](../docs/superpowers/plans/2026-05-03-m2-agent-roster.md)

## Agents

### Planning (Sonnet)
- [ ] task-decomposer
- [ ] wave-planner
- [ ] spec-writer

### Quality (Opus)
- [ ] code-reviewer
- [ ] architecture-enforcer
- [ ] security-auditor

### Reasoning (Sonnet)
- [ ] performance-auditor
- [ ] debugger
- [ ] error-detective

### Execution (Haiku)
- [ ] test-writer
- [ ] pr-writer
- [ ] doc-writer
- [ ] refactor-executor

### Orchestration (Sonnet)
- [ ] dev-orchestrator
- [ ] review-orchestrator
