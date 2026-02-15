# Relay Shift Rules

Every shift agent MUST follow these rules:

## Before Starting Work
1. Read HANDOFF.md completely
2. Read BACKLOG.md to understand the task queue
3. Read the last 3 entries in SHIFT_LOG.md for recent context

## During Work
1. Work on tasks from BACKLOG.md in priority order (HIGH > MEDIUM > LOW)
2. Commit frequently with clear messages
3. Run `flutter analyze` before committing — zero errors allowed
4. Do NOT refactor working code unless it's on the backlog
5. Do NOT add features not on the backlog
6. If blocked, document the blocker and move to the next task

## Before Ending Shift
1. Append a shift log entry to SHIFT_LOG.md
2. Update HANDOFF.md with current state for the next agent
3. Update BACKLOG.md — mark completed tasks, add discovered tasks
4. Commit all changes with a clear summary
5. Push to GitHub

## Communication
- If something is urgent for Dave, write to shifts/URGENT.md
- Never delete or overwrite other agents' log entries
- Be honest about what you did and didn't finish

## Code Quality
- This is an AAC accessibility app — reliability > cleverness
- Large touch targets (60x60dp minimum)
- High contrast (dark bg, bright icons)
- No small text (16sp minimum)
- Test on-device when possible
- Works offline first, cloud features are optional
