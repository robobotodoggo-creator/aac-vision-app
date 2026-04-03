# AAC Vision App — Claude Code Context

## What This Is
A Flutter AAC (Augmentative and Alternative Communication) app that helps nonverbal users communicate. Shows a grid of tappable communication symbols, uses the device camera to detect the environment, and surfaces contextually relevant suggestions.

## Quick Commands
```bash
flutter analyze          # Check for errors (must pass before committing)
flutter build apk --debug   # Build debug APK
flutter run              # Run on connected device
```

## Project Structure
```
lib/
├── main.dart                 # App entry, Provider setup, wakelock
├── models/
│   ├── aac_symbol.dart       # Symbol data model
│   └── context_mapping.dart  # Object -> symbol mapping model
├── services/
│   ├── app_state.dart        # Central state (Provider ChangeNotifier)
│   ├── tts_service.dart      # Text-to-speech wrapper
│   ├── vision_service.dart   # Camera + ML Kit object detection
│   ├── context_service.dart  # Maps detected objects -> AAC suggestions
│   └── cloud_service.dart    # Claude API for smart suggestions
├── screens/
│   ├── home_screen.dart      # Main AAC grid + category tabs
│   └── settings_screen.dart  # Toggles, API key, grid size, TTS config
├── widgets/
│   ├── aac_grid.dart         # GridView of symbol tiles
│   ├── symbol_tile.dart      # Individual tappable tile
│   ├── suggestion_bar.dart   # Context-aware suggestions row
│   ├── sentence_bar.dart     # Multi-word sentence builder
│   └── camera_preview.dart   # Small camera feed PiP
└── assets/data/
    ├── default_symbols.json  # 56 symbols across 7 categories
    └── context_mappings.json # Object detection -> suggestion rules
```

## If You Are a Relay Shift Agent
1. Read `shifts/HANDOFF.md` first
2. Read `shifts/BACKLOG.md` for tasks
3. Read `shifts/RULES.md` for rules
4. Do work, commit often
5. Update HANDOFF.md and SHIFT_LOG.md when done

## Key Design Principles
- This is an ACCESSIBILITY tool — reliability matters more than features
- Minimum 60x60dp touch targets
- High contrast (dark background, bright icons)
- No text smaller than 16sp
- Works fully offline (cloud is optional)
- Tap only — no gestures required
- Screen stays on (wakelock)

## Target Device
Samsung Galaxy Tab S10+ (12.4" 2560x1600, Android, 12GB RAM)
Min SDK: 23 (Android 6.0)

## AI Agent Architecture

This project is built by autonomous AI agents coordinated through OpenClaw.

### Roles
- **Qwen 8B (local, OpenClaw):** Project manager / dispatcher. Runs 2x/day via cron (9 AM, 6 PM PT). Reads the backlog, runs tests, spawns Claude when work is needed. Also reachable on-demand via Telegram. Never codes — only manages.
- **Claude Opus 4.6 (Claude Code Pro):** The coder. Spawned by Qwen for specific tasks. Reads CLAUDE.md + shifts/RULES.md, picks up stories from BACKLOG.md, does the work, commits, updates handoff docs.
- **Long-running Claude (future):** A persistent "director" instance that maintains high-level project context across weeks. Answers strategic questions, reviews architecture, never touches code directly. Qwen routes questions to it.

### How Shifts Work
1. Qwen wakes up (cron or Telegram trigger)
2. Reads HANDOFF.md, BACKLOG.md, runs `flutter analyze`
3. If green, spawns Claude Code to pick up top priority task
4. Claude reads RULES.md, does the work, commits, updates HANDOFF.md + SHIFT_LOG.md
5. Qwen reports summary to Dave via Telegram

### Triggering a Check-In Manually
Message the Telegram bot: "check on the AAC app" or "run tests on aac_vision_app"

## Owner
Dave (roboboto) — building this for AAC users, post-stroke aphasia focus
GitHub: robobotodoggo-creator
