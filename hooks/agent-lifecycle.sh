#!/bin/bash
# G-Team agent lifecycle logger.
# Wired to SubagentStart and SubagentStop hooks in hooks.json.
# Logs to .claude/g-team-agent-log.jsonl and echoes a status note to Claude.
#
# Usage: bash hooks/agent-lifecycle.sh start|stop

EVENT="${1:-unknown}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LOG_FILE=".claude/g-team-agent-log.jsonl"

mkdir -p .claude

INPUT=$(cat)

AGENT=$(echo "$INPUT" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    name = (
        d.get('agent_name') or
        d.get('name') or
        d.get('subagent_name') or
        d.get('type') or
        'unknown'
    )
    print(name)
except Exception:
    print('unknown')
" 2>/dev/null)

echo "{\"event\":\"$EVENT\",\"agent\":\"$AGENT\",\"timestamp\":\"$TIMESTAMP\"}" >> "$LOG_FILE"

if [ "$EVENT" = "start" ]; then
    echo "[G-Team] agent '$AGENT' started"
elif [ "$EVENT" = "stop" ]; then
    echo "[G-Team] agent '$AGENT' finished"
fi
