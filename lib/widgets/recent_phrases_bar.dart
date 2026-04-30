import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class RecentPhrasesBar extends StatelessWidget {
  const RecentPhrasesBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (state.recentPhrases.isEmpty) {
          return const SizedBox.shrink();
        }
        return Container(
          height: 52,
          color: cs.surfaceContainerHigh,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Icon(Icons.history, color: cs.outline, size: 20),
              ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: state.recentPhrases.length,
                  itemBuilder: (context, index) {
                    final phrase = state.recentPhrases[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8),
                      child: Material(
                        color: cs.surfaceContainer,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            state.speakPhrase(phrase);
                          },
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 36),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            child: Center(
                              child: Text(
                                phrase,
                                style: TextStyle(
                                  color: cs.onSurface,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
