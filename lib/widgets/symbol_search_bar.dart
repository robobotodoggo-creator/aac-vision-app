import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class SymbolSearchBar extends StatefulWidget {
  const SymbolSearchBar({super.key});

  @override
  State<SymbolSearchBar> createState() => _SymbolSearchBarState();
}

class _SymbolSearchBarState extends State<SymbolSearchBar> {
  final _controller = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final query = context.read<AppState>().searchQuery;
    if (_controller.text != query) {
      _controller.text = query;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Consumer<AppState>(
      builder: (context, state, _) {
        // Sync controller when query is cleared externally (e.g. category change)
        if (state.searchQuery.isEmpty && _controller.text.isNotEmpty) {
          _controller.clear();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: SizedBox(
            height: 48,
            child: TextField(
              controller: _controller,
              onChanged: (value) => state.setSearchQuery(value),
              style: TextStyle(color: cs.onSurface, fontSize: 16),
              decoration: InputDecoration(
                hintText:
                    'Search ${state.selectedCategory[0].toUpperCase()}${state.selectedCategory.substring(1)}...',
                hintStyle: TextStyle(color: cs.outline, fontSize: 16),
                prefixIcon:
                    Icon(Icons.search, color: cs.onSurfaceVariant, size: 24),
                suffixIcon: state.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear,
                            color: cs.onSurfaceVariant, size: 24),
                        onPressed: () {
                          _controller.clear();
                          state.setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: cs.surfaceContainerHigh,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
