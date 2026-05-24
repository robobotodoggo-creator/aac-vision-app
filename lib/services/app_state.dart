import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/aac_symbol.dart';
import 'tts_service.dart';
import 'vision_service.dart';
import 'context_service.dart';
import 'cloud_service.dart';
import 'sound_service.dart';
import 'usage_stats_service.dart';

class AppState extends ChangeNotifier {
  final TtsService tts = TtsService();
  final VisionService vision = VisionService();
  final ContextService context = ContextService();
  final CloudService cloud = CloudService();
  final UsageStatsService usageStats = UsageStatsService();
  final SoundService sound = SoundService();

  // Suggestion display tuning: predictability matters more than freshness for
  // aphasia users. Suggestions stick for [_stickyTtl] after last seen so they
  // can be tapped, are sorted alphabetically for stable position, and capped
  // so the bar never overflows.
  static const Duration _stickyTtl = Duration(seconds: 5);
  static const int _maxVisibleSuggestions = 6;
  final Map<String, DateTime> _suggestionLastSeen = {};
  bool _suggestionsFrozen = false;

  List<AacSymbol> _allSymbols = [];
  List<AacSymbol> _suggestedSymbols = [];
  final List<AacSymbol> _sentenceSymbols = [];
  List<String> _recentPhrases = [];
  List<AacSymbol> _customSymbols = [];
  Set<String> _hiddenSymbolIds = {};
  Map<String, List<String>> _symbolOrder = {};
  String _selectedCategory = 'core';
  String _searchQuery = '';
  bool _cameraEnabled = false;
  bool _cloudEnabled = false;
  int _gridColumns = 4;
  double _speechRate = 0.45;
  double _pitch = 1.0;
  bool _darkMode = true;
  bool _soundEffects = false;
  bool _onboardingComplete = false;
  bool _initialized = false;
  String? _visionError;
  bool _disposed = false;
  StreamSubscription<List<String>>? _detectedObjectsSub;
  StreamSubscription<String>? _visionErrorSub;

  bool get initialized => _initialized;
  List<AacSymbol> get allSymbols => _allSymbols;
  List<AacSymbol> get suggestedSymbols => _suggestedSymbols;
  List<AacSymbol> get sentenceSymbols => _sentenceSymbols;
  List<String> get recentPhrases => _recentPhrases;
  Set<String> get hiddenSymbolIds => _hiddenSymbolIds;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get cameraEnabled => _cameraEnabled;
  bool get suggestionsFrozen => _suggestionsFrozen;

  void toggleSuggestionsFrozen() {
    _suggestionsFrozen = !_suggestionsFrozen;
    notifyListeners();
  }
  bool get cloudEnabled => _cloudEnabled;
  int get gridColumns => _gridColumns;
  double get speechRate => _speechRate;
  double get pitch => _pitch;
  bool get darkMode => _darkMode;
  bool get soundEffects => _soundEffects;
  bool get onboardingComplete => _onboardingComplete;
  String? get visionError => _visionError;

  List<String> get categories {
    final cats = _allSymbols.map((s) => s.category).toSet().toList();
    cats.sort();
    return cats;
  }

  List<AacSymbol> get filteredSymbols {
    var symbols = _allSymbols
        .where((s) => s.category == _selectedCategory)
        .where((s) => !_hiddenSymbolIds.contains(s.id));
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      symbols = symbols.where((s) => s.label.toLowerCase().contains(query));
    }
    final result = symbols.toList();
    final order = _symbolOrder[_selectedCategory];
    if (order != null) {
      result.sort((a, b) {
        final ai = order.indexOf(a.id);
        final bi = order.indexOf(b.id);
        if (ai == -1 && bi == -1) return 0;
        if (ai == -1) return 1;
        if (bi == -1) return 1;
        return ai.compareTo(bi);
      });
    }
    return result;
  }

  /// Returns all symbols for a category, including hidden ones, in custom order.
  List<AacSymbol> symbolsForCategory(String category) {
    final symbols =
        _allSymbols.where((s) => s.category == category).toList();
    final order = _symbolOrder[category];
    if (order != null) {
      symbols.sort((a, b) {
        final ai = order.indexOf(a.id);
        final bi = order.indexOf(b.id);
        if (ai == -1 && bi == -1) return 0;
        if (ai == -1) return 1;
        if (bi == -1) return 1;
        return ai.compareTo(bi);
      });
    }
    return symbols;
  }

  Future<void> init() async {
    // Load preferences first so we can pass persisted TTS values to init
    final prefs = await SharedPreferences.getInstance();
    final savedRate = prefs.getDouble('speechRate') ?? 0.45;
    final savedPitch = prefs.getDouble('pitch') ?? 1.0;

    // Run symbol loading, context init, TTS init, usage stats, and sound in parallel
    await Future.wait([
      _loadSymbols(),
      context.init(),
      tts.init(rate: savedRate, pitch: savedPitch),
      usageStats.init(),
      sound.init(),
    ]);

    await _loadPreferences();

    _detectedObjectsSub = vision.detectedObjects.listen(_onObjectsDetected);
    _visionErrorSub = vision.errors.listen(_onVisionError);

    _initialized = true;
    notifyListeners();
  }

  void _onVisionError(String error) {
    _visionError = error;
    _cameraEnabled = false;
    notifyListeners();
  }

  Future<void> _loadSymbols() async {
    final jsonStr =
        await rootBundle.loadString('assets/data/default_symbols.json');
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    final list = data['symbols'] as List;
    _allSymbols =
        list.map((s) => AacSymbol.fromJson(s as Map<String, dynamic>)).toList();
    await _loadCustomSymbols();
    notifyListeners();
  }

  Future<void> _loadCustomSymbols() async {
    final prefs = await SharedPreferences.getInstance();
    final customJson = prefs.getString('customSymbols');
    if (customJson != null) {
      try {
        final list = json.decode(customJson) as List;
        _customSymbols = list
            .map((s) => AacSymbol.fromJson(s as Map<String, dynamic>))
            .toList();
        _allSymbols.addAll(_customSymbols);
      } catch (_) {
        _customSymbols = [];
      }
    }
  }

  Future<void> _saveCustomSymbols() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded =
        json.encode(_customSymbols.map((s) => s.toJson()).toList());
    await prefs.setString('customSymbols', encoded);
  }

  bool isCustomSymbol(String id) => id.startsWith('custom_');

  Future<void> addCustomSymbol({
    required String label,
    required String speakText,
    required String category,
    required String emoji,
  }) async {
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final symbol = AacSymbol(
      id: id,
      label: label,
      speakText: speakText,
      category: category,
      emoji: emoji,
    );
    _customSymbols.add(symbol);
    _allSymbols.add(symbol);
    await _saveCustomSymbols();
    notifyListeners();
  }

  Future<void> deleteCustomSymbol(String id) async {
    _customSymbols.removeWhere((s) => s.id == id);
    _allSymbols.removeWhere((s) => s.id == id);
    _hiddenSymbolIds.remove(id);
    // Clean up from custom order maps
    for (final order in _symbolOrder.values) {
      order.remove(id);
    }
    await _saveCustomSymbols();
    await _saveSymbolCustomizations();
    notifyListeners();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _cameraEnabled = prefs.getBool('cameraEnabled') ?? false;
    _cloudEnabled = prefs.getBool('cloudEnabled') ?? false;
    _gridColumns = prefs.getInt('gridColumns') ?? 4;
    _recentPhrases = prefs.getStringList('recentPhrases') ?? [];
    _speechRate = prefs.getDouble('speechRate') ?? 0.45;
    _pitch = prefs.getDouble('pitch') ?? 1.0;
    _darkMode = prefs.getBool('darkMode') ?? true;
    _soundEffects = prefs.getBool('soundEffects') ?? false;
    _onboardingComplete = prefs.getBool('onboardingComplete') ?? false;
    // TTS rate/pitch already set during init() — no redundant calls needed
    _hiddenSymbolIds =
        (prefs.getStringList('hiddenSymbolIds') ?? []).toSet();
    final orderStr = prefs.getString('symbolOrder');
    if (orderStr != null) {
      try {
        final decoded = json.decode(orderStr) as Map<String, dynamic>;
        _symbolOrder = decoded.map(
            (k, v) => MapEntry(k, (v as List).cast<String>()));
      } catch (_) {
        _symbolOrder = {};
      }
    }
    final apiKey = prefs.getString('apiKey');
    if (apiKey != null) cloud.setApiKey(apiKey);
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    _searchQuery = '';
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void addToSentence(AacSymbol symbol) {
    if (_soundEffects) sound.playTap();
    _sentenceSymbols.add(symbol);
    usageStats.recordTap(symbol.id);
    notifyListeners();
  }

  void removeLastFromSentence() {
    if (_sentenceSymbols.isNotEmpty) {
      _sentenceSymbols.removeLast();
      notifyListeners();
    }
  }

  void removeFromSentenceAt(int index) {
    if (index >= 0 && index < _sentenceSymbols.length) {
      _sentenceSymbols.removeAt(index);
      notifyListeners();
    }
  }

  void clearSentence() {
    _sentenceSymbols.clear();
    notifyListeners();
  }

  Future<void> speakSymbol(AacSymbol symbol) async {
    if (_soundEffects) sound.playTap();
    await tts.speak(symbol.speakText);
    _addRecentPhrase(symbol.speakText);
    usageStats.recordTap(symbol.id);
  }

  Future<void> speakSentence() async {
    if (_sentenceSymbols.isEmpty) return;
    final text = _sentenceSymbols.map((s) => s.speakText).join(' ');
    await tts.speak(text);
    _addRecentPhrase(text);
    clearSentence();
  }

  Future<void> speakPhrase(String phrase) async {
    await tts.speak(phrase);
  }

  void _addRecentPhrase(String phrase) {
    _recentPhrases.remove(phrase);
    _recentPhrases.insert(0, phrase);
    if (_recentPhrases.length > 10) {
      _recentPhrases = _recentPhrases.sublist(0, 10);
    }
    _saveRecentPhrases();
    notifyListeners();
  }

  Future<void> _saveRecentPhrases() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recentPhrases', _recentPhrases);
  }

  Future<void> toggleCamera(bool enabled) async {
    _visionError = null;
    final prefs = await SharedPreferences.getInstance();
    if (enabled) {
      final success = await vision.init();
      if (success) {
        _cameraEnabled = true;
        await prefs.setBool('cameraEnabled', true);
        vision.startDetection();
      } else {
        _cameraEnabled = false;
        await prefs.setBool('cameraEnabled', false);
      }
    } else {
      _cameraEnabled = false;
      await prefs.setBool('cameraEnabled', false);
      vision.stopDetection();
      _suggestedSymbols.clear();
    }
    notifyListeners();
  }

  Future<void> toggleCloud(bool enabled) async {
    _cloudEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('cloudEnabled', enabled);
    notifyListeners();
  }

  Future<void> setApiKey(String key) async {
    cloud.setApiKey(key);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiKey', key);
  }

  Future<void> setGridColumns(int columns) async {
    _gridColumns = columns;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('gridColumns', columns);
    notifyListeners();
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    await tts.setSpeechRate(rate);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('speechRate', rate);
    notifyListeners();
  }

  Future<void> setPitch(double pitch) async {
    _pitch = pitch;
    await tts.setPitch(pitch);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('pitch', pitch);
    notifyListeners();
  }

  Future<void> setDarkMode(bool dark) async {
    _darkMode = dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', dark);
    notifyListeners();
  }

  Future<void> setSoundEffects(bool enabled) async {
    _soundEffects = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEffects', enabled);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _onboardingComplete = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);
    notifyListeners();
  }

  bool isSymbolHidden(String id) => _hiddenSymbolIds.contains(id);

  Future<void> toggleSymbolVisibility(String id) async {
    if (_hiddenSymbolIds.contains(id)) {
      _hiddenSymbolIds.remove(id);
    } else {
      _hiddenSymbolIds.add(id);
    }
    await _saveSymbolCustomizations();
    notifyListeners();
  }

  Future<void> reorderSymbol(
      String category, int oldIndex, int newIndex) async {
    final symbols = symbolsForCategory(category);
    final ids = symbols.map((s) => s.id).toList();
    if (newIndex > oldIndex) newIndex--;
    final id = ids.removeAt(oldIndex);
    ids.insert(newIndex, id);
    _symbolOrder[category] = ids;
    await _saveSymbolCustomizations();
    notifyListeners();
  }

  Future<void> resetSymbolCustomizations() async {
    _hiddenSymbolIds.clear();
    _symbolOrder.clear();
    await _saveSymbolCustomizations();
    notifyListeners();
  }

  Future<void> _saveSymbolCustomizations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'hiddenSymbolIds', _hiddenSymbolIds.toList());
    final orderJson = json.encode(_symbolOrder);
    await prefs.setString('symbolOrder', orderJson);
  }

  /// Exports custom symbols, hidden IDs, and symbol order to a JSON file.
  /// Returns the file path for sharing.
  Future<File> exportSymbolConfig() async {
    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'customSymbols': _customSymbols.map((s) => s.toJson()).toList(),
      'hiddenSymbolIds': _hiddenSymbolIds.toList(),
      'symbolOrder': _symbolOrder,
    };
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/aac_symbols_config.json');
    await file.writeAsString(jsonStr);
    return file;
  }

  /// Imports symbol config from a JSON string. Replaces current customizations.
  Future<String?> importSymbolConfig(String jsonStr) async {
    try {
      final data = json.decode(jsonStr) as Map<String, dynamic>;

      // Load custom symbols
      if (data['customSymbols'] != null) {
        // Remove existing custom symbols from _allSymbols
        _allSymbols.removeWhere((s) => s.id.startsWith('custom_'));
        final list = data['customSymbols'] as List;
        _customSymbols = list
            .map((s) => AacSymbol.fromJson(s as Map<String, dynamic>))
            .toList();
        _allSymbols.addAll(_customSymbols);
        await _saveCustomSymbols();
      }

      // Load hidden symbol IDs
      if (data['hiddenSymbolIds'] != null) {
        _hiddenSymbolIds =
            (data['hiddenSymbolIds'] as List).cast<String>().toSet();
      }

      // Load symbol order
      if (data['symbolOrder'] != null) {
        final decoded = data['symbolOrder'] as Map<String, dynamic>;
        _symbolOrder =
            decoded.map((k, v) => MapEntry(k, (v as List).cast<String>()));
      }

      await _saveSymbolCustomizations();
      notifyListeners();
      return null; // success
    } catch (e) {
      return 'Invalid config file: $e';
    }
  }

  void _onObjectsDetected(List<String> objects) {
    if (_suggestionsFrozen) return;

    final now = DateTime.now();
    final suggestionIds = context.getSuggestions(objects);

    // Refresh "last seen" timestamps for currently detected suggestions.
    for (final id in suggestionIds) {
      _suggestionLastSeen[id] = now;
    }

    _rebuildVisibleSuggestions(now);

    if (_cloudEnabled && cloud.isConfigured) {
      cloud
          .getSuggestions(
            detectedObjects: objects,
            recentPhrases: _recentPhrases,
          )
          .then((cloudSuggestions) {
        if (_disposed || cloudSuggestions == null || _suggestionsFrozen) return;
        for (final text in cloudSuggestions) {
          final fakeId = 'cloud_${text.hashCode}';
          _suggestionLastSeen[fakeId] = DateTime.now();
          if (!_suggestedSymbols.any((s) => s.id == fakeId)) {
            _allSymbols.add(AacSymbol(
              id: fakeId,
              label: text,
              speakText: text,
              category: 'cloud',
              emoji: '🤖',
            ));
          }
        }
        _rebuildVisibleSuggestions(DateTime.now());
      }).catchError((_) {
        // Cloud is optional — fall back to on-device suggestions silently
      });
    }
  }

  /// Rebuilds [_suggestedSymbols] from "last seen" timestamps:
  ///   - drops anything older than [_stickyTtl] (sticky display so users can tap)
  ///   - sorts alphabetically by label (stable position across frames)
  ///   - caps at [_maxVisibleSuggestions] (oldest first to drop)
  void _rebuildVisibleSuggestions(DateTime now) {
    // Prune stale entries
    _suggestionLastSeen.removeWhere(
        (_, seenAt) => now.difference(seenAt) > _stickyTtl);

    // Resolve IDs → symbols
    final alive = _suggestionLastSeen.keys
        .map((id) => _allSymbols.firstWhere((s) => s.id == id,
            orElse: () => AacSymbol(
                id: id, label: id, speakText: id, category: '', emoji: '')))
        .where((s) => s.label.isNotEmpty)
        .toList();

    // If too many, keep the most-recently-seen
    if (alive.length > _maxVisibleSuggestions) {
      alive.sort((a, b) => _suggestionLastSeen[b.id]!
          .compareTo(_suggestionLastSeen[a.id]!));
      alive.removeRange(_maxVisibleSuggestions, alive.length);
    }

    // Final display sort: alphabetical = stable position
    alive.sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));

    _suggestedSymbols = alive;
    notifyListeners();
  }

  Future<void> clearUsageStats() async {
    await usageStats.clearStats();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _detectedObjectsSub?.cancel();
    _visionErrorSub?.cancel();
    tts.dispose();
    vision.dispose();
    sound.dispose();
    super.dispose();
  }
}
