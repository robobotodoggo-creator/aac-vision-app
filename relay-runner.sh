#!/bin/bash
# relay-runner.sh — Launch a Claude Code shift agent for the AAC Vision App
# Called by cron every 2 hours
#
# Usage: ./relay-runner.sh
# Cron:  0 */2 * * * /Users/roboboto/aac_vision_app/relay-runner.sh >> /Users/roboboto/aac_vision_app/shifts/cron.log 2>&1

set -euo pipefail

PROJECT_DIR="/Users/roboboto/aac_vision_app"
LOG_FILE="$PROJECT_DIR/shifts/cron.log"
SHIFT_START=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

export PATH="/opt/homebrew/opt/node@22/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

echo "=== Relay shift starting at $SHIFT_START ==="

cd "$PROJECT_DIR"

# Run Claude Code with the shift prompt
# --max-turns limits how long the agent can run
# --dangerously-skip-permissions allows autonomous operation
claude --print \
  --max-turns 30 \
  --dangerously-skip-permissions \
  "You are a relay shift agent for the AAC Vision App.

Read these files in order:
1. CLAUDE.md (project context)
2. shifts/HANDOFF.md (current state from last agent)
3. shifts/BACKLOG.md (task queue)
4. shifts/RULES.md (rules you must follow)

Then:
- Pick the highest priority incomplete task from the backlog
- Do the work. Commit after each meaningful change.
- Run 'flutter analyze' before each commit — zero errors.
- When done (or after ~25 turns), update:
  - shifts/HANDOFF.md with current state
  - shifts/SHIFT_LOG.md with what you did
  - shifts/BACKLOG.md marking completed tasks
- Commit and push to GitHub.
- Be efficient. You have limited turns."

SHIFT_END=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "=== Relay shift ended at $SHIFT_END ==="
