# Handoff — Current State

## Last Updated
2026-02-15 by Claude Opus 4.6 (initial setup)

## Project Status
The AAC Vision App has been scaffolded with all core features. The code compiles clean (`flutter analyze` passes). It has NOT been built or run on a device yet.

## What's Working
- Full project structure with models, services, screens, widgets
- 56 AAC symbols across 7 categories (core, food, feelings, actions, people, places, emergency)
- Symbol grid with category tabs
- Sentence builder (long-press tiles to compose, tap Speak to vocalize)
- TTS service (flutter_tts)
- Vision service (Google ML Kit object detection, ~5fps processing)
- Context service (JSON-based object-to-symbol mappings)
- Cloud service (Claude API with 30s cache, 5s timeout)
- Settings screen (camera toggle, cloud toggle, API key, grid size, TTS controls)
- Dark theme, high contrast, wakelock, haptic feedback

## What Needs Attention Next
1. **Android permissions** — AndroidManifest.xml needs CAMERA, INTERNET, VIBRATE, WAKE_LOCK permissions added
2. **First build test** — Run `flutter build apk --debug` to catch any build issues
3. **Recent phrases bar** — Spec calls for it but not implemented yet
4. **Error handling** — Vision service needs graceful camera/ML Kit failure handling

## Key Files
- `lib/main.dart` — App entry point
- `lib/services/app_state.dart` — Central state management (Provider)
- `lib/screens/home_screen.dart` — Main AAC grid screen
- `lib/screens/settings_screen.dart` — Settings
- `assets/data/default_symbols.json` — Symbol library
- `assets/data/context_mappings.json` — Object detection -> suggestion mappings

## Target Device
Samsung Galaxy Tab S10+ (12.4" display, Android, Dimensity 9300+)
But should work on any Android 10+ device.

## Git
- Repo initialized, initial commit done
- Remote: not yet pushed to GitHub
