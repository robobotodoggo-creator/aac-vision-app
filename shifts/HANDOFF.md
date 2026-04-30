# Handoff — Current State

## Last Updated
2026-04-30 by Claude Opus 4.6

## Project Status
All HIGH and MEDIUM priority items complete. Top four LOW items (custom symbol creation, export/import config, usage analytics, dark/light theme toggle) also done. `flutter analyze` passes clean. APK build not verified (no Java runtime on this machine). App has NOT been tested on a physical device yet.

## What's Working
- Full project structure with models, services, screens, widgets
- 56 default AAC symbols across 7 categories (core, food, feelings, actions, people, places, emergency)
- **Dark/light theme toggle** — Settings > Appearance with Dark Mode switch; uses Material 3 `colorSchemeSeed` theming; all widgets use `Theme.of(context).colorScheme.*` instead of hardcoded colors; dark mode (default) keeps high-contrast black scaffold; light mode uses M3 auto-generated light palette; preference persisted in SharedPreferences; status bar icons adapt to theme
- **Custom symbol creation** — Users can add new symbols with emoji + label via FAB on Manage Symbols screen; custom symbols persisted in SharedPreferences; deletable with confirmation dialog
- **Export/import symbol config** — Overflow menu on Manage Symbols screen with Export (share sheet), Import (file picker), and Reset options; JSON format includes custom symbols, hidden IDs, and symbol order
- **Usage analytics** — Local-only symbol usage tracking; UsageStatsScreen (Settings > Usage Stats) shows summary cards, most-used symbols with percentages, daily activity; export as text report for therapists; clear data with confirmation; tracks both single taps and sentence-building long-presses
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
- Settings screen (appearance/theme, camera toggle with error display, cloud toggle, API key, grid size, TTS rate/pitch, manage symbols, usage stats)
- **Loading screen** — app shows branded loading screen with spinner during initialization
- **Suggestion bar** — gradient fade overflow indicator when >3 suggestions
- Material 3 theming with dark/light support, high contrast, wakelock, haptic feedback
- Android permissions (CAMERA, INTERNET, VIBRATE, WAKE_LOCK)
- Recent phrases bar (persisted, tappable for re-speak)
- Visual flash animation on tile tap (200ms flash for accessibility)

## What Needs Attention Next
1. **Device testing** — Need to test on actual Samsung Galaxy Tab S10+ or any Android device
2. **Java runtime** — APK builds require Java; not installed on current dev machine
3. **Sound effects for tile taps** — Next LOW priority item

## Key Files Changed This Shift
- `lib/main.dart` — MaterialApp now switches between dark/light ThemeData based on `state.darkMode`; Consumer wraps MaterialApp for reactive theme; status bar icons adapt; loading screen uses theme colors
- `lib/services/app_state.dart` — Added `_darkMode` field, `darkMode` getter, `setDarkMode()` with SharedPreferences persistence; loaded in `_loadPreferences()`
- `lib/screens/settings_screen.dart` — New "Appearance" section with Dark Mode toggle (SwitchListTile with sun/moon icon); all hardcoded colors replaced with theme-aware equivalents
- `lib/screens/home_screen.dart` — All hardcoded `Colors.*` replaced with `Theme.of(context).colorScheme.*`
- `lib/widgets/symbol_tile.dart` — Flash animation uses `Color.lerp` with theme colors instead of hardcoded `ColorTween`; label color from theme
- `lib/widgets/sentence_bar.dart` — Theme-aware container, chip, and text colors
- `lib/widgets/suggestion_bar.dart` — Theme-aware container and gradient colors
- `lib/widgets/recent_phrases_bar.dart` — Theme-aware bar and pill colors
- `lib/widgets/symbol_search_bar.dart` — Theme-aware input styling
- `lib/screens/manage_symbols_screen.dart` — Theme-aware dialogs, list items, FAB, and menu
- `lib/screens/usage_stats_screen.dart` — Theme-aware summary cards, rows, and section headers

## Target Device
Samsung Galaxy Tab S10+ (12.4" display, Android, Dimensity 9300+)
But should work on any Android 6.0+ device (minSdk 23).

## Git
- All changes committed and pushed to main
