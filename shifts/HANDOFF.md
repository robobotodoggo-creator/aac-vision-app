# Handoff — Current State

## Last Updated
2026-04-28 by Claude Opus 4.6

## Project Status
All HIGH priority items complete. First MEDIUM item (landscape layout) done. `flutter analyze` passes clean. APK build not verified this shift (no Java runtime on this machine). App has NOT been tested on a physical device yet.

## What's Working
- Full project structure with models, services, screens, widgets
- 56 AAC symbols across 7 categories (core, food, feelings, actions, people, places, emergency)
- Symbol grid with category tabs
- **Landscape layout** — vertical category sidebar, auto-increased grid columns, smaller camera PiP
- Portrait layout unchanged — horizontal category tabs
- Sentence builder (long-press tiles to compose, tap Speak to vocalize)
- TTS service (flutter_tts)
- Vision service (Google ML Kit object detection, ~5fps processing) with proper error handling
- Context service (JSON-based object-to-symbol mappings)
- Cloud service (Claude API with 30s cache, 5s timeout)
- Settings screen (camera toggle with error display, cloud toggle, API key, grid size, TTS controls)
- Dark theme, high contrast, wakelock, haptic feedback
- Android permissions (CAMERA, INTERNET, VIBRATE, WAKE_LOCK)
- Recent phrases bar (persisted, tappable for re-speak)
- Visual flash animation on tile tap (200ms blue flash for accessibility)

## What Needs Attention Next
1. **Device testing** — Need to test on actual Samsung Galaxy Tab S10+ or any Android device
2. **Symbol search/filter** — Search within categories
3. **TTS persistence** — Rate/pitch sliders in settings don't persist their values
4. **Loading state** — Show loading indicator while app initializes
5. **Java runtime** — APK builds require Java; not installed on current dev machine

## Key Files Changed This Shift
- `lib/screens/home_screen.dart` — Landscape/portrait layout switching with OrientationBuilder, vertical category sidebar
- `lib/widgets/aac_grid.dart` — Auto-adjust grid columns (+2 in landscape)
- `lib/widgets/camera_preview.dart` — Smaller PiP in landscape

## Target Device
Samsung Galaxy Tab S10+ (12.4" display, Android, Dimensity 9300+)
But should work on any Android 6.0+ device (minSdk 23).

## Git
- All changes committed and pushed to main
