import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../widgets/aac_grid.dart';
import '../widgets/suggestion_bar.dart';
import '../widgets/sentence_bar.dart';
import '../widgets/camera_preview.dart';
import '../widgets/recent_phrases_bar.dart';
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
            child: OrientationBuilder(
              builder: (context, orientation) {
                final isLandscape = orientation == Orientation.landscape;
                return Stack(
                  children: [
                    if (isLandscape)
                      _buildLandscapeLayout(context, state)
                    else
                      _buildPortraitLayout(context, state),
                    const CameraPreviewWidget(),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPortraitLayout(BuildContext context, AppState state) {
    return Column(
      children: [
        const SentenceBar(),
        const SuggestionBar(),
        const RecentPhrasesBar(),
        _buildHorizontalCategoryTabs(state, context),
        const Expanded(child: AacGrid()),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, AppState state) {
    return Row(
      children: [
        // Vertical category sidebar
        _buildCategorySidebar(state, context),
        // Main content area
        Expanded(
          child: Column(
            children: [
              const SentenceBar(),
              const SuggestionBar(),
              const RecentPhrasesBar(),
              const Expanded(child: AacGrid()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySidebar(AppState state, BuildContext context) {
    return Container(
      width: 100,
      color: Colors.grey[900],
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: state.categories.map((cat) {
                final isSelected = cat == state.selectedCategory;
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  child: Material(
                    color: isSelected ? Colors.blue[700] : Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => state.selectCategory(cat),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 60),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 12),
                        child: Text(
                          cat[0].toUpperCase() + cat.substring(1),
                          style: TextStyle(
                            color:
                                isSelected ? Colors.white : Colors.white70,
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Settings button at bottom of sidebar
          Padding(
            padding: const EdgeInsets.all(6),
            child: Material(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                },
                child: Container(
                  constraints: const BoxConstraints(minHeight: 60),
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.settings, color: Colors.white70, size: 24),
                      SizedBox(height: 4),
                      Text(
                        'Settings',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCategoryTabs(AppState state, BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          ...state.categories.map((cat) {
            final isSelected = cat == state.selectedCategory;
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
                onSelected: (_) => state.selectCategory(cat),
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ActionChip(
              avatar: const Icon(Icons.settings,
                  color: Colors.white70, size: 18),
              label: const Text('Settings',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
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
    );
  }
}
