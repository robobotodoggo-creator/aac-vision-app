# AAC Vision App Backlog

## HIGH Priority
- [ ] Add camera permissions to AndroidManifest.xml (INTERNET, CAMERA, VIBRATE, WAKE_LOCK)
- [ ] Test flutter build on Android — fix any build errors
- [ ] Add recent phrases bar above the category tabs for quick re-use
- [ ] Implement proper error handling in vision_service.dart (camera unavailable, ML Kit init failure)
- [ ] Add haptic feedback confirmation (visual flash on tile tap)

## MEDIUM Priority
- [ ] Add landscape layout optimization for tablet (S10+ is 12.4")
- [ ] Implement symbol search/filter within categories
- [ ] Add ability to customize/reorder symbols from settings
- [ ] Cache TTS initialization for faster first-speak
- [ ] Add loading state while app initializes
- [ ] Make suggestion bar scrollable with overflow indicator
- [ ] Settings: persist TTS rate/pitch values (currently hardcoded)

## LOW Priority
- [ ] Custom symbol creation (add new symbols with emoji + label)
- [ ] Export/import symbol configurations as JSON
- [ ] Add usage analytics (local only — which symbols used most, for therapist reports)
- [ ] Dark/light theme toggle (dark is default, some users may prefer light)
- [ ] Add sound effects option for tile taps (in addition to TTS)
- [ ] Onboarding tutorial overlay for first launch

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
