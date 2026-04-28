import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import 'symbol_tile.dart';

class AacGrid extends StatelessWidget {
  const AacGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final symbols = state.filteredSymbols;
        final isLandscape =
            MediaQuery.of(context).orientation == Orientation.landscape;
        // In landscape, add 2 extra columns to use the wider space
        final columns =
            isLandscape ? state.gridColumns + 2 : state.gridColumns;
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: symbols.length,
          itemBuilder: (context, index) {
            final symbol = symbols[index];
            return SymbolTile(
              symbol: symbol,
              onTap: () => state.speakSymbol(symbol),
              onLongPress: () => state.addToSentence(symbol),
            );
          },
        );
      },
    );
  }
}
