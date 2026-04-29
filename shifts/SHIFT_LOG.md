# Shift Log

## Shift 0 — Initial Setup
- **Agent**: Claude Opus 4.6 (local Claude Code)
- **Date**: 2026-02-15
- **Duration**: ~30 minutes
- **What was done**:
  - Created Flutter project (com.robobotodoggo.aac_vision_app)
  - Added all dependencies (ML Kit, camera, TTS, provider, etc.)
  - Built full project structure: models, services, screens, widgets
  - Created 56 default AAC symbols across 7 categories
  - Implemented all core services (TTS, vision, context, cloud)
  - Built all UI widgets (grid, tiles, suggestion bar, sentence bar, camera preview)
  - Built home screen and settings screen
  - Set minSdk to 23 for ML Kit compatibility
  - `flutter analyze` passes clean
  - Initial git commit
- **What's next**: Android permissions, first device build, recent phrases bar
- **Blockers**: None

## 2026-04-27 — Claude Opus 4.6
**Task:** Complete all HIGH priority backlog items
**Done:**
- Added Android permissions (CAMERA, INTERNET, VIBRATE, WAKE_LOCK) to AndroidManifest.xml
- Verified debug APK builds successfully
- Built RecentPhrasesBar widget with persisted phrase history (SharedPreferences)
- Added speakPhrase method and deduplication logic to AppState
- Implemented proper error handling in VisionService (camera init, ML Kit init, frame processing)
- Added error stream and visionError display in Settings screen
- AppState now gracefully disables camera on init failure
- Added visual flash animation (200ms blue flash) on SymbolTile tap/long-press
- All changes pass `flutter analyze` and `flutter build apk --debug`
**Learned:** VisionService.init() had no error handling at all — camera failures would throw unhandled exceptions. The recentPhrases list existed in AppState but was never persisted or exposed in UI.
**Blocked:** Nothing
**Next:** Medium priority items — landscape layout optimization, symbol search/filter, TTS rate/pitch persistence. Should also test on actual device.

## 2026-04-28 — Claude Opus 4.6
**Task:** Add landscape layout optimization for tablet (MEDIUM priority)
**Done:**
- HomeScreen now detects orientation and switches between portrait and landscape layouts
- Landscape: category tabs move to a vertical sidebar (100px wide, left side) freeing vertical space
- Landscape: Settings button sits at bottom of sidebar with icon + label
- Portrait: layout unchanged (horizontal category tab bar)
- AacGrid auto-adds 2 extra columns in landscape (e.g., 4 → 6) to use wider display
- CameraPreview PiP shrinks slightly in landscape (100x130 vs 120x160) to save space
- All touch targets remain ≥60dp in both orientations
- `flutter analyze` passes clean
**Learned:** `flutter build apk --debug` fails on this machine due to missing Java runtime — environment issue, not code. Previous shift had Java available. OrientationBuilder is the cleanest way to handle this since it rebuilds only when orientation changes.
**Blocked:** APK build requires Java runtime installation on this machine
**Next:** Symbol search/filter, TTS rate/pitch persistence, loading state. Device testing still needed.

## 2026-04-28 — Claude Opus 4.6
**Task:** Implement symbol search/filter within categories (MEDIUM priority)
**Done:**
- Added `_searchQuery` field and `setSearchQuery` method to AppState
- `filteredSymbols` now filters by both category and search query (case-insensitive label match)
- Search query auto-clears when user switches categories
- Created `SymbolSearchBar` widget (TextField with search icon and clear button)
- Added search bar to both portrait and landscape layouts in HomeScreen
- 48dp height, 16sp text, rounded corners, high-contrast dark styling
- `flutter analyze` passes clean
**Learned:** Need to sync the TextEditingController when AppState clears the search externally (on category change). Consumer rebuild handles this by checking if controller text diverges from state.
**Blocked:** Nothing
**Next:** TTS rate/pitch persistence, loading state, symbol customization. Device testing still needed.

## 2026-04-28 — Claude Opus 4.6
**Task:** Three MEDIUM priority items: TTS persistence, loading state, suggestion bar overflow
**Done:**
- TTS rate/pitch now persisted in SharedPreferences; sliders in Settings reflect saved values and update live via AppState setters
- Added `_initialized` flag to AppState; `main.dart` now calls `runApp()` immediately and shows a loading screen (app name + spinner) until `init()` completes
- Suggestion bar now has a gradient fade on the right edge when >3 suggestions, indicating scrollable overflow (IgnorePointer so it doesn't block touches)
- Noticed pre-existing unstaged changes in `.metadata` (platform android→web) and `build.gradle.kts` (minSdk 23→flutter default) — did NOT commit these as they'd break ML Kit compatibility
- `flutter analyze` passes clean
**Learned:** The TTS sliders were using hardcoded values (0.45, 1.0) and calling `state.tts.setSpeechRate()` directly — changes worked in-session but were lost on restart and the slider UI never moved. Moving state ownership to AppState with persistence fixes both issues.
**Blocked:** Pre-existing `.metadata` and `build.gradle.kts` changes need investigation — someone or something changed minSdk from 23 to flutter default and platform from android to web. These should be reverted or intentionally committed separately.
**Next:** Symbol customization/reorder, cache TTS initialization. Device testing still needed.

## 2026-04-28 — Claude Opus 4.6
**Task:** Symbol customization/reorder (MEDIUM priority) + investigate stale build files
**Done:**
- Reverted stale `.metadata` (platform web→android) and `build.gradle.kts` (minSdk flutter.default→23) — these were caused by `flutter create --platforms web` and would break ML Kit
- Added `ManageSymbolsScreen` accessible from Settings > Symbols > Manage Symbols
- Per-category reorderable list with drag handles for custom symbol ordering
- Visibility toggle (eye icon) to show/hide individual symbols
- Hidden symbols excluded from `filteredSymbols` in the main grid
- Custom order and hidden set persisted in SharedPreferences (JSON for order map, StringList for hidden IDs)
- Added `symbolsForCategory()` method that returns all symbols including hidden ones (used by manage screen)
- Reset button with confirmation dialog restores defaults
- Settings shows count of hidden symbols
- `flutter analyze` passes clean
**Learned:** `ReorderableListView.builder` needs the index passed to `ReorderableDragStartListener` directly — can't derive it from key. The `withValues()` API is the Flutter 3.x way to set opacity on colors (replaces `withOpacity()`). The `web/` untracked directory was the source of the `.metadata` platform change.
**Blocked:** Nothing
**Next:** Cache TTS initialization, custom symbol creation. Device testing still needed.

## 2026-04-29 — Claude Opus 4.6
**Task:** Cache TTS initialization for faster first-speak (MEDIUM priority) + add web/ to .gitignore (LOW)
**Done:**
- TtsService.init() now accepts persisted rate/pitch params — avoids setting defaults then overwriting
- Added TTS engine warm-up: `awaitSpeakCompletion(true)` + empty `speak('')` during init primes the native TTS engine so the first real speak has no cold-start delay
- AppState.init() now loads SharedPreferences early, extracts TTS values, and runs symbol loading, context init, and TTS init in parallel via `Future.wait` (was sequential)
- Removed redundant `setSpeechRate`/`setPitch` calls from `_loadPreferences` since values are now set correctly during init
- Added `/web/` to .gitignore (unused Flutter web scaffold)
- `flutter analyze` passes clean
**Learned:** The original init flow was fully sequential — symbols, context, TTS one after another — but they're independent and can safely run in parallel. On Android, the first `FlutterTts.speak()` call triggers the platform TTS engine to connect, causing 100-500ms delay. Speaking an empty string during init absorbs that cost.
**Blocked:** Nothing
**Next:** Custom symbol creation, device testing. All MEDIUM backlog items now complete.
