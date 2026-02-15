import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class SentenceBar extends StatelessWidget {
  const SentenceBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Container(
          height: 56,
          color: Colors.grey[900],
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: state.sentenceSymbols.isEmpty
                    ? const Text(
                        'Long-press tiles to build a sentence',
                        style: TextStyle(color: Colors.white38, fontSize: 16),
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
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              backgroundColor: Colors.blue[800],
                              deleteIcon: const Icon(Icons.close,
                                  size: 18, color: Colors.white70),
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
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.white54, size: 28),
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
