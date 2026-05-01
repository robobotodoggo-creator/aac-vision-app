# Handoff — Current State

## Last Updated
2026-04-30 by Claude Opus 4.6

## Project Status
All HIGH, MEDIUM, and LOW priority backlog items complete. Only remaining item is physical device testing (MEDIUM). `flutter analyze` passes clean. APK build not verified (no Java runtime on this machine). App has NOT been tested on a physical device yet.

## What's Working
- Full project structure with models, services, screens, widgets
- 56 default AAC symbols across 7 categories (core, food, feelings, actions, people, places, emergency)
- **Onboarding tutorial overlay** — 5-step first-launch walkthrough (welcome, tap to speak, sentence building, categories, settings); full-screen overlay with emoji illustrations, progress dots, Skip/Next buttons; persisted in SharedPreferences so it only shows once; 18sp+ text, 60dp+ buttons, works in both dark/light themes
- **Tap sound effects** — Settings > Appearance with toggle (off by default); SoundService generates a 50ms click WAV programmatically at runtime (no asset files); plays via `audioplayers` `BytesSource` on single taps and long-press sentence building; non-blocking so TTS isn't delayed
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
- Settings screen (appearance/theme/sound, camera toggle with error display, cloud toggle, API key, grid size, TTS rate/pitch, manage symbols, usage stats)
- **Loading screen** — app shows branded loading screen with spinner during initialization
- **Suggestion bar** — gradient fade overflow indicator when >3 suggestions
- Material 3 theming with dark/light support, high contrast, wakelock, haptic feedback
- Android permissions (CAMERA, INTERNET, VIBRATE, WAKE_LOCK)
- Recent phrases bar (persisted, tappable for re-speak)
- Visual flash animation on tile tap (200ms flash for accessibility)

## What Needs Attention Next
1. **Device testing** — Need to test on actual Samsung Galaxy Tab S10+ or any Android device
2. **Java runtime** — APK builds require Java; not installed on current dev machine

## Key Files Changed This Shift
- `lib/widgets/onboarding_overlay.dart` — New file; 5-step tutorial overlay with emoji illustrations, title/description, progress dots, Skip/Next buttons; `OnboardingOverlay` widget takes `onComplete` callback
- `lib/screens/home_screen.dart` — Added `OnboardingOverlay` as a `Positioned.fill` layer in the Stack, shown when `!state.onboardingComplete`
- `lib/services/app_state.dart` — Added `_onboardingComplete` flag with getter, loaded from SharedPreferences in `_loadPreferences()`, `completeOnboarding()` method persists the flag

## Target Device
Samsung Galaxy Tab S10+ (12.4" display, Android, Dimensity 9300+)
But should work on any Android 6.0+ device (minSdk 23).

## Git
- All changes committed and pushed to main
