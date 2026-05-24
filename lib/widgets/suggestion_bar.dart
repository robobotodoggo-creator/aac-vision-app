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
        final frozen = state.suggestionsFrozen;
        // Show the bar (with header + freeze toggle) whenever the camera is on,
        // so the freeze control is always reachable. Otherwise hide entirely.
        if (!state.cameraEnabled && state.suggestedSymbols.isEmpty) {
          return const SizedBox.shrink();
        }
        return Container(
          height: 100,
          color: cs.primaryContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(left: 12, top: 4, right: 4),
                child: Row(
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        frozen ? 'Suggested (paused)' : 'Suggested',
                        style: TextStyle(
                          color: cs.onPrimaryContainer,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Semantics(
                      label: frozen
                          ? 'Resume suggestion updates'
                          : 'Pause suggestion updates',
                      button: true,
                      child: IconButton(
                        constraints: const BoxConstraints(
                            minWidth: 60, minHeight: 60),
                        iconSize: 28,
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          frozen ? Icons.lock : Icons.lock_open,
                          color: cs.onPrimaryContainer,
                        ),
                        onPressed: state.toggleSuggestionsFrozen,
                        tooltip: frozen
                            ? 'Resume suggestions'
                            : 'Pause suggestions',
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: state.suggestedSymbols.isEmpty
                    ? Center(
                        child: Text(
                          frozen ? 'Updates paused' : 'Looking…',
                          style: TextStyle(
                              color: cs.onPrimaryContainer
                                  .withValues(alpha: 0.6),
                              fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: state.suggestedSymbols.length,
                        itemBuilder: (context, index) {
                          final symbol = state.suggestedSymbols[index];
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            child: SizedBox(
                              width: 80,
                              child: SymbolTile(
                                symbol: symbol,
                                onTap: () => state.speakSymbol(symbol),
                                onLongPress: () =>
                                    state.addToSentence(symbol),
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
