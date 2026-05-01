# Handoff — Current State

## Last Updated
2026-05-01 by Claude Opus 4.6

## Project Status
All HIGH, MEDIUM, and LOW priority code backlog items are complete. The only remaining backlog item is physical device testing (MEDIUM). `flutter analyze` passes clean.

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
- **Stream subscriptions properly stored and cancelled in dispose()**

## What Needs Attention Next
1. **Device testing** — Need to test on actual Samsung Galaxy Tab S10+ or any Android device
2. **Java runtime** — APK builds require Java; not installed on current dev machine

## Key Files Changed This Shift
- `lib/services/app_state.dart` — Added stream subscription storage and cancellation in dispose()

## Target Device
Samsung Galaxy Tab S10+ (12.4" display, Android, Dimensity 9300+)
But should work on any Android 6.0+ device (minSdk 23).

## Git
- All changes committed and pushed to main
