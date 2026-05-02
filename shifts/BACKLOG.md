# AAC Vision App Backlog

## HIGH Priority
- [x] Fix text below 16sp minimum in 3 locations (accessibility violation of project design principles)
- [x] Fix touch targets below 60dp minimum in 3 locations (accessibility violation of project design principles)
- [x] Add .catchError() to unawaited cloud suggestion fetch in AppState (error handling gap)

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
