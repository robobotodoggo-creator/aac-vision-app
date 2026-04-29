import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import 'manage_symbols_screen.dart';

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
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text('Settings'),
            backgroundColor: Colors.grey[900],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Camera toggle
              _buildSection(
                'Camera',
                [
                  SwitchListTile(
                    title: const Text('Enable Camera',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                    subtitle: const Text(
                        'Detect objects for context-aware suggestions',
                        style: TextStyle(color: Colors.white54)),
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
                'Cloud Suggestions',
                [
                  SwitchListTile(
                    title: const Text('Smart Suggestions (uses internet)',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                    subtitle: const Text(
                        'Send context to Claude for richer suggestions',
                        style: TextStyle(color: Colors.white54)),
                    value: state.cloudEnabled,
                    onChanged: (v) => state.toggleCloud(v),
                  ),
                  if (state.cloudEnabled)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _apiKeyController,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Anthropic API Key',
                          labelStyle: const TextStyle(color: Colors.white54),
                          hintText: 'sk-ant-...',
                          hintStyle: const TextStyle(color: Colors.white24),
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey[700]!),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.save, color: Colors.blue),
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
                'Grid Layout',
                [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Text('Grid columns: ',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        const Spacer(),
                        for (final cols in [3, 4, 5])
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text('${cols}x$cols',
                                  style: const TextStyle(fontSize: 16)),
                              selected: state.gridColumns == cols,
                              selectedColor: Colors.blue[700],
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
                'Symbols',
                [
                  ListTile(
                    title: const Text('Manage Symbols',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                    subtitle: const Text(
                        'Add, reorder, show, or hide symbols',
                        style: TextStyle(color: Colors.white54)),
                    trailing: const Icon(Icons.chevron_right,
                        color: Colors.white54, size: 28),
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
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 16),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // TTS settings
              _buildSection(
                'Text-to-Speech',
                [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Speech Rate: ${state.speechRate.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18)),
                        Slider(
                          value: state.speechRate,
                          min: 0.1,
                          max: 1.0,
                          onChanged: (v) => state.setSpeechRate(v),
                        ),
                        Text(
                            'Pitch: ${state.pitch.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18)),
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

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.blue,
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
