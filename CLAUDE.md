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

## Owner
Dave (roboboto) — building this for AAC users
GitHub: robobotodoggo-creator
