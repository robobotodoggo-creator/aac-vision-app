import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aac_vision_app/models/aac_symbol.dart';
import 'package:aac_vision_app/widgets/symbol_tile.dart';
import 'package:aac_vision_app/widgets/sentence_bar.dart';
import 'package:aac_vision_app/services/app_state.dart';

// Test symbols used across multiple test groups
const _testSymbol = AacSymbol(
  id: 'test_yes',
  label: 'Yes',
  speakText: 'yes',
  category: 'core',
  emoji: '✅',
);

const _testSymbol2 = AacSymbol(
  id: 'test_no',
  label: 'No',
  speakText: 'no',
  category: 'core',
  emoji: '❌',
);

const _testSymbol3 = AacSymbol(
  id: 'test_water',
  label: 'Water',
  speakText: 'water',
  category: 'food',
  emoji: '💧',
);

/// Wraps a widget with MaterialApp and Provider for testing.
Widget _testApp(AppState state, Widget child) {
  return ChangeNotifierProvider<AppState>.value(
    value: state,
    child: MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Mock the flutter_tts platform channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (MethodCall methodCall) async => null,
    );
  });

  setUp(() {
    // Mock SharedPreferences with empty values
    SharedPreferences.setMockInitialValues({});
  });

  group('AacSymbol model', () {
    test('fromJson creates correct symbol', () {
      final json = {
        'id': 'core_hello',
        'label': 'Hello',
        'speakText': 'hello',
        'category': 'core',
        'emoji': '👋',
      };
      final symbol = AacSymbol.fromJson(json);
      expect(symbol.id, 'core_hello');
      expect(symbol.label, 'Hello');
      expect(symbol.speakText, 'hello');
      expect(symbol.category, 'core');
      expect(symbol.emoji, '👋');
    });

    test('toJson roundtrip preserves data', () {
      final json = _testSymbol.toJson();
      final restored = AacSymbol.fromJson(json);
      expect(restored.id, _testSymbol.id);
      expect(restored.label, _testSymbol.label);
      expect(restored.speakText, _testSymbol.speakText);
      expect(restored.category, _testSymbol.category);
      expect(restored.emoji, _testSymbol.emoji);
    });
  });

  group('AppState sentence logic', () {
    late AppState state;

    setUp(() {
      state = AppState();
    });

    tearDown(() {
      state.dispose();
    });

    test('addToSentence appends symbol', () {
      state.addToSentence(_testSymbol);
      expect(state.sentenceSymbols.length, 1);
      expect(state.sentenceSymbols[0].id, 'test_yes');
    });

    test('addToSentence preserves order', () {
      state.addToSentence(_testSymbol);
      state.addToSentence(_testSymbol2);
      state.addToSentence(_testSymbol3);
      expect(state.sentenceSymbols.length, 3);
      expect(state.sentenceSymbols[0].label, 'Yes');
      expect(state.sentenceSymbols[1].label, 'No');
      expect(state.sentenceSymbols[2].label, 'Water');
    });

    test('removeLastFromSentence removes last symbol', () {
      state.addToSentence(_testSymbol);
      state.addToSentence(_testSymbol2);
      state.removeLastFromSentence();
      expect(state.sentenceSymbols.length, 1);
      expect(state.sentenceSymbols[0].id, 'test_yes');
    });

    test('removeFromSentenceAt removes correct index', () {
      state.addToSentence(_testSymbol);
      state.addToSentence(_testSymbol2);
      state.addToSentence(_testSymbol3);
      // Remove middle symbol (index 1 = "No")
      state.removeFromSentenceAt(1);
      expect(state.sentenceSymbols.length, 2);
      expect(state.sentenceSymbols[0].label, 'Yes');
      expect(state.sentenceSymbols[1].label, 'Water');
    });

    test('removeFromSentenceAt with invalid index does nothing', () {
      state.addToSentence(_testSymbol);
      state.removeFromSentenceAt(-1);
      state.removeFromSentenceAt(5);
      expect(state.sentenceSymbols.length, 1);
    });

    test('clearSentence removes all symbols', () {
      state.addToSentence(_testSymbol);
      state.addToSentence(_testSymbol2);
      state.clearSentence();
      expect(state.sentenceSymbols, isEmpty);
    });

    test('removeLastFromSentence on empty does nothing', () {
      state.removeLastFromSentence();
      expect(state.sentenceSymbols, isEmpty);
    });
  });

  group('AppState category and search', () {
    late AppState state;

    setUp(() {
      state = AppState();
    });

    tearDown(() {
      state.dispose();
    });

    test('default category is core', () {
      expect(state.selectedCategory, 'core');
    });

    test('selectCategory changes category', () {
      state.selectCategory('food');
      expect(state.selectedCategory, 'food');
    });

    test('selectCategory clears search query', () {
      state.setSearchQuery('test');
      expect(state.searchQuery, 'test');
      state.selectCategory('food');
      expect(state.searchQuery, '');
    });

    test('setSearchQuery updates query', () {
      state.setSearchQuery('hello');
      expect(state.searchQuery, 'hello');
    });
  });

  group('SymbolTile widget', () {
    testWidgets('renders emoji and label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SymbolTile(
              symbol: _testSymbol,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('✅'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
    });

    testWidgets('has minimum 60x60dp constraints', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SymbolTile(
                symbol: _testSymbol,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      // Find the Container with constraints
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints!.minHeight, greaterThanOrEqualTo(60));
      expect(container.constraints!.minWidth, greaterThanOrEqualTo(60));
    });

    testWidgets('tap triggers onTap callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SymbolTile(
              symbol: _testSymbol,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('long-press triggers onLongPress callback', (tester) async {
      var longPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SymbolTile(
              symbol: _testSymbol,
              onTap: () {},
              onLongPress: () => longPressed = true,
            ),
          ),
        ),
      );

      await tester.longPress(find.byType(InkWell));
      expect(longPressed, isTrue);
    });

    testWidgets('label font size is at least 16sp', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SymbolTile(
              symbol: _testSymbol,
              onTap: () {},
            ),
          ),
        ),
      );

      final labelText = tester.widget<Text>(find.text('Yes'));
      expect(labelText.style!.fontSize, greaterThanOrEqualTo(16));
    });
  });

  group('SentenceBar widget', () {
    testWidgets('shows placeholder when sentence is empty', (tester) async {
      final state = AppState();
      await tester.pumpWidget(_testApp(state, const SentenceBar()));

      expect(find.text('Long-press tiles to build a sentence'), findsOneWidget);
      state.dispose();
    });

    testWidgets('shows chips when sentence has symbols', (tester) async {
      final state = AppState();
      state.addToSentence(_testSymbol);
      state.addToSentence(_testSymbol2);
      await tester.pumpWidget(_testApp(state, const SentenceBar()));

      expect(find.text('✅ Yes'), findsOneWidget);
      expect(find.text('❌ No'), findsOneWidget);
      state.dispose();
    });

    testWidgets('shows Speak button when sentence is not empty',
        (tester) async {
      final state = AppState();
      state.addToSentence(_testSymbol);
      await tester.pumpWidget(_testApp(state, const SentenceBar()));

      expect(find.text('Speak'), findsOneWidget);
      state.dispose();
    });

    testWidgets('hides Speak button when sentence is empty', (tester) async {
      final state = AppState();
      await tester.pumpWidget(_testApp(state, const SentenceBar()));

      expect(find.text('Speak'), findsNothing);
      state.dispose();
    });

    testWidgets('chip delete removes correct symbol by index',
        (tester) async {
      final state = AppState();
      state.addToSentence(_testSymbol);
      state.addToSentence(_testSymbol2);
      state.addToSentence(_testSymbol3);
      await tester.pumpWidget(_testApp(state, const SentenceBar()));

      // Tap the delete icon on the first chip (Yes)
      final deleteIcons = find.byIcon(Icons.close);
      await tester.tap(deleteIcons.first);
      await tester.pumpAndSettle();

      // "Yes" should be removed, "No" and "Water" remain
      expect(state.sentenceSymbols.length, 2);
      expect(state.sentenceSymbols[0].label, 'No');
      expect(state.sentenceSymbols[1].label, 'Water');
      state.dispose();
    });

    testWidgets('clear button removes all symbols', (tester) async {
      final state = AppState();
      state.addToSentence(_testSymbol);
      state.addToSentence(_testSymbol2);
      await tester.pumpWidget(_testApp(state, const SentenceBar()));

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(state.sentenceSymbols, isEmpty);
      state.dispose();
    });

    testWidgets('placeholder text is at least 16sp', (tester) async {
      final state = AppState();
      await tester.pumpWidget(_testApp(state, const SentenceBar()));

      final placeholder =
          tester.widget<Text>(find.text('Long-press tiles to build a sentence'));
      expect(placeholder.style!.fontSize, greaterThanOrEqualTo(16));
      state.dispose();
    });
  });
}
