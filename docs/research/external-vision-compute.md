# External Vision Compute Investigation

**Date:** 2026-05-26
**Author:** Claude Opus 4.6 (shift agent)
**Backlog item:** "External vision compute investigation" (RESEARCH, low priority)

## Summary

**Recommendation: Do not pursue external vision compute at this time.** The latency cost of sending camera frames to an external board exceeds the gains, ML Kit's on-device performance is adequate for the app's AAC use case, and the added complexity/cost/fragility directly conflicts with the project's reliability-first design principles.

---

## 1. Current Baseline: On-Device ML Kit

The app currently runs Google ML Kit on the tablet itself:

| Metric | Current Value |
|--------|--------------|
| Processing rate | ~5 fps (200ms timer interval) |
| Models | Image Labeler (447-class) + Object Detector (5 broad categories) |
| Confidence threshold | 0.5 (labeler), 0.6 (object detector) |
| Stability filter | 3-of-5 frames required before surfacing a label |
| Effective label latency | ~600–1000ms (3 frames x 200ms + processing) |
| Resolution | Medium (camera preset) |

**Key observation:** The bottleneck is not compute speed — it's the stability filter. Even if ML Kit processed frames in 1ms, the app deliberately waits for 3 consistent frames before surfacing a label. This means the *perceptible* latency floor is ~600ms regardless of compute power.

### Does ML Kit saturate the bottleneck?

Yes, largely. On a Samsung Galaxy Tab S10+ (Dimensity 9300+), ML Kit image labeling completes in ~30–80ms per frame. Object detection adds ~20–50ms. Total per-frame processing is ~50–130ms, well within the 200ms budget. The tablet's NPU handles these models efficiently.

The app is CPU/NPU-idle ~35–75% of each 200ms window. There is no compute bottleneck to offload.

## 2. External Board Options Analyzed

### 2a. Raspberry Pi 5

- **CPU:** Quad-core Cortex-A76 @ 2.4GHz
- **RAM:** 4/8GB
- **ML capability:** No dedicated NPU. Relies on CPU or optional Hailo-8L M.2 HAT (~13 TOPS)
- **Price:** $60–80 (board only), $100+ with case/power/HAT
- **Power:** 5V/5A (25W peak with peripherals)

**Assessment:** Without the Hailo HAT, the Pi 5 is *slower* than the Tab S10+ for ML inference. The Dimensity 9300+ NPU significantly outperforms a quad A76 running ML models on CPU. With the Hailo HAT, you get dedicated inference hardware, but you also add $70+ and another point of failure.

### 2b. NVIDIA Jetson Orin Nano

- **GPU:** 1024-core Ampere, 40 TOPS
- **RAM:** 4/8GB LPDDR5
- **Price:** $250–500 (dev kit)
- **Power:** 7–15W
- **ML capability:** Excellent. Runs TensorRT-optimized models at high throughput.

**Assessment:** Massive overkill. 40 TOPS of inference capability to run a 447-class image labeler is like using a firehose to water a houseplant. The Jetson excels at multi-stream video analytics, not single-frame AAC labeling. Cost and power draw are prohibitive for a portable AAC device.

### 2c. Google Coral USB Accelerator

- **Chip:** Edge TPU, 4 TOPS
- **Interface:** USB 3.0
- **Price:** $60
- **Power:** ~2W (powered via USB)
- **ML capability:** Runs TFLite models compiled for Edge TPU very efficiently.

**Assessment:** Most interesting option. Compact, low power, purpose-built for edge inference. However, it only runs models compiled specifically for the Edge TPU (requires full integer quantization). ML Kit's built-in models cannot be used — you'd need to find or train compatible TFLite models, losing ML Kit's convenient API entirely.

## 3. Latency Cost of Frame Transfer

Sending camera frames from the tablet to an external board introduces unavoidable latency:

| Transport | Typical Latency (640x480 JPEG, ~50KB) | Notes |
|-----------|----------------------------------------|-------|
| USB 2.0 | ~2–5ms transfer + ~5ms overhead | Requires OTG adapter, wired tether |
| USB 3.0 | ~1–2ms transfer + ~5ms overhead | Same wiring constraint |
| Wi-Fi (LAN) | ~5–20ms transfer + ~10–30ms overhead | Adds network stack, jitter, discovery |
| BLE | ~200–800ms for 50KB | BLE MTU is 247 bytes; 50KB takes ~200+ packets. Completely impractical for images. |

**Round-trip budget** (send frame + receive result):

| Transport | Round-trip | vs. Current 50–130ms On-Device |
|-----------|-----------|-------------------------------|
| USB | ~15–25ms + inference time | Comparable, but adds wiring |
| Wi-Fi | ~30–80ms + inference time | Worse. Adds jitter and unreliability |
| BLE | 400–1600ms+ | Unusable |

USB is the only viable transport, and it matches on-device performance at best — while adding a physical tether, connection management code, and a failure mode (cable disconnect mid-session for an AAC user who needs uninterrupted communication).

## 4. What External Compute Could Improve

The backlog asks whether offloading would improve:

### Label quality
- **Marginal.** ML Kit's 447-class model covers common household, food, people, and place categories well. A more powerful model (e.g., a large ViT or CLIP) could identify more specific objects, but the AAC symbol set has 56 entries. Recognizing 500 vs. 10,000 object classes doesn't help when the output maps to 56 symbols.

### Detection of small/distant objects
- **Possible but not meaningful.** A higher-resolution pipeline (full-res frames + more powerful model) could detect smaller objects. But the app's use case is "what's in front of the user right now" — typically food on a table, a person nearby, a room. These are large, close objects. The camera resolution, not the compute, is the limiting factor for distant objects.

### Simultaneous object count
- **Already adequate.** ML Kit detects multiple objects per frame. The stability filter and suggestion cap (default 6) mean the app intentionally limits how many suggestions it shows. More detections would create noise, not value, for AAC users who need simplicity.

## 5. Physical Case Mockup

If pursued despite the above, a rigid case design would need:

```
┌─────────────────────────────────────┐
│           Tablet (12.4")            │
│      ┌─────────────────────┐        │
│      │                     │        │
│      │    Display / UI     │        │
│      │                     │        │
│      └─────────────────────┘        │
├─────────────────────────────────────┤
│  [SBC]  [Battery]  [USB Hub]        │  ← rear compartment, ~25mm deep
│  (Pi5)  (10000mAh) (USB-C to OTG)  │
└─────────────────────────────────────┘
```

- Total thickness: ~30–35mm (tablet ~6mm + rear case ~25mm)
- Weight: ~400g additional (Pi5 ~50g, battery ~200g, case ~150g)
- Ventilation slots required for SBC thermal management
- USB-C OTG connection from tablet to SBC
- Dedicated power path: battery -> SBC, tablet charges separately
- Estimated BOM: $150–200 (SBC + battery + case + cables)

**Fragility concern:** The tablet's built-in accelerometer, vibration motor, and the user's potential tremor or drop risk make a bolted-on compute module a reliability hazard. AAC devices need to survive drops and rough handling.

## 6. Recommendation

**Do not pursue external vision compute.** The analysis shows:

1. **No compute bottleneck exists.** The Tab S10+ processes frames in 50–130ms against a 200ms budget. The stability filter, not compute, determines perceived latency.
2. **Transfer latency negates any gains.** USB adds wiring; Wi-Fi adds jitter; BLE is unusable.
3. **Label quality gains are marginal.** The 56-symbol AAC vocabulary doesn't benefit from more specific object classification.
4. **Added cost, weight, and fragility violate design principles.** This is an accessibility tool where reliability > features.
5. **Maintenance burden doubles.** External compute requires a separate software stack, connection management, fallback logic, and physical case engineering.

### When to revisit

- If the app's symbol set grows to 200+ and the current 447-class labeler becomes insufficient
- If the use case expands to real-time scene understanding (spatial relationships, activity recognition) that exceeds mobile NPU capability
- If a future tablet lacks adequate on-device ML performance
- If a production AAC hardware enclosure is being custom-manufactured anyway

### Better investment of effort

Rather than external compute, the following would yield more user value:
- **Custom TFLite model** trained on AAC-relevant objects (food items, household objects, people, rooms) for higher accuracy on the things that matter
- **Higher camera resolution preset** for the image labeler (currently set to `medium`)
- **Contextual boosting** — use time of day, location, or recent usage patterns to weight ambiguous labels toward more likely suggestions
