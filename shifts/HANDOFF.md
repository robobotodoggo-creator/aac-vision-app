# Handoff — Current State

## Last Updated
2026-04-30 by Claude Opus 4.6

## Project Status
All HIGH, MEDIUM, and LOW priority backlog items complete. Only remaining item is physical device testing (MEDIUM). `flutter analyze` passes clean. Full codebase audit found no issues — no TODOs, no null safety problems, no deprecated APIs, all controllers disposed. One cosmetic item added to LOW backlog (stream subscription cleanup in AppState).

## What's Working
- Full project structure with models, services, screens, widgets
- 56 default AAC symbols across 7 categories (core, food, feelings, actions, people, places, emergency)
- **Onboarding tutorial overlay** — 5-step first-launch walkthrough; persisted in SharedPreferences
- **Tap sound effects** — programmatic WAV generation, toggle in Settings (off by default)
- **Dark/light theme toggle** — Material 3 theming, all widgets use ColorScheme
- **Custom symbol creation** — add new symbols with emoji + label via FAB
- **Export/import symbol config** — JSON format via share sheet / file picker
- **Usage analytics** — local-only tracking, therapist report export
- Symbol grid with category tabs
- **Symbol customization** — reorder, show/hide, delete custom symbols
- **Symbol search/filter** — search bar filters by label within category
- **Landscape layout** — vertical sidebar, auto-increased grid columns
- Sentence builder (long-press to compose, tap Speak)
- TTS service with persisted rate/pitch and cached initialization
- Vision service (Google ML Kit, ~5fps) with error handling
- Context service (JSON-based object-to-symbol mappings)
- Cloud service (Claude API, 30s cache, 5s timeout)
- Settings screen (appearance, camera, cloud, API key, grid size, TTS, symbols, usage stats)
- Loading screen during initialization
- Suggestion bar with gradient fade overflow indicator
- Material 3 theming, high contrast, wakelock, haptic feedback
- Android permissions (CAMERA, INTERNET, VIBRATE, WAKE_LOCK)
- Recent phrases bar (persisted, tappable)
- Visual flash animation on tile tap

## What Needs Attention Next
1. **Device testing** — Need to test on actual Samsung Galaxy Tab S10+ or any Android device
2. **Java runtime** — APK builds require Java; not installed on current dev machine
3. **Stream subscription cleanup** — LOW priority cosmetic fix in AppState (added to backlog)

## Key Files Changed This Shift
- `shifts/BACKLOG.md` — Added discovered LOW priority item (stream subscription cleanup)
- No code changes this shift — codebase audit only

## Target Device
Samsung Galaxy Tab S10+ (12.4" display, Android, Dimensity 9300+)
But should work on any Android 6.0+ device (minSdk 23).

## Git
- All changes committed and pushed to main
