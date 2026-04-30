import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/app_state.dart';

class ManageSymbolsScreen extends StatefulWidget {
  const ManageSymbolsScreen({super.key});

  @override
  State<ManageSymbolsScreen> createState() => _ManageSymbolsScreenState();
}

class _ManageSymbolsScreenState extends State<ManageSymbolsScreen> {
  String _selectedCategory = 'core';

  void _showAddSymbolDialog(AppState state) {
    final labelController = TextEditingController();
    final speakController = TextEditingController();
    final emojiController = TextEditingController();
    String category = _selectedCategory;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: const Text('Add Symbol',
                  style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: emojiController,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 32),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: 'Emoji',
                        labelStyle:
                            const TextStyle(color: Colors.white54, fontSize: 16),
                        hintText: 'Tap to type emoji',
                        hintStyle:
                            const TextStyle(color: Colors.white24, fontSize: 16),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey[700]!),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: labelController,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 18),
                      decoration: InputDecoration(
                        labelText: 'Label',
                        labelStyle:
                            const TextStyle(color: Colors.white54, fontSize: 16),
                        hintText: 'e.g. Cookie',
                        hintStyle:
                            const TextStyle(color: Colors.white24, fontSize: 16),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey[700]!),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: speakController,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 18),
                      decoration: InputDecoration(
                        labelText: 'Speak Text (optional)',
                        labelStyle:
                            const TextStyle(color: Colors.white54, fontSize: 16),
                        hintText: 'Defaults to label',
                        hintStyle:
                            const TextStyle(color: Colors.white24, fontSize: 16),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey[700]!),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Category',
                        labelStyle:
                            const TextStyle(color: Colors.white54, fontSize: 16),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey[700]!),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: category,
                          dropdownColor: Colors.grey[800],
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                          isExpanded: true,
                          items: state.categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(
                                cat[0].toUpperCase() + cat.substring(1),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() => category = val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child:
                      const Text('Cancel', style: TextStyle(fontSize: 16)),
                ),
                TextButton(
                  onPressed: () {
                    final label = labelController.text.trim();
                    final emoji = emojiController.text.trim();
                    if (label.isEmpty || emoji.isEmpty) return;
                    final speakText = speakController.text.trim().isEmpty
                        ? label
                        : speakController.text.trim();
                    state.addCustomSymbol(
                      label: label,
                      speakText: speakText,
                      category: category,
                      emoji: emoji,
                    );
                    Navigator.pop(ctx);
                    setState(() => _selectedCategory = category);
                  },
                  child: const Text('Add',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _exportConfig(AppState state) async {
    try {
      final file = await state.exportSymbolConfig();
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)]),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _importConfig(AppState state) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) return;
      final path = result.files.single.path;
      if (path == null) return;
      final jsonStr = await File(path).readAsString();
      final error = await state.importSymbolConfig(jsonStr);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Config imported successfully'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }

  void _confirmDelete(AppState state, String symbolId, String label) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Delete Symbol?',
            style: TextStyle(color: Colors.white)),
        content: Text(
            'Remove "$label" permanently? This cannot be undone.',
            style: const TextStyle(color: Colors.white70, fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(fontSize: 16)),
          ),
          TextButton(
            onPressed: () {
              state.deleteCustomSymbol(symbolId);
              Navigator.pop(ctx);
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.redAccent, fontSize: 16)),
          ),
        ],
      ),
    );
  }

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
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: Colors.grey[850],
                onSelected: (value) {
                  switch (value) {
                    case 'export':
                      _exportConfig(state);
                    case 'import':
                      _importConfig(state);
                    case 'reset':
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: Colors.grey[900],
                          title: const Text('Reset All?',
                              style: TextStyle(color: Colors.white)),
                          content: const Text(
                              'This will restore default symbol order and make all symbols visible.',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 16)),
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
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        Icon(Icons.upload, color: Colors.white70, size: 22),
                        SizedBox(width: 12),
                        Text('Export Config',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'import',
                    child: Row(
                      children: [
                        Icon(Icons.download, color: Colors.white70, size: 22),
                        SizedBox(width: 12),
                        Text('Import Config',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'reset',
                    child: Row(
                      children: [
                        Icon(Icons.restore, color: Colors.redAccent, size: 22),
                        SizedBox(width: 12),
                        Text('Reset All',
                            style: TextStyle(
                                color: Colors.redAccent, fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddSymbolDialog(state),
            backgroundColor: Colors.blue[700],
            child: const Icon(Icons.add, size: 28),
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
                    final isCustom = state.isCustomSymbol(symbol.id);
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
                              if (isCustom)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.redAccent, size: 24),
                                  onPressed: () => _confirmDelete(
                                      state, symbol.id, symbol.label),
                                  constraints: const BoxConstraints(
                                      minHeight: 48, minWidth: 48),
                                ),
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
