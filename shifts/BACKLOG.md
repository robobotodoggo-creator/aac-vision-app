# AAC Vision App Backlog

## HIGH Priority
- [ ] Add suggestion-bar sensitivity slider in Settings — let users tune the stability threshold (3-of-5 frames default), sticky TTL (5s default), and visible cap (6 default) without rebuilding (added 2026-05-23)

## RESEARCH (low priority, write findings to docs/research/)
- [ ] **Kotlin / native rewrite feasibility:** Build the same app in Kotlin + CameraX + native ML Kit. Measure cold-start time, memory footprint, sustained battery drain over 30 min of camera-on use, frame latency for label-to-suggestion. Compare against current Flutter version on the same Samsung Tab S9 Ultra. Report whether the gain justifies maintaining two codebases. (added 2026-05-23)
- [ ] **Older / cheaper Android device benchmarks:** Same app, three target tablets: Samsung Tab A (entry-level, ~$150), Tab S6 Lite (mid, ~$300), Tab S9 Ultra (current). Measure ML Kit label latency, dropped-frame rate, battery drain. Goal: document the minimum viable hardware for this app to be usable for stroke survivors on a budget. (added 2026-05-23)
- [ ] **External vision compute investigation:** Research feasibility of pairing the tablet (display + UI) with an external compute board (Raspberry Pi 5, Jetson Orin Nano, Coral USB Accelerator) for vision processing. Questions to answer: does ML Kit's on-device speed already saturate the bottleneck? Would offloading vision to a more powerful board meaningfully improve label quality, detection of small/distant objects, or simultaneous-object count? What's the latency cost of sending camera frames over USB/Wi-Fi/BLE to an external board? Mockup a rigid case design that could house tablet + small SBC + battery. Write up tradeoffs and a recommendation. (added 2026-05-23)
- [ ] **Screenshot-in-the-loop dev workflow:** Investigate adding `adb shell screencap` + Claude Vision check to the autonomous shift loop, so agents can verify visual correctness of their UI changes before committing. Prototype: shift runs flutter test, builds APK, installs on attached device, takes screenshot of each major screen, sends to Claude Vision with the diff for a "does this look right?" pass. (added 2026-05-23)

- [x] Fix text below 16sp minimum in 3 locations (accessibility violation of project design principles)
- [x] Fix touch targets below 60dp minimum in 3 locations (accessibility violation of project design principles)
- [x] Add .catchError() to unawaited cloud suggestion fetch in AppState (error handling gap)
- [x] Fix camera image file leak — takePicture() temp files never deleted, accumulates ~18k files/hour at 5fps (discovered 2026-05-02)
- [x] Fix cloud suggestion callback — notifyListeners() on disposed AppState crashes in debug mode (discovered 2026-05-02)
- [x] Fix TextEditingController leaks in add-symbol dialog — controllers never disposed (discovered 2026-05-02)
- [x] Fix sentence bar chip delete targeting wrong symbol — all chips called removeLastFromSentence() instead of removing the tapped chip (discovered 2026-05-02)

## MEDIUM Priority
- [x] Add landscape layout optimization for tablet (S10+ is 12.4")
- [x] Implement symbol search/filter within categories
- [x] Settings: persist TTS rate/pitch values
- [x] Add loading state while app initializes
- [x] Make suggestion bar scrollable with overflow indicator
- [x] Add ability to customize/reorder symbols from settings
- [x] Investigate stale `.metadata` and `build.gradle.kts` changes (reverted — caused by `flutter create --platforms web`)
- [x] Cache TTS initialization for faster first-speak
- [ ] Test on physical Android device

## LOW Priority
- [x] Add widget test suite for core functionality (model, state logic, SymbolTile, SentenceBar) — 25 tests (completed 2026-05-03)
- [x] Expand test coverage (suggestion bar, grid widget, onboarding overlay, search bar, recent phrases bar, AppState logic) — 65 tests total (completed 2026-05-03)
- [x] Fix markNeedsBuild() hack in UsageStatsScreen — route stats clear through AppState.notifyListeners() (discovered 2026-05-02)
- [x] Fix unawaited _tts.stop() in TtsService.dispose() — wrap with unawaited() for clarity (discovered 2026-05-02)
- [x] Replace hardcoded destructive-action colors with ColorScheme.error (discovered 2026-05-01 — leftover from theming migration)
- [x] Custom symbol creation (add new symbols with emoji + label)
- [x] Export/import symbol configurations as JSON
- [x] Add usage analytics (local only — which symbols used most, for therapist reports)
- [x] Dark/light theme toggle (dark is default, some users may prefer light)
- [x] Add sound effects option for tile taps (in addition to TTS)
- [x] Onboarding tutorial overlay for first launch
- [x] Add `web/` to .gitignore (untracked Flutter web scaffold, not needed)
- [x] Store stream subscriptions in AppState and cancel in dispose() (discovered 2026-04-30 — cosmetic, not a practical leak since vision.dispose() closes the controllers)
- [x] Add Semantics widgets for Android TalkBack support — wrap interactive widgets (symbol tiles, category buttons, sentence bar chips, settings controls) with Semantics labels so caregivers using screen readers can navigate the app (completed 2026-05-04)
- [x] Harden SharedPreferences and cloud API JSON parsing against corrupted data — try-catch with fallback defaults prevents startup crash from corrupted prefs; explicit null/bounds checks in cloud response parsing (completed 2026-05-04)

## DONE
- [x] Project scaffold and dependency setup
- [x] AAC symbol model and default symbols (56 symbols, 7 categories)
- [x] Symbol grid with category tabs
- [x] Sentence builder (long-press to add, Speak button)
- [x] TTS service
- [x] Vision service (Google ML Kit object detection)
- [x] Context mapping service (object -> symbol suggestions)
- [x] Cloud service (Claude API integration)
- [x] Settings screen
- [x] Camera PiP preview widget
- [x] Suggestion bar widget
- [x] Add camera permissions to AndroidManifest.xml
- [x] Test flutter build on Android — builds clean
- [x] Add recent phrases bar above category tabs
- [x] Implement proper error handling in vision_service.dart
- [x] Add haptic feedback visual flash on tile tap
