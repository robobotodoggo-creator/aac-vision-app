import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import 'manage_symbols_screen.dart';
import 'usage_stats_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyController = TextEditingController();

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            backgroundColor: cs.surfaceContainerHighest,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Theme toggle
              _buildSection(
                context,
                'Appearance',
                [
                  SwitchListTile(
                    title: Text('Dark Mode',
                        style:
                            TextStyle(color: cs.onSurface, fontSize: 18)),
                    subtitle: Text('Switch between dark and light theme',
                        style: TextStyle(color: cs.onSurfaceVariant)),
                    value: state.darkMode,
                    onChanged: (v) => state.setDarkMode(v),
                    secondary: Icon(
                      state.darkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: cs.primary,
                    ),
                  ),
                  SwitchListTile(
                    title: Text('Tap Sound Effects',
                        style:
                            TextStyle(color: cs.onSurface, fontSize: 18)),
                    subtitle: Text(
                        'Play a click sound when tapping symbols',
                        style: TextStyle(color: cs.onSurfaceVariant)),
                    value: state.soundEffects,
                    onChanged: (v) => state.setSoundEffects(v),
                    secondary: Icon(
                      state.soundEffects
                          ? Icons.volume_up
                          : Icons.volume_off,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Camera toggle
              _buildSection(
                context,
                'Camera',
                [
                  SwitchListTile(
                    title: Text('Enable Camera',
                        style:
                            TextStyle(color: cs.onSurface, fontSize: 18)),
                    subtitle: Text(
                        'Detect objects for context-aware suggestions',
                        style: TextStyle(color: cs.onSurfaceVariant)),
                    value: state.cameraEnabled,
                    onChanged: (v) => state.toggleCamera(v),
                  ),
                  if (state.visionError != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Text(
                        state.visionError!,
                        style: const TextStyle(
                            color: Colors.redAccent, fontSize: 16),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Cloud toggle
              _buildSection(
                context,
                'Cloud Suggestions',
                [
                  SwitchListTile(
                    title: Text('Smart Suggestions (uses internet)',
                        style:
                            TextStyle(color: cs.onSurface, fontSize: 18)),
                    subtitle: Text(
                        'Send context to Claude for richer suggestions',
                        style: TextStyle(color: cs.onSurfaceVariant)),
                    value: state.cloudEnabled,
                    onChanged: (v) => state.toggleCloud(v),
                  ),
                  if (state.cloudEnabled)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _apiKeyController,
                        style:
                            TextStyle(color: cs.onSurface, fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Anthropic API Key',
                          labelStyle:
                              TextStyle(color: cs.onSurfaceVariant),
                          hintText: 'sk-ant-...',
                          hintStyle: TextStyle(color: cs.outline),
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: cs.outlineVariant),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.save, color: cs.primary),
                            onPressed: () {
                              state.setApiKey(_apiKeyController.text);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('API key saved')),
                              );
                            },
                          ),
                        ),
                        obscureText: true,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Grid size
              _buildSection(
                context,
                'Grid Layout',
                [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text('Grid columns: ',
                            style: TextStyle(
                                color: cs.onSurface, fontSize: 18)),
                        const Spacer(),
                        for (final cols in [3, 4, 5])
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text('${cols}x$cols',
                                  style: const TextStyle(fontSize: 16)),
                              selected: state.gridColumns == cols,
                              selectedColor: cs.primary,
                              onSelected: (_) => state.setGridColumns(cols),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Manage Symbols
              _buildSection(
                context,
                'Symbols',
                [
                  ListTile(
                    title: Text('Manage Symbols',
                        style:
                            TextStyle(color: cs.onSurface, fontSize: 18)),
                    subtitle: Text('Add, reorder, show, or hide symbols',
                        style: TextStyle(color: cs.onSurfaceVariant)),
                    trailing: Icon(Icons.chevron_right,
                        color: cs.onSurfaceVariant, size: 28),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageSymbolsScreen(),
                        ),
                      );
                    },
                  ),
                  if (state.hiddenSymbolIds.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Text(
                        '${state.hiddenSymbolIds.length} symbol(s) hidden',
                        style:
                            TextStyle(color: cs.outline, fontSize: 16),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Usage Stats
              _buildSection(
                context,
                'Usage Stats',
                [
                  ListTile(
                    title: Text('View Usage Stats',
                        style:
                            TextStyle(color: cs.onSurface, fontSize: 18)),
                    subtitle: Text(
                        'Most-used symbols and daily activity for therapist reports',
                        style: TextStyle(color: cs.onSurfaceVariant)),
                    trailing: Icon(Icons.chevron_right,
                        color: cs.onSurfaceVariant, size: 28),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UsageStatsScreen(),
                        ),
                      );
                    },
                  ),
                  if (state.usageStats.totalTaps > 0)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Text(
                        '${state.usageStats.totalTaps} total taps tracked',
                        style:
                            TextStyle(color: cs.outline, fontSize: 16),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // TTS settings
              _buildSection(
                context,
                'Text-to-Speech',
                [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Speech Rate: ${state.speechRate.toStringAsFixed(2)}',
                            style: TextStyle(
                                color: cs.onSurface, fontSize: 18)),
                        Slider(
                          value: state.speechRate,
                          min: 0.1,
                          max: 1.0,
                          onChanged: (v) => state.setSpeechRate(v),
                        ),
                        Text(
                            'Pitch: ${state.pitch.toStringAsFixed(2)}',
                            style: TextStyle(
                                color: cs.onSurface, fontSize: 18)),
                        Slider(
                          value: state.pitch,
                          min: 0.5,
                          max: 2.0,
                          onChanged: (v) => state.setPitch(v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                color: cs.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
