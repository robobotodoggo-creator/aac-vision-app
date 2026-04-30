import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks local-only symbol usage statistics for therapist reports.
/// All data stays on-device in SharedPreferences.
class UsageStatsService {
  // symbolId -> total tap count
  Map<String, int> _symbolCounts = {};
  // 'YYYY-MM-DD' -> total taps that day
  Map<String, int> _dailyCounts = {};

  Map<String, int> get symbolCounts => Map.unmodifiable(_symbolCounts);
  Map<String, int> get dailyCounts => Map.unmodifiable(_dailyCounts);

  int get totalTaps =>
      _symbolCounts.values.fold(0, (sum, count) => sum + count);
  int get uniqueSymbolsUsed =>
      _symbolCounts.values.where((c) => c > 0).length;
  int get daysTracked => _dailyCounts.length;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final symbolJson = prefs.getString('usageSymbolCounts');
    if (symbolJson != null) {
      final decoded = json.decode(symbolJson) as Map<String, dynamic>;
      _symbolCounts = decoded.map((k, v) => MapEntry(k, v as int));
    }
    final dailyJson = prefs.getString('usageDailyCounts');
    if (dailyJson != null) {
      final decoded = json.decode(dailyJson) as Map<String, dynamic>;
      _dailyCounts = decoded.map((k, v) => MapEntry(k, v as int));
    }
  }

  Future<void> recordTap(String symbolId) async {
    _symbolCounts[symbolId] = (_symbolCounts[symbolId] ?? 0) + 1;

    final today = _todayKey();
    _dailyCounts[today] = (_dailyCounts[today] ?? 0) + 1;

    await _save();
  }

  /// Returns symbol IDs sorted by tap count, descending.
  List<MapEntry<String, int>> topSymbols({int limit = 20}) {
    final sorted = _symbolCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).toList();
  }

  /// Returns daily counts sorted by date, most recent first.
  List<MapEntry<String, int>> recentDays({int limit = 30}) {
    final sorted = _dailyCounts.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    return sorted.take(limit).toList();
  }

  /// Generates a plain-text report for therapist sharing.
  Future<File> exportReport(
      Map<String, String> symbolLabels, Map<String, String> symbolEmojis) async {
    final buf = StringBuffer();
    buf.writeln('AAC Usage Report');
    buf.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buf.writeln('');
    buf.writeln('=== Summary ===');
    buf.writeln('Total taps: $totalTaps');
    buf.writeln('Unique symbols used: $uniqueSymbolsUsed');
    buf.writeln('Days tracked: $daysTracked');
    buf.writeln('');

    buf.writeln('=== Most Used Symbols ===');
    final top = topSymbols(limit: 50);
    for (final entry in top) {
      final label = symbolLabels[entry.key] ?? entry.key;
      final emoji = symbolEmojis[entry.key] ?? '';
      buf.writeln('$emoji $label: ${entry.value} taps');
    }
    buf.writeln('');

    buf.writeln('=== Daily Activity ===');
    final days = recentDays(limit: 90);
    for (final entry in days) {
      buf.writeln('${entry.key}: ${entry.value} taps');
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/aac_usage_report.txt');
    await file.writeAsString(buf.toString());
    return file;
  }

  Future<void> clearStats() async {
    _symbolCounts.clear();
    _dailyCounts.clear();
    await _save();
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('usageSymbolCounts', json.encode(_symbolCounts));
    await prefs.setString('usageDailyCounts', json.encode(_dailyCounts));
  }
}
