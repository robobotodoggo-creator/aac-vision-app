# Handoff — Current State

## Last Updated
2026-04-29 by Claude Opus 4.6

## Project Status
All HIGH and MEDIUM priority items complete. Top two LOW items (custom symbol creation, export/import config) also done. `flutter analyze` passes clean. APK build not verified (no Java runtime on this machine). App has NOT been tested on a physical device yet.

## What's Working
- Full project structure with models, services, screens, widgets
- 56 default AAC symbols across 7 categories (core, food, feelings, actions, people, places, emergency)
- **Custom symbol creation** — Users can add new symbols with emoji + label via FAB on Manage Symbols screen; custom symbols persisted in SharedPreferences; deletable with confirmation dialog
- **Export/import symbol config** — Overflow menu (⋮) on Manage Symbols screen with Export (share sheet), Import (file picker), and Reset options; JSON format includes custom symbols, hidden IDs, and symbol order
- Symbol grid with category tabs
- **Symbol customization** — Manage Symbols screen (Settings > Symbols) with per-category reorderable list, drag handles, show/hide toggles, and delete for custom symbols; persisted in SharedPreferences; Reset button to restore defaults
- **Symbol search/filter** — search bar above grid filters symbols by label within the selected category; auto-clears on category change
- **Landscape layout** — vertical category sidebar, auto-increased grid columns, smaller camera PiP
- Portrait layout unchanged — horizontal category tabs
- Sentence builder (long-press tiles to compose, tap Speak to vocalize)
- TTS service (flutter_tts) with **persisted rate/pitch** and **cached initialization** — engine is primed during startup with empty speak, init runs in parallel with symbol/context loading
- Vision service (Google ML Kit object detection, ~5fps processing) with proper error handling
- Context service (JSON-based object-to-symbol mappings)
- Cloud service (Claude API with 30s cache, 5s timeout)
- Settings screen (camera toggle with error display, cloud toggle, API key, grid size, TTS rate/pitch, manage symbols)
- **Loading screen** — app shows branded loading screen with spinner during initialization
- **Suggestion bar** — gradient fade overflow indicator when >3 suggestions
- Dark theme, high contrast, wakelock, haptic feedback
- Android permissions (CAMERA, INTERNET, VIBRATE, WAKE_LOCK)
- Recent phrases bar (persisted, tappable for re-speak)
- Visual flash animation on tile tap (200ms blue flash for accessibility)

## What Needs Attention Next
1. **Device testing** — Need to test on actual Samsung Galaxy Tab S10+ or any Android device
2. **Java runtime** — APK builds require Java; not installed on current dev machine
3. **Usage analytics** — Next LOW priority item (local-only symbol usage tracking for therapist reports)

## Key Files Changed This Shift
- `lib/services/app_state.dart` — Added `exportSymbolConfig()` and `importSymbolConfig()` methods; added `dart:io` and `path_provider` imports
- `lib/screens/manage_symbols_screen.dart` — Added `_exportConfig` and `_importConfig` methods; replaced Reset button with PopupMenuButton overflow menu (Export, Import, Reset); added `share_plus`, `file_picker`, `dart:io` imports
- `pubspec.yaml` — Added `share_plus`, `file_picker`, `path_provider` dependencies

## Target Device
Samsung Galaxy Tab S10+ (12.4" display, Android, Dimensity 9300+)
But should work on any Android 6.0+ device (minSdk 23).

## Git
- All changes committed and pushed to main
