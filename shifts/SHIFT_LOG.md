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
