import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import 'symbol_tile.dart';

class SuggestionBar extends StatelessWidget {
  const SuggestionBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (state.suggestedSymbols.isEmpty) {
          return const SizedBox.shrink();
        }
        return Container(
          height: 100,
          color: Colors.blue[900],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 12, top: 4),
                child: Text(
                  'Suggested',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
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
              ),
            ],
          ),
        );
      },
    );
  }
}
