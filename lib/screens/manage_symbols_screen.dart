import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class ManageSymbolsScreen extends StatefulWidget {
  const ManageSymbolsScreen({super.key});

  @override
  State<ManageSymbolsScreen> createState() => _ManageSymbolsScreenState();
}

class _ManageSymbolsScreenState extends State<ManageSymbolsScreen> {
  String _selectedCategory = 'core';

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final symbols = state.symbolsForCategory(_selectedCategory);
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text('Manage Symbols'),
            backgroundColor: Colors.grey[900],
            actions: [
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: Colors.grey[900],
                      title: const Text('Reset All?',
                          style: TextStyle(color: Colors.white)),
                      content: const Text(
                          'This will restore default symbol order and make all symbols visible.',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 16)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel',
                              style: TextStyle(fontSize: 16)),
                        ),
                        TextButton(
                          onPressed: () {
                            state.resetSymbolCustomizations();
                            Navigator.pop(ctx);
                          },
                          child: const Text('Reset',
                              style: TextStyle(
                                  color: Colors.redAccent, fontSize: 16)),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Reset',
                    style: TextStyle(color: Colors.redAccent, fontSize: 16)),
              ),
            ],
          ),
          body: Column(
            children: [
              // Category selector
              SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  children: state.categories.map((cat) {
                    final isSelected = cat == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(
                          cat[0].toUpperCase() + cat.substring(1),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: Colors.blue[700],
                        backgroundColor: Colors.grey[800],
                        onSelected: (_) =>
                            setState(() => _selectedCategory = cat),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Drag to reorder. Tap the eye to show/hide.',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ),
              // Reorderable symbol list
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: symbols.length,
                  onReorder: (oldIndex, newIndex) {
                    state.reorderSymbol(
                        _selectedCategory, oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final symbol = symbols[index];
                    final isHidden = state.isSymbolHidden(symbol.id);
                    return Container(
                      key: ValueKey(symbol.id),
                      margin: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 4),
                      decoration: BoxDecoration(
                        color: isHidden
                            ? Colors.grey[900]
                            : Colors.grey[850],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Opacity(
                        opacity: isHidden ? 0.5 : 1.0,
                        child: ListTile(
                          leading: Text(symbol.emoji,
                              style: const TextStyle(fontSize: 28)),
                          title: Text(
                            symbol.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isHidden
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: isHidden
                                      ? Colors.white38
                                      : Colors.blue[300],
                                  size: 28,
                                ),
                                onPressed: () =>
                                    state.toggleSymbolVisibility(symbol.id),
                                constraints: const BoxConstraints(
                                    minHeight: 48, minWidth: 48),
                              ),
                              const SizedBox(width: 8),
                              ReorderableDragStartListener(
                                index: index,
                                child: const Icon(Icons.drag_handle,
                                    color: Colors.white54, size: 28),
                              ),
                            ],
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
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
