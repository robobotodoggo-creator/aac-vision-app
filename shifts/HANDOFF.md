# Handoff — Current State

## Last Updated
2026-04-28 by Claude Opus 4.6

## Project Status
All HIGH priority items complete. Two MEDIUM items done (landscape layout, symbol search). `flutter analyze` passes clean. APK build not verified (no Java runtime on this machine). App has NOT been tested on a physical device yet.

## What's Working
- Full project structure with models, services, screens, widgets
- 56 AAC symbols across 7 categories (core, food, feelings, actions, people, places, emergency)
- Symbol grid with category tabs
- **Symbol search/filter** — search bar above grid filters symbols by label within the selected category; auto-clears on category change
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
2. **TTS persistence** — Rate/pitch sliders in settings don't persist their values
3. **Loading state** — Show loading indicator while app initializes
4. **Symbol customization** — Ability to reorder/customize symbols from settings
5. **Java runtime** — APK builds require Java; not installed on current dev machine

## Key Files Changed This Shift
- `lib/services/app_state.dart` — Added `_searchQuery`, `setSearchQuery()`, updated `filteredSymbols` getter, clear search on category change
- `lib/widgets/symbol_search_bar.dart` — New widget: search TextField with clear button
- `lib/screens/home_screen.dart` — Added SymbolSearchBar to both portrait and landscape layouts

## Target Device
Samsung Galaxy Tab S10+ (12.4" display, Android, Dimensity 9300+)
But should work on any Android 6.0+ device (minSdk 23).

## Git
- All changes committed and pushed to main
