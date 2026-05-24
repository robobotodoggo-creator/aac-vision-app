# Handoff — Current State

## Last Updated
2026-05-24 by Claude Opus 4.6

## Project Status
All HIGH, MEDIUM, and LOW priority code backlog items are complete. Physical device testing (MEDIUM) still pending. `flutter analyze` passes clean. 68 tests pass. **URGENT.md exists** — cron-disable request still unactioned (87th no-op check-in).

## What's Working
- Full project structure with models, services, screens, widgets
- 56 default AAC symbols across 7 categories (core, food, feelings, actions, people, places, emergency)
- **Suggestion sensitivity settings** — stability threshold (1–5 frames), sticky TTL (1–15s), visible cap (3–12) configurable via sliders in Settings; persisted in SharedPreferences
- **Widget test suite** — 68 tests covering AacSymbol model, AppState logic (sentences, categories, search, custom symbols, defaults, suggestion settings, import/export), SymbolTile, SentenceBar, SuggestionBar, OnboardingOverlay, AacGrid, SymbolSearchBar, RecentPhrasesBar
- **TalkBack/Semantics accessibility** — all interactive widgets wrapped with Semantics labels for Android screen reader support
- **Onboarding tutorial overlay** — 5-step first-launch walkthrough; persisted in SharedPreferences
- **Tap sound effects** — programmatic WAV generation, toggle in Settings (off by default)
- **Dark/light theme toggle** — Material 3 theming, all widgets use ColorScheme
- **Custom symbol creation** — add new symbols with emoji + label via FAB
- **Export/import symbol config** — JSON format via share sheet / file picker
- **Usage analytics** — local-only tracking, therapist report export, clear stats via AppState
- Symbol grid with category tabs
- **Symbol customization** — reorder, show/hide, delete custom symbols
- **Symbol search/filter** — search bar filters by label within category
- **Landscape layout** — vertical sidebar, auto-increased grid columns
- Sentence builder (long-press to compose, tap Speak)
- TTS service with persisted rate/pitch and cached initialization
- Vision service (Google ML Kit, ~5fps) with error handling
- Context service (JSON-based object-to-symbol mappings)
- Cloud service (Claude API, 30s cache, 5s timeout) with error handling on fetch
- Settings screen (appearance, camera, suggestion sensitivity, cloud, API key, grid size, TTS, symbols, usage stats)
- Loading screen during initialization
- Suggestion bar with gradient fade overflow indicator
- Material 3 theming, high contrast, wakelock, haptic feedback
- Android permissions (CAMERA, INTERNET, VIBRATE, WAKE_LOCK)
- Recent phrases bar (persisted, tappable, 60dp touch targets)
- Visual flash animation on tile tap
- All text 16sp+, all touch targets 60dp+
- All destructive-action colors use ColorScheme.error
- All service calls from widgets route through AppState for proper Provider rebuilds
- Camera frame temp files cleaned up after ML Kit processing
- Cloud suggestion callback guards against disposed AppState
- Dialog TextEditingControllers properly disposed on close
- SharedPreferences JSON parsing resilient to corrupted data

## What Needs Attention Next
1. **DISABLE THE CRON** — See shifts/URGENT.md. 87+ no-op check-ins is unacceptable compute waste.
2. **Device testing** — Need to test on actual Samsung Galaxy Tab S10+ or any Android device
3. **Java runtime** — APK builds require Java; not installed on current dev machine
4. **New features** — All code tasks done; consider adding multi-language support, predictive phrases, or caregiver lock mode to backlog if project needs to grow

## Key Files Changed This Shift
No code changes — 87th no-op check-in. Only shift documents updated.

## Target Device
Samsung Galaxy Tab S10+ (12.4" display, Android, Dimensity 9300+)
But should work on any Android 6.0+ device (minSdk 23).

## Git
- All changes committed and pushed to main
