# Screenshot-in-the-Loop Dev Workflow

**Date:** 2026-05-26
**Author:** Claude Opus 4.6 (shift agent)
**Status:** Research complete
**Backlog item:** "Screenshot-in-the-loop dev workflow" (RESEARCH)

## Summary

Investigated adding automated screenshot capture + AI-powered visual verification to the autonomous shift loop. Three approaches evaluated: (1) adb screenshots with Claude Vision review, (2) Flutter golden tests, (3) Flutter integration tests with screenshot capture. **Recommendation: Implement Flutter golden tests first (no device needed), defer adb+Vision workflow until a device is permanently connected.**

---

## The Concept

After an agent makes UI changes, the shift loop would:

1. Build the debug APK
2. Install on a connected Android device via `adb`
3. Navigate to each major screen
4. Capture screenshots via `adb shell screencap`
5. Send screenshots to Claude Vision API with the code diff
6. Claude Vision checks: layout correctness, touch target sizes, contrast, text legibility, accessibility
7. If Vision flags issues, the agent fixes them before committing

## Screens to Capture

The app has 4 screens + 2 overlays that would need visual verification:

| Screen | Key Visual Checks |
|--------|-------------------|
| HomeScreen (portrait) | Grid layout, 60dp tiles, sentence bar, suggestion bar, category tabs |
| HomeScreen (landscape) | Vertical sidebar, wider grid, correct column count |
| SettingsScreen | All sections visible, slider controls, toggles |
| ManageSymbolsScreen | Symbol list, reorder handles, add button |
| UsageStatsScreen | Chart rendering, export button, stats display |
| OnboardingOverlay | Step indicators, dismiss button, overlay positioning |
| CameraPreview (PiP) | Corner positioning, correct size, not blocking grid |

---

## Approach 1: adb Screenshots + Claude Vision API

### How It Would Work

```bash
#!/bin/bash
# screenshot-check.sh — Visual verification step for relay-runner.sh

DEVICE_SERIAL="$1"
SCREENSHOTS_DIR="shifts/screenshots"
mkdir -p "$SCREENSHOTS_DIR"

# Build and install
flutter build apk --debug
adb -s "$DEVICE_SERIAL" install -r build/app/outputs/flutter-apk/app-debug.apk

# Launch app
adb -s "$DEVICE_SERIAL" shell am start -n com.robobotodoggo.aac_vision_app/.MainActivity
sleep 5  # Wait for app initialization

# Capture home screen (portrait)
adb -s "$DEVICE_SERIAL" shell screencap -p /sdcard/screenshot_home.png
adb -s "$DEVICE_SERIAL" pull /sdcard/screenshot_home.png "$SCREENSHOTS_DIR/home_portrait.png"

# Navigate to settings (requires UI automation — see "Navigation Problem" below)
# ... capture settings, manage symbols, usage stats ...

# Send to Claude Vision for review
# (via API call with the screenshot + diff context)
```

### Navigation Problem

The biggest challenge: **how does the script navigate between screens?** Options:

- **`adb shell input tap X Y`** — Fragile. Coordinates change with device resolution, font scaling, system bars. Breaks across devices.
- **Flutter integration_test driver** — Robust. Uses Flutter's widget tree to find and tap elements by key/semantics. Requires `integration_test` package setup.
- **Appium Flutter Driver** — Third-party. Adds complexity but provides cross-platform automation.
- **Pre-set deep links / route arguments** — Could add `--route` flag to app launch, but Flutter doesn't natively support this without custom code.

**Best option:** Flutter integration test that navigates screens and calls `adb shell screencap` at each stop. This combines reliable navigation with real-device screenshots.

### Claude Vision API Integration

```python
# Pseudocode for the Vision check step
import anthropic

client = anthropic.Anthropic()

def check_screenshot(image_path, screen_name, diff_text):
    with open(image_path, "rb") as f:
        image_data = base64.b64encode(f.read()).decode()

    response = client.messages.create(
        model="claude-sonnet-4-20250514",
        max_tokens=1024,
        messages=[{
            "role": "user",
            "content": [
                {"type": "image", "source": {"type": "base64",
                    "media_type": "image/png", "data": image_data}},
                {"type": "text", "text": f"""
                    This is a screenshot of the {screen_name} in an AAC
                    (Augmentative and Alternative Communication) app for
                    nonverbal users. Check for:

                    1. TOUCH TARGETS: All tappable elements must be at
                       least 60x60dp. Flag anything that looks too small.
                    2. TEXT SIZE: All text must be at least 16sp. Flag
                       any text that appears too small.
                    3. CONTRAST: Dark background with bright icons/text.
                       Flag any low-contrast elements.
                    4. LAYOUT: Grid should be evenly spaced, no overlaps,
                       no clipping. Sentence bar at top, suggestions below.
                    5. ACCESSIBILITY: Clear visual hierarchy, no cluttered
                       areas, large clear symbols.

                    Recent code changes (diff):
                    {diff_text}

                    Report ONLY issues. If everything looks correct, say
                    "PASS". Be specific about locations of any problems.
                """}
            ]
        }]
    )
    return response.content[0].text
```

### Cost Analysis

| Component | Per-check cost | Notes |
|-----------|---------------|-------|
| Screenshot (7 screens) | ~14,000 input tokens | ~2,000 tokens/image |
| Prompt + diff context | ~3,000 input tokens | |
| Response | ~500 output tokens | |
| **Total per shift** | **~$0.05–0.10** | Using Sonnet for cost efficiency |
| **Monthly (2x/day)** | **~$3–6** | Negligible |

Cost is not a concern. The bottleneck is device availability.

### Pros
- Catches real rendering issues (font rendering, system bar interactions, actual pixel output)
- AI can evaluate subjective qualities (does this "look right"?)
- Can check accessibility heuristically (touch target visual size, contrast)
- Works with the actual device the app targets

### Cons
- **Requires a permanently connected Android device** — the dev machine (`roboboto`) doesn't have one
- **Java/Android SDK required** for APK builds — not currently installed
- Screen navigation automation adds complexity
- Device state management (screen on, unlocked, correct orientation) adds fragility
- Non-deterministic — AI may flag false positives or miss real issues

---

## Approach 2: Flutter Golden Tests (No Device Needed)

### How It Would Work

Golden tests render widgets in a test environment and compare the output against saved reference images ("goldens"). No device or emulator required.

```dart
// test/golden/home_screen_golden_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aac_vision_app/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen matches golden', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen()),
    );
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/home_screen.png'),
    );
  });
}
```

```bash
# Generate reference goldens (run once when UI is correct)
flutter test --update-goldens

# Verify against goldens (run in CI/shifts)
flutter test
```

### Pros
- **No device needed** — runs in Flutter's test renderer
- **Deterministic** — pixel-perfect comparison, no AI ambiguity
- **Fast** — runs in seconds, no build/install/screenshot cycle
- **Already partially set up** — 68 widget tests exist, just need golden assertions
- Built into Flutter — no external dependencies
- Can set tolerance threshold (e.g., 0.5% pixel diff allowed)

### Cons
- Test renderer ≠ real device rendering (fonts, system bars, camera preview absent)
- Doesn't catch device-specific issues (Samsung One UI quirks, real resolution)
- Golden files are large binary blobs in git
- Goldens break on Flutter SDK upgrades (renderer changes)
- Cannot verify camera preview or real ML Kit integration

### Suitability for This Project
Golden tests would catch the most common regression type: **a code change that accidentally breaks layout, sizing, or visibility of UI elements.** They're the right first step because they work without hardware.

---

## Approach 3: Flutter Integration Tests + Device Screenshots

### How It Would Work

```dart
// integration_test/screenshot_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Capture all screens', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Home screen
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('home_portrait');

    // Navigate to settings
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('settings');

    // Navigate to manage symbols
    await tester.tap(find.text('Manage Symbols'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('manage_symbols');

    // ... etc
  });
}
```

```bash
# Run on connected device
flutter test integration_test/screenshot_test.dart -d <device-id>
```

### Pros
- Real device rendering (accurate pixels)
- Reliable navigation via widget tree (no coordinate tapping)
- Screenshots can be fed to Claude Vision or compared with golden files
- Flutter's official approach for device testing

### Cons
- **Still requires a connected device or emulator**
- Slower than golden tests (full app boot, real rendering pipeline)
- `takeScreenshot()` has known platform issues on some Android versions
- Emulator screenshots differ from real device screenshots

---

## Integration with relay-runner.sh

If a device were available, the modified shift loop would be:

```
1. Read shift docs, pick task
2. Do the work, commit code changes
3. flutter analyze  (must pass)
4. flutter test     (must pass — includes golden tests)
5. flutter build apk --debug
6. adb install + launch
7. Run integration_test/screenshot_test.dart
8. Send screenshots to Claude Vision with the diff
9. If Vision says PASS → push
10. If Vision flags issues → fix, loop back to step 3
11. Update shift docs
```

Steps 5–10 add ~3–5 minutes per shift and ~$0.05–0.10 in API cost. The main constraint is step 6 requiring a connected, unlocked device.

---

## Recommendation

### Phase 1: Golden Tests (implement now, no hardware needed)

Add golden test assertions to the existing widget test suite. This catches layout regressions immediately and integrates with the current `flutter test` workflow.

**Effort:** ~2 hours of agent work. Add golden test file, generate initial goldens, add `flutter test` to relay-runner pre-commit checks.

**Limitations:** Test renderer only. Won't catch device-specific issues.

### Phase 2: adb + Claude Vision (defer until device is available)

When a Samsung Galaxy Tab S10+ (or any Android device) is permanently connected to the dev machine:

1. Install Java/Android SDK on the dev machine
2. Add `integration_test` package to the project
3. Write integration test that navigates all screens
4. Add screenshot capture + Vision API check to relay-runner.sh
5. Store screenshots in `shifts/screenshots/` (gitignored) for debugging

**Effort:** ~4 hours of agent work once device is available.

### Phase 3: Continuous Visual Monitoring (future)

- Store golden screenshots per commit in cloud storage
- Build a visual diff dashboard
- Alert on regressions via Telegram bot

**This phase is over-engineered for the current project stage.**

---

## Do Not Pursue

- **Emulator-based testing in the shift loop** — Android emulator requires significant resources, adds boot time, and Samsung-specific UI won't be represented. Real device is better.
- **Appium/third-party frameworks** — Adds dependency complexity for marginal benefit over Flutter's built-in integration_test.
- **Claude Computer Use for navigation** — Designed for web/desktop, not Android device control. adb + integration_test is more reliable.

---

## Conclusion

The screenshot-in-the-loop concept is sound and cost-effective (~$3–6/month). The **blocking constraint is device availability**, not technical feasibility. Golden tests (Phase 1) provide immediate value with zero hardware requirements. The full adb+Vision workflow (Phase 2) should be implemented when a device is permanently connected to the dev machine.
