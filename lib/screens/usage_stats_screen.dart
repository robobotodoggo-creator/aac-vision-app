import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/app_state.dart';

class UsageStatsScreen extends StatelessWidget {
  const UsageStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final stats = state.usageStats;
        final topSymbols = stats.topSymbols(limit: 20);
        final recentDays = stats.recentDays(limit: 30);

        // Build label/emoji lookup from allSymbols
        final labelMap = <String, String>{};
        final emojiMap = <String, String>{};
        for (final s in state.allSymbols) {
          labelMap[s.id] = s.label;
          emojiMap[s.id] = s.emoji;
        }

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text('Usage Stats'),
            backgroundColor: Colors.grey[900],
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  if (value == 'export') {
                    final file =
                        await stats.exportReport(labelMap, emojiMap);
                    await SharePlus.instance.share(
                      ShareParams(files: [XFile(file.path)]),
                    );
                  } else if (value == 'clear') {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Clear Usage Data'),
                        content: const Text(
                            'This will permanently delete all usage statistics. This cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Clear',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await stats.clearStats();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Usage data cleared')),
                        );
                        // Force rebuild
                        (context as Element).markNeedsBuild();
                      }
                    }
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'export',
                    child: ListTile(
                      leading: Icon(Icons.share),
                      title: Text('Export Report'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'clear',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, color: Colors.red),
                      title:
                          Text('Clear Data', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: stats.totalTaps == 0
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No usage data yet.\nStart tapping symbols and your stats will appear here.',
                      style: TextStyle(color: Colors.white54, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Summary cards
                    _buildSummaryRow(stats.totalTaps,
                        stats.uniqueSymbolsUsed, stats.daysTracked),
                    const SizedBox(height: 20),

                    // Most used symbols
                    _buildSectionHeader('Most Used Symbols'),
                    const SizedBox(height: 8),
                    ...topSymbols.map((entry) {
                      final label = labelMap[entry.key] ?? entry.key;
                      final emoji = emojiMap[entry.key] ?? '';
                      final pct = stats.totalTaps > 0
                          ? (entry.value / stats.totalTaps * 100)
                          : 0.0;
                      return _buildSymbolRow(
                          emoji, label, entry.value, pct);
                    }),
                    const SizedBox(height: 20),

                    // Daily activity
                    _buildSectionHeader('Daily Activity'),
                    const SizedBox(height: 8),
                    ...recentDays.map((entry) {
                      return _buildDayRow(entry.key, entry.value);
                    }),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildSummaryRow(int totalTaps, int uniqueSymbols, int daysTracked) {
    return Row(
      children: [
        Expanded(child: _buildSummaryCard('Total Taps', '$totalTaps', Icons.touch_app)),
        const SizedBox(width: 8),
        Expanded(child: _buildSummaryCard('Symbols Used', '$uniqueSymbols', Icons.grid_view)),
        const SizedBox(width: 8),
        Expanded(child: _buildSummaryCard('Days Active', '$daysTracked', Icons.calendar_today)),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.blue,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSymbolRow(String emoji, String label, int count, double pct) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 48,
            child: Text(
              '${pct.toStringAsFixed(0)}%',
              style: const TextStyle(color: Colors.white38, fontSize: 16),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayRow(String date, int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Colors.white38, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              date,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          Text(
            '$count taps',
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
