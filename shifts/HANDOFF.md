# Handoff — Current State

## Last Updated
2026-05-29 by Claude Opus 4.6

## Project Status
All HIGH, MEDIUM (except physical device testing), and LOW priority code backlog items are complete. Three RESEARCH items completed (external vision compute, screenshot-in-the-loop workflow, custom TFLite model). Golden tests (Phase 1) implemented — 8 golden tests added, 76 total tests pass. `flutter analyze` passes clean. **URGENT.md exists** — cron-disable request still unactioned (109th check-in).

## What's Working
- Full project structure with models, services, screens, widgets
- 56 default AAC symbols across 7 categories (core, food, feelings, actions, people, places, emergency)
- **Golden tests (Phase 1)** — 8 golden tests covering SymbolTile (dark/light), SentenceBar (empty/populated), AacGrid (4-col grid), OnboardingOverlay (step 1 + 5), SymbolSearchBar; catches layout/sizing regressions deterministically
- **Suggestion sensitivity settings** — stability threshold (1–5 frames), sticky TTL (1–15s), visible cap (3–12) configurable via sliders in Settings; persisted in SharedPreferences
- **Widget test suite** — 76 tests covering AacSymbol model, AppState logic (sentences, categories, search, custom symbols, defaults, suggestion settings, import/export), SymbolTile, SentenceBar, SuggestionBar, OnboardingOverlay, AacGrid, SymbolSearchBar, RecentPhrasesBar, plus 8 golden visual regression tests
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

## Research Completed
- **External vision compute investigation** (`docs/research/external-vision-compute.md`) — Analyzed Pi 5, Jetson Orin Nano, Coral USB. Conclusion: not recommended. No on-device compute bottleneck exists; transfer latency negates gains; added cost/fragility violates AAC reliability principles.
- **Screenshot-in-the-loop dev workflow** (`docs/research/screenshot-in-the-loop.md`) — Evaluated three approaches: adb+Claude Vision, Flutter golden tests, Flutter integration tests. Recommendation: add golden tests now (no device needed, catches layout regressions); defer adb+Vision to when a device is permanently connected. Cost is negligible (~$3–6/month). Blocking constraint is device availability, not technical feasibility. **Phase 1 (golden tests) now implemented.**
- **Custom AAC-trained TFLite vision model** (`docs/research/custom-tflite-model.md`) — Cataloged 500 AAC-relevant object classes across 11 domains. ML Kit's default ~400-class model only has ~50 classes useful for AAC (10%). OpenImages V7 covers ~120 of the 500 target classes; ~330 need new data collection. Recommended architecture: EfficientNet-Lite0 INT8 (~5 MB, ~6.5 ms CPU latency). Integration is a ~10-line change in vision_service.dart. Per-user personalization feasible via frozen-base + trainable-head architecture. Blocking constraint: dataset curation for AAC-specific classes (mobility aids, therapy tools, communication devices).

## What Needs Attention Next
1. **DISABLE THE CRON** — See shifts/URGENT.md. 109 check-ins and counting.
2. **Device testing** — Need to test on actual Samsung Galaxy Tab S10+ or any Android device
3. **Java runtime** — APK builds require Java; not installed on current dev machine
4. **Remaining RESEARCH items** — Kotlin rewrite feasibility, device benchmarks (both need hardware)
5. **Phase 2: adb + Claude Vision** — Per screenshot research, the full device-screenshot workflow should be added when a device is permanently connected
6. **Custom TFLite model implementation** — Research complete, next step is data collection + model training (needs GPU, Colab sufficient)
7. **New features** — Consider adding multi-language support, predictive phrases, or caregiver lock mode to backlog if project needs to grow

## Key Files Changed This Shift
- No code changes — 105th no-op check-in, updated shift docs only

## Target Device
Samsung Galaxy Tab S10+ (12.4" display, Android, Dimensity 9300+)
But should work on any Android 6.0+ device (minSdk 23).

## Git
- All changes committed and pushed to main
