import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/aac_symbol.dart';
import 'tts_service.dart';
import 'vision_service.dart';
import 'context_service.dart';
import 'cloud_service.dart';

class AppState extends ChangeNotifier {
  final TtsService tts = TtsService();
  final VisionService vision = VisionService();
  final ContextService context = ContextService();
  final CloudService cloud = CloudService();

  List<AacSymbol> _allSymbols = [];
  List<AacSymbol> _suggestedSymbols = [];
  final List<AacSymbol> _sentenceSymbols = [];
  List<String> _recentPhrases = [];
  String _selectedCategory = 'core';
  String _searchQuery = '';
  bool _cameraEnabled = false;
  bool _cloudEnabled = false;
  int _gridColumns = 4;
  String? _visionError;

  List<AacSymbol> get allSymbols => _allSymbols;
  List<AacSymbol> get suggestedSymbols => _suggestedSymbols;
  List<AacSymbol> get sentenceSymbols => _sentenceSymbols;
  List<String> get recentPhrases => _recentPhrases;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get cameraEnabled => _cameraEnabled;
  bool get cloudEnabled => _cloudEnabled;
  int get gridColumns => _gridColumns;
  String? get visionError => _visionError;

  List<String> get categories {
    final cats = _allSymbols.map((s) => s.category).toSet().toList();
    cats.sort();
    return cats;
  }

  List<AacSymbol> get filteredSymbols {
    var symbols = _allSymbols.where((s) => s.category == _selectedCategory);
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      symbols = symbols.where((s) => s.label.toLowerCase().contains(query));
    }
    return symbols.toList();
  }

  Future<void> init() async {
    await _loadSymbols();
    await context.init();
    await tts.init();
    await _loadPreferences();

    vision.detectedObjects.listen(_onObjectsDetected);
    vision.errors.listen(_onVisionError);
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
    notifyListeners();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _cameraEnabled = prefs.getBool('cameraEnabled') ?? false;
    _cloudEnabled = prefs.getBool('cloudEnabled') ?? false;
    _gridColumns = prefs.getInt('gridColumns') ?? 4;
    _recentPhrases = prefs.getStringList('recentPhrases') ?? [];
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
    _sentenceSymbols.add(symbol);
    notifyListeners();
  }

  void removeLastFromSentence() {
    if (_sentenceSymbols.isNotEmpty) {
      _sentenceSymbols.removeLast();
      notifyListeners();
    }
  }

  void clearSentence() {
    _sentenceSymbols.clear();
    notifyListeners();
  }

  Future<void> speakSymbol(AacSymbol symbol) async {
    await tts.speak(symbol.speakText);
    _addRecentPhrase(symbol.speakText);
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

  void _onObjectsDetected(List<String> objects) {
    final suggestionIds = context.getSuggestions(objects);
    _suggestedSymbols = _allSymbols
        .where((s) => suggestionIds.contains(s.id))
        .toList();

    if (_cloudEnabled && cloud.isConfigured) {
      cloud
          .getSuggestions(
            detectedObjects: objects,
            recentPhrases: _recentPhrases,
          )
          .then((cloudSuggestions) {
        if (cloudSuggestions != null) {
          // Cloud suggestions are raw text — show as temporary symbols
          for (final text in cloudSuggestions) {
            if (!_suggestedSymbols.any((s) => s.speakText == text)) {
              _suggestedSymbols.add(AacSymbol(
                id: 'cloud_${text.hashCode}',
                label: text,
                speakText: text,
                category: 'cloud',
                emoji: '🤖',
              ));
            }
          }
          notifyListeners();
        }
      });
    }

    notifyListeners();
  }

  @override
  void dispose() {
    tts.dispose();
    vision.dispose();
    super.dispose();
  }
}
