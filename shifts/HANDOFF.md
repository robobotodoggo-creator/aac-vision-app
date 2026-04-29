# Handoff — Current State

## Last Updated
2026-04-28 by Claude Opus 4.6

## Project Status
All HIGH priority items complete. Five MEDIUM items done (landscape layout, symbol search, TTS persistence, loading state, suggestion overflow). `flutter analyze` passes clean. APK build not verified (no Java runtime on this machine). App has NOT been tested on a physical device yet.

## What's Working
- Full project structure with models, services, screens, widgets
- 56 AAC symbols across 7 categories (core, food, feelings, actions, people, places, emergency)
- Symbol grid with category tabs
- **Symbol search/filter** — search bar above grid filters symbols by label within the selected category; auto-clears on category change
- **Landscape layout** — vertical category sidebar, auto-increased grid columns, smaller camera PiP
- Portrait layout unchanged — horizontal category tabs
- Sentence builder (long-press tiles to compose, tap Speak to vocalize)
- TTS service (flutter_tts) with **persisted rate/pitch** — sliders reflect saved values, update live
- Vision service (Google ML Kit object detection, ~5fps processing) with proper error handling
- Context service (JSON-based object-to-symbol mappings)
- Cloud service (Claude API with 30s cache, 5s timeout)
- Settings screen (camera toggle with error display, cloud toggle, API key, grid size, TTS rate/pitch with current value labels)
- **Loading screen** — app shows branded loading screen with spinner during initialization
- **Suggestion bar** — gradient fade overflow indicator when >3 suggestions
- Dark theme, high contrast, wakelock, haptic feedback
- Android permissions (CAMERA, INTERNET, VIBRATE, WAKE_LOCK)
- Recent phrases bar (persisted, tappable for re-speak)
- Visual flash animation on tile tap (200ms blue flash for accessibility)

## What Needs Attention Next
1. **Device testing** — Need to test on actual Samsung Galaxy Tab S10+ or any Android device
2. **Symbol customization** — Ability to reorder/customize symbols from settings
3. **Cache TTS initialization** — For faster first-speak
4. **Stale build files** — `.metadata` and `build.gradle.kts` have uncommitted changes that revert minSdk from 23 to flutter default and change platform from android to web. These should be investigated and either reverted or intentionally committed.
5. **Java runtime** — APK builds require Java; not installed on current dev machine

## Key Files Changed This Shift
- `lib/services/app_state.dart` — Added `_speechRate`, `_pitch`, `_initialized` fields with getters/setters; persistence via SharedPreferences; `init()` now sets `_initialized = true` at end
- `lib/screens/settings_screen.dart` — TTS sliders now use `state.speechRate`/`state.pitch` and show current value labels
- `lib/main.dart` — `runApp()` called before `init()`; Consumer wraps home to show `_LoadingScreen` until initialized
- `lib/widgets/suggestion_bar.dart` — Added Stack with gradient fade overlay on right edge for scroll indication

## Target Device
Samsung Galaxy Tab S10+ (12.4" display, Android, Dimensity 9300+)
But should work on any Android 6.0+ device (minSdk 23).

## Git
- All changes committed and pushed to main
