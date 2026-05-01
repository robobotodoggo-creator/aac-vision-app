import 'package:flutter/material.dart';

/// A step in the onboarding tutorial.
class _OnboardingStep {
  final String emoji;
  final String title;
  final String description;

  const _OnboardingStep({
    required this.emoji,
    required this.title,
    required this.description,
  });
}

const _steps = [
  _OnboardingStep(
    emoji: '\u{1F44B}',
    title: 'Welcome to AAC Vision',
    description:
        'This app helps you communicate by tapping picture symbols that speak out loud.',
  ),
  _OnboardingStep(
    emoji: '\u{1F5E3}',
    title: 'Tap to Speak',
    description:
        'Tap any symbol once to say it immediately. The word will be spoken aloud.',
  ),
  _OnboardingStep(
    emoji: '\u{1F4DD}',
    title: 'Build Sentences',
    description:
        'Long-press symbols to add them to the sentence bar at the top. Then tap Speak to say the full sentence.',
  ),
  _OnboardingStep(
    emoji: '\u{1F4C2}',
    title: 'Browse Categories',
    description:
        'Use the category tabs to find symbols for food, feelings, actions, people, places, and more.',
  ),
  _OnboardingStep(
    emoji: '\u{2699}',
    title: 'Customize in Settings',
    description:
        'Open Settings to adjust grid size, speech speed, add custom symbols, enable the camera, and more.',
  ),
];

/// Full-screen onboarding overlay shown on first launch.
/// Calls [onComplete] when the user finishes or skips.
class OnboardingOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingOverlay({super.key, required this.onComplete});

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay> {
  int _currentStep = 0;

  void _next() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      widget.onComplete();
    }
  }

  void _skip() {
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final step = _steps[_currentStep];
    final isLast = _currentStep == _steps.length - 1;

    return ColoredBox(
      color: cs.scrim.withValues(alpha: 0.85),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Emoji illustration
                  Text(step.emoji, style: const TextStyle(fontSize: 72)),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    step.title,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    step.description,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 18,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Progress dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_steps.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: CircleAvatar(
                          radius: 6,
                          backgroundColor: i == _currentStep
                              ? cs.primary
                              : cs.onSurface.withValues(alpha: 0.3),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),

                  // Buttons
                  Row(
                    children: [
                      // Skip button (hidden on last step)
                      if (!isLast)
                        Expanded(
                          child: SizedBox(
                            height: 60,
                            child: OutlinedButton(
                              onPressed: _skip,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: cs.outline),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'Skip',
                                style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (!isLast) const SizedBox(width: 16),

                      // Next / Get Started button
                      Expanded(
                        child: SizedBox(
                          height: 60,
                          child: FilledButton(
                            onPressed: _next,
                            style: FilledButton.styleFrom(
                              backgroundColor: cs.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              isLast ? 'Get Started' : 'Next',
                              style: TextStyle(
                                color: cs.onPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
