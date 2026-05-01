import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import 'symbol_tile.dart';

class SuggestionBar extends StatelessWidget {
  const SuggestionBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (state.suggestedSymbols.isEmpty) {
          return const SizedBox.shrink();
        }
        return Container(
          height: 100,
          color: cs.primaryContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Text(
                  'Suggested',
                  style: TextStyle(
                    color: cs.onPrimaryContainer,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: state.suggestedSymbols.length,
                      itemBuilder: (context, index) {
                        final symbol = state.suggestedSymbols[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: SizedBox(
                            width: 80,
                            child: SymbolTile(
                              symbol: symbol,
                              onTap: () => state.speakSymbol(symbol),
                              onLongPress: () => state.addToSentence(symbol),
                            ),
                          ),
                        );
                      },
                    ),
                    if (state.suggestedSymbols.length > 3)
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        width: 24,
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  cs.primaryContainer.withValues(alpha: 0),
                                  cs.primaryContainer,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
