import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../widgets/aac_grid.dart';
import '../widgets/suggestion_bar.dart';
import '../widgets/sentence_bar.dart';
import '../widgets/camera_preview.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    // Sentence builder bar
                    const SentenceBar(),

                    // Context-aware suggestions
                    const SuggestionBar(),

                    // Category tabs
                    SizedBox(
                      height: 48,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        children: [
                          ...state.categories.map((cat) {
                            final isSelected = cat == state.selectedCategory;
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: FilterChip(
                                label: Text(
                                  cat[0].toUpperCase() + cat.substring(1),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: Colors.blue[700],
                                backgroundColor: Colors.grey[800],
                                onSelected: (_) => state.selectCategory(cat),
                              ),
                            );
                          }),
                          // Settings button at end of category row
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ActionChip(
                              avatar: const Icon(Icons.settings,
                                  color: Colors.white70, size: 18),
                              label: const Text('Settings',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 16)),
                              backgroundColor: Colors.grey[800],
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SettingsScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Main AAC grid
                    const Expanded(child: AacGrid()),
                  ],
                ),

                // Camera PiP overlay
                const CameraPreviewWidget(),
              ],
            ),
          ),
        );
      },
    );
  }
}
