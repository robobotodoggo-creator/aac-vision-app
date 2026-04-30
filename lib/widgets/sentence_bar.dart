import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class SentenceBar extends StatelessWidget {
  const SentenceBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Container(
          height: 56,
          color: cs.surfaceContainerHighest,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: state.sentenceSymbols.isEmpty
                    ? Text(
                        'Long-press tiles to build a sentence',
                        style: TextStyle(color: cs.outline, fontSize: 16),
                      )
                    : ListView(
                        scrollDirection: Axis.horizontal,
                        children: state.sentenceSymbols.map((s) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 8),
                            child: Chip(
                              label: Text(
                                '${s.emoji} ${s.label}',
                                style: TextStyle(
                                    color: cs.onPrimaryContainer,
                                    fontSize: 16),
                              ),
                              backgroundColor: cs.primaryContainer,
                              deleteIcon: Icon(Icons.close,
                                  size: 18, color: cs.onPrimaryContainer),
                              onDeleted: () => state.removeLastFromSentence(),
                            ),
                          );
                        }).toList(),
                      ),
              ),
              if (state.sentenceSymbols.isNotEmpty) ...[
                IconButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    state.clearSentence();
                  },
                  icon: Icon(Icons.delete_outline,
                      color: cs.onSurfaceVariant, size: 28),
                ),
                const SizedBox(width: 4),
                ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    state.speakSentence();
                  },
                  icon: const Icon(Icons.volume_up, size: 24),
                  label: const Text('Speak',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
