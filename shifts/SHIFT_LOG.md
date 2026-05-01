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

## 2026-04-29 — Claude Opus 4.6
**Task:** Custom symbol creation (LOW priority) — add new symbols with emoji + label
**Done:**
- Added `addCustomSymbol` and `deleteCustomSymbol` methods to AppState
- Custom symbols persisted in SharedPreferences as JSON, loaded into `_allSymbols` during startup
- Custom symbol IDs use `custom_` prefix to distinguish from default symbols
- FAB (+) button on Manage Symbols screen opens Add Symbol dialog
- Dialog has fields for emoji, label, speak text (optional, defaults to label), and category dropdown
- Delete button (trash icon with confirmation dialog) shown only for custom symbols in the manage list
- Cleanup on delete: removes from hidden set and custom order maps
- Settings subtitle updated to mention "Add" capability
- `flutter analyze` passes clean
**Learned:** `DropdownButtonFormField.value` is deprecated in Flutter 3.33+ — switched to `DropdownButton` inside `InputDecorator` to avoid the warning. `StatefulBuilder` is necessary inside `showDialog` to manage local dialog state (category selection) without rebuilding the parent.
**Blocked:** Nothing
**Next:** Export/import symbol configs, device testing. Custom symbol creation is complete.

## 2026-04-29 — Claude Opus 4.6
**Task:** Export/import symbol configurations as JSON (LOW priority)
**Done:**
- Added `exportSymbolConfig()` to AppState — bundles custom symbols, hidden IDs, and symbol order into versioned JSON; writes to temp file for sharing
- Added `importSymbolConfig(String)` to AppState — parses JSON, replaces current customizations (custom symbols, hidden set, order), persists changes
- Added `_exportConfig` and `_importConfig` methods to ManageSymbolsScreen using `share_plus` (share sheet) and `file_picker` (file selection)
- Replaced standalone Reset button with PopupMenuButton overflow menu containing Export, Import, and Reset actions
- Added `share_plus`, `file_picker`, and `path_provider` dependencies
- `flutter analyze` passes clean
**Learned:** `FilePicker.platform.pickFiles()` from older versions is now `FilePicker.pickFiles()` as a static method in file_picker 11.x. `path_provider` was a transitive dep via share_plus but needs explicit listing to satisfy `depend_on_referenced_packages` lint.
**Blocked:** Nothing
**Next:** Usage analytics (local), dark/light theme toggle, device testing.

## 2026-04-29 — Claude Opus 4.6
**Task:** Add usage analytics — local-only symbol usage tracking for therapist reports (LOW priority)
**Done:**
- Created `UsageStatsService` that tracks per-symbol tap counts and daily totals in SharedPreferences
- Integrated tracking into `AppState.speakSymbol()` (single taps) and `addToSentence()` (long-press sentence building)
- Added `usageStats.init()` to parallel startup in `AppState.init()`
- Built `UsageStatsScreen` with summary cards (total taps, unique symbols, days active), most-used symbols list with percentages, and daily activity history
- Export button generates a plain-text report and shares via share sheet (`share_plus`)
- Clear data option with confirmation dialog
- Added Usage Stats entry in Settings screen between Symbols and TTS sections
- `flutter analyze` passes clean
**Learned:** Consumer/Provider rebuilds handle the stats display well since AppState already calls `notifyListeners()` after speak/addToSentence. The stats service doesn't need to call notifyListeners itself — it just persists silently.
**Blocked:** Nothing
**Next:** Dark/light theme toggle, sound effects for tile taps, onboarding tutorial. Device testing still needed.

## 2026-04-30 — Claude Opus 4.6
**Task:** Dark/light theme toggle (LOW priority)
**Done:**
- Added `darkMode` property to AppState with SharedPreferences persistence (defaults to true/dark)
- MaterialApp now uses `theme`/`darkTheme`/`themeMode` pattern to switch between light and dark Material 3 themes
- Dark theme keeps `scaffoldBackgroundColor: Colors.black` for high-contrast accessibility
- Light theme uses Material 3 auto-generated light palette from blue seed
- Replaced all hardcoded `Colors.*` across 11 files with `Theme.of(context).colorScheme.*` equivalents
- Added "Appearance" section to Settings with Dark Mode SwitchListTile (sun/moon icon)
- Status bar icon brightness adapts to selected theme
- SymbolTile flash animation refactored: replaced `ColorTween` with `Color.lerp` using theme colors (avoids needing context in initState)
- `flutter analyze` passes clean
**Learned:** The original codebase had ~100+ hardcoded color references across 11 files. Material 3's `ColorScheme` surface container hierarchy (`surfaceContainer`, `surfaceContainerHigh`, `surfaceContainerHighest`) maps well to the existing visual hierarchy (chips < tiles < cards/sections). `Color.lerp` with an animation controller value is simpler than `ColorTween` when colors need to come from the theme context rather than initState.
**Blocked:** Nothing
**Next:** Sound effects for tile taps, onboarding tutorial. Device testing still needed.

## 2026-04-30 — Claude Opus 4.6
**Task:** Add sound effects option for tile taps (LOW priority)
**Done:**
- Created `SoundService` that generates a 50ms 800Hz click WAV programmatically at runtime — no bundled audio assets needed
- WAV generation uses sine wave with exponential decay, 22050Hz 16-bit mono PCM (~2KB)
- Added `audioplayers` dependency; `SoundService.playTap()` plays via `BytesSource`
- Added `soundEffects` toggle to AppState with SharedPreferences persistence (defaults to off)
- Sound plays on both single taps (`speakSymbol`) and long-press sentence building (`addToSentence`)
- Toggle in Settings > Appearance section with volume_up/volume_off icon
- `sound.init()` added to parallel startup in `AppState.init()`
- `sound.dispose()` called in `AppState.dispose()`
- `flutter analyze` passes clean
**Learned:** `audioplayers` `BytesSource` accepts a raw `Uint8List` WAV, eliminating the need for asset files. Generating the WAV programmatically keeps the project simpler — no audio files to manage. The sound effect is intentionally fire-and-forget (not awaited) so it doesn't block TTS playback.
**Blocked:** Nothing
**Next:** Onboarding tutorial overlay. Device testing still needed.

## 2026-04-30 — Claude Opus 4.6
**Task:** Onboarding tutorial overlay for first launch (LOW priority)
**Done:**
- Created `OnboardingOverlay` widget with 5 tutorial steps: welcome, tap to speak, build sentences, browse categories, customize settings
- Each step has an emoji illustration, title, and description with Next/Skip buttons and progress dots
- Overlay renders as a full-screen semi-transparent layer on top of HomeScreen via `Positioned.fill` in the existing Stack
- Added `onboardingComplete` flag to AppState with SharedPreferences persistence (defaults to false)
- `completeOnboarding()` method sets the flag and persists; overlay disappears via Consumer rebuild
- All text 18sp+, buttons 60dp height, high contrast — meets AAC accessibility requirements
- `flutter analyze` passes clean
**Learned:** Using `Positioned.fill` inside the existing HomeScreen Stack is cleaner than wrapping HomeScreen in a new Stack — it keeps the overlay as a sibling of the camera PiP and avoids nesting complexity. The `scrim` color from ColorScheme with 0.85 alpha gives a good semi-transparent overlay that works well in both dark and light themes.
**Blocked:** Nothing
**Next:** All backlog items complete except physical device testing. No remaining LOW priority items.

## 2026-04-30 — Claude Opus 4.6
**Task:** Shift check-in — verify codebase health, look for remaining work
**Done:**
- Ran `flutter analyze` — passes clean, zero issues
- Audited full codebase for missed issues: no TODOs/FIXMEs, no null safety problems, no deprecated APIs, all controllers properly disposed
- Discovered one cosmetic issue: stream subscriptions in `AppState.init()` (lines 125-126) aren't stored or cancelled in `dispose()` — not a practical leak since `vision.dispose()` closes the underlying `StreamController`s, but added to LOW backlog for correctness
- Confirmed all HIGH, MEDIUM, and LOW backlog items complete; only remaining item is physical device testing
**Learned:** The codebase is in good shape. Stream subscription cleanup is technically best practice even when the StreamController itself is disposed, because closing a controller doesn't cancel subscriptions — it sends a done event and the subscription stays allocated until GC. In this app it's irrelevant (AppState is a singleton) but worth noting.
**Blocked:** No code work to do — all backlog items complete. Physical device testing requires hardware.
**Next:** Physical device testing is the only remaining task. Consider adding new features to the backlog (e.g., multi-language support, symbol categories from camera context, caregiver mode).

## 2026-05-01 — Claude Opus 4.6
**Task:** Fix stream subscription cleanup in AppState (LOW priority backlog item)
**Done:**
- Added `dart:async` import and two `StreamSubscription` fields (`_detectedObjectsSub`, `_visionErrorSub`) to AppState
- Stored return values from `vision.detectedObjects.listen()` and `vision.errors.listen()` in init()
- Added `cancel()` calls for both subscriptions in `dispose()`, before service disposal
- `flutter analyze` passes clean
**Learned:** Nothing surprising — straightforward fix. All backlog items are now complete except physical device testing.
**Blocked:** Nothing
**Next:** Physical device testing is the only remaining task. All code backlog items are complete.

## 2026-05-01 — Claude Opus 4.6
**Task:** Accessibility audit and fixes — enforce 16sp minimum text and 60dp minimum touch targets
**Done:**
- Ran full codebase audit; discovered 3 text-size violations and 3 touch-target violations against project design principles
- Fixed font size 14→16sp in home_screen.dart (sidebar Settings label) and usage_stats_screen.dart (summary card titles)
- Fixed font size 12→16sp in suggestion_bar.dart ("Suggested" label)
- Increased recent_phrases_bar.dart bar height 52→68dp and chip minHeight 36→60dp
- Increased manage_symbols_screen.dart icon button constraints from 48x48 to 60x60dp (delete + visibility toggles)
- Added `.catchError()` to unawaited cloud suggestion fetch in app_state.dart to prevent unhandled Future errors
- `flutter analyze` passes clean
**Learned:** The original codebase had several spots that slipped under the 16sp/60dp accessibility minimums stated in CLAUDE.md. These are easy to miss during incremental development — periodic audits catch them. The cloud suggestion `.then()` chain had no error handler, which would surface as an unhandled exception in debug mode if the API request failed after the CloudService catch block (e.g., during JSON parsing of the response).
**Blocked:** Nothing
**Next:** Physical device testing is the only remaining task. All code backlog items are complete.
