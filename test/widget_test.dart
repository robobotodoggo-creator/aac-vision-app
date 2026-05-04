import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aac_vision_app/models/aac_symbol.dart';
import 'package:aac_vision_app/widgets/symbol_tile.dart';
import 'package:aac_vision_app/widgets/sentence_bar.dart';
import 'package:aac_vision_app/widgets/suggestion_bar.dart';
import 'package:aac_vision_app/widgets/onboarding_overlay.dart';
import 'package:aac_vision_app/widgets/aac_grid.dart';
import 'package:aac_vision_app/widgets/symbol_search_bar.dart';
import 'package:aac_vision_app/widgets/recent_phrases_bar.dart';
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

  group('SuggestionBar widget', () {
    testWidgets('renders nothing when no suggestions', (tester) async {
      final state = AppState();
      await tester.pumpWidget(_testApp(state, const SuggestionBar()));

      // SuggestionBar returns SizedBox.shrink when suggestedSymbols is empty
      expect(find.byType(SizedBox), findsWidgets);
      expect(find.text('Suggested'), findsNothing);
      state.dispose();
    });
  });

  group('OnboardingOverlay widget', () {
    testWidgets('shows first step on initial render', (tester) async {
      var completed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingOverlay(onComplete: () => completed = true),
          ),
        ),
      );

      expect(find.text('Welcome to AAC Vision'), findsOneWidget);
      expect(
          find.text(
              'This app helps you communicate by tapping picture symbols that speak out loud.'),
          findsOneWidget);
      expect(completed, isFalse);
    });

    testWidgets('Next button advances to second step', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingOverlay(onComplete: () {}),
          ),
        ),
      );

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Tap to Speak'), findsOneWidget);
      expect(find.text('Welcome to AAC Vision'), findsNothing);
    });

    testWidgets('Skip button calls onComplete', (tester) async {
      var completed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingOverlay(onComplete: () => completed = true),
          ),
        ),
      );

      await tester.tap(find.text('Skip'));
      expect(completed, isTrue);
    });

    testWidgets('shows Get Started on last step', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingOverlay(onComplete: () {}),
          ),
        ),
      );

      // Advance through all 5 steps (tap Next 4 times to reach the last)
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }

      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Customize in Settings'), findsOneWidget);
      // Skip button should be hidden on last step
      expect(find.text('Skip'), findsNothing);
    });

    testWidgets('Get Started calls onComplete', (tester) async {
      var completed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingOverlay(onComplete: () => completed = true),
          ),
        ),
      );

      // Advance to last step
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text('Get Started'));
      expect(completed, isTrue);
    });

    testWidgets('shows 5 progress dots', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingOverlay(onComplete: () {}),
          ),
        ),
      );

      expect(find.byType(CircleAvatar), findsNWidgets(5));
    });

    testWidgets('title font size meets 16sp minimum', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingOverlay(onComplete: () {}),
          ),
        ),
      );

      final title = tester.widget<Text>(find.text('Welcome to AAC Vision'));
      expect(title.style!.fontSize, greaterThanOrEqualTo(16));
    });

    testWidgets('description font size meets 16sp minimum', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingOverlay(onComplete: () {}),
          ),
        ),
      );

      final desc = tester.widget<Text>(find.text(
          'This app helps you communicate by tapping picture symbols that speak out loud.'));
      expect(desc.style!.fontSize, greaterThanOrEqualTo(16));
    });

    testWidgets('buttons are 60dp height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingOverlay(onComplete: () {}),
          ),
        ),
      );

      // Both Skip and Next buttons are wrapped in SizedBox(height: 60)
      final sizedBoxes = tester
          .widgetList<SizedBox>(find.byType(SizedBox))
          .where((sb) => sb.height == 60);
      expect(sizedBoxes.length, greaterThanOrEqualTo(2));
    });
  });

  group('AacGrid widget', () {
    testWidgets('renders GridView', (tester) async {
      final state = AppState();
      await tester.pumpWidget(_testApp(state, const AacGrid()));

      expect(find.byType(GridView), findsOneWidget);
      state.dispose();
    });

    testWidgets('shows no tiles when no symbols loaded', (tester) async {
      final state = AppState();
      await tester.pumpWidget(_testApp(state, const AacGrid()));

      // No symbols loaded, so no SymbolTile widgets
      expect(find.byType(SymbolTile), findsNothing);
      state.dispose();
    });
  });

  group('SymbolSearchBar widget', () {
    testWidgets('renders search icon', (tester) async {
      final state = AppState();
      await tester.pumpWidget(_testApp(state, const SymbolSearchBar()));

      expect(find.byIcon(Icons.search), findsOneWidget);
      state.dispose();
    });

    testWidgets('shows hint text with category name', (tester) async {
      final state = AppState();
      await tester.pumpWidget(_testApp(state, const SymbolSearchBar()));

      // Default category is 'core', so hint should say "Search Core..."
      expect(find.text('Search Core...'), findsOneWidget);
      state.dispose();
    });

    testWidgets('no clear button when query is empty', (tester) async {
      final state = AppState();
      await tester.pumpWidget(_testApp(state, const SymbolSearchBar()));

      expect(find.byIcon(Icons.clear), findsNothing);
      state.dispose();
    });

    testWidgets('text size is 16sp', (tester) async {
      final state = AppState();
      await tester.pumpWidget(_testApp(state, const SymbolSearchBar()));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.style!.fontSize, greaterThanOrEqualTo(16));
      state.dispose();
    });
  });

  group('RecentPhrasesBar widget', () {
    testWidgets('hidden when no recent phrases', (tester) async {
      final state = AppState();
      await tester.pumpWidget(_testApp(state, const RecentPhrasesBar()));

      // Should render SizedBox.shrink — no history icon visible
      expect(find.byIcon(Icons.history), findsNothing);
      state.dispose();
    });
  });

  group('AppState custom symbols', () {
    late AppState state;

    setUp(() {
      state = AppState();
    });

    tearDown(() {
      state.dispose();
    });

    test('addCustomSymbol adds to allSymbols', () async {
      expect(state.allSymbols, isEmpty);
      await state.addCustomSymbol(
        label: 'Cookie',
        speakText: 'cookie',
        category: 'food',
        emoji: '🍪',
      );
      expect(state.allSymbols.length, 1);
      expect(state.allSymbols[0].label, 'Cookie');
      expect(state.allSymbols[0].id, startsWith('custom_'));
    });

    test('deleteCustomSymbol removes from allSymbols', () async {
      await state.addCustomSymbol(
        label: 'Cookie',
        speakText: 'cookie',
        category: 'food',
        emoji: '🍪',
      );
      final id = state.allSymbols[0].id;
      await state.deleteCustomSymbol(id);
      expect(state.allSymbols, isEmpty);
    });

    test('isCustomSymbol identifies custom symbols', () {
      expect(state.isCustomSymbol('custom_123'), isTrue);
      expect(state.isCustomSymbol('core_hello'), isFalse);
    });

    test('filteredSymbols filters by selected category', () async {
      await state.addCustomSymbol(
        label: 'Cookie',
        speakText: 'cookie',
        category: 'food',
        emoji: '🍪',
      );
      await state.addCustomSymbol(
        label: 'Yes',
        speakText: 'yes',
        category: 'core',
        emoji: '✅',
      );

      state.selectCategory('food');
      expect(state.filteredSymbols.length, 1);
      expect(state.filteredSymbols[0].label, 'Cookie');

      state.selectCategory('core');
      expect(state.filteredSymbols.length, 1);
      expect(state.filteredSymbols[0].label, 'Yes');
    });

    test('filteredSymbols excludes hidden symbols', () async {
      // Use importSymbolConfig for explicit IDs (addCustomSymbol uses
      // millisecondsSinceEpoch which can collide in fast tests)
      await state.importSymbolConfig(
        '{"version":1,"customSymbols":['
        '{"id":"custom_cookie","label":"Cookie","speakText":"cookie","category":"food","emoji":"🍪"},'
        '{"id":"custom_juice","label":"Juice","speakText":"juice","category":"food","emoji":"🧃"}'
        '],"hiddenSymbolIds":[],"symbolOrder":{}}',
      );

      state.selectCategory('food');
      expect(state.filteredSymbols.length, 2);

      await state.toggleSymbolVisibility('custom_cookie');

      expect(state.filteredSymbols.length, 1);
      expect(state.filteredSymbols[0].label, 'Juice');
    });

    test('toggleSymbolVisibility toggles hidden state', () async {
      await state.addCustomSymbol(
        label: 'Cookie',
        speakText: 'cookie',
        category: 'food',
        emoji: '🍪',
      );
      final id = state.allSymbols[0].id;

      expect(state.isSymbolHidden(id), isFalse);
      await state.toggleSymbolVisibility(id);
      expect(state.isSymbolHidden(id), isTrue);
      await state.toggleSymbolVisibility(id);
      expect(state.isSymbolHidden(id), isFalse);
    });

    test('filteredSymbols applies search query', () async {
      await state.importSymbolConfig(
        '{"version":1,"customSymbols":['
        '{"id":"custom_cookie2","label":"Cookie","speakText":"cookie","category":"food","emoji":"🍪"},'
        '{"id":"custom_juice2","label":"Juice","speakText":"juice","category":"food","emoji":"🧃"}'
        '],"hiddenSymbolIds":[],"symbolOrder":{}}',
      );

      state.selectCategory('food');
      state.setSearchQuery('cook');
      expect(state.filteredSymbols.length, 1);
      expect(state.filteredSymbols[0].label, 'Cookie');
    });

    test('search query is case insensitive', () async {
      await state.addCustomSymbol(
        label: 'Cookie',
        speakText: 'cookie',
        category: 'food',
        emoji: '🍪',
      );

      state.selectCategory('food');
      state.setSearchQuery('COOKIE');
      expect(state.filteredSymbols.length, 1);
    });

    test('resetSymbolCustomizations clears hidden and order', () async {
      await state.addCustomSymbol(
        label: 'Cookie',
        speakText: 'cookie',
        category: 'food',
        emoji: '🍪',
      );
      final id = state.allSymbols[0].id;
      await state.toggleSymbolVisibility(id);
      expect(state.isSymbolHidden(id), isTrue);

      await state.resetSymbolCustomizations();
      expect(state.isSymbolHidden(id), isFalse);
      expect(state.hiddenSymbolIds, isEmpty);
    });
  });

  group('AppState defaults', () {
    late AppState state;

    setUp(() {
      state = AppState();
    });

    tearDown(() {
      state.dispose();
    });

    test('dark mode defaults to true', () {
      expect(state.darkMode, isTrue);
    });

    test('sound effects defaults to false', () {
      expect(state.soundEffects, isFalse);
    });

    test('onboarding defaults to not complete', () {
      expect(state.onboardingComplete, isFalse);
    });

    test('camera defaults to disabled', () {
      expect(state.cameraEnabled, isFalse);
    });

    test('cloud defaults to disabled', () {
      expect(state.cloudEnabled, isFalse);
    });

    test('grid columns defaults to 4', () {
      expect(state.gridColumns, 4);
    });

    test('speech rate defaults to 0.45', () {
      expect(state.speechRate, 0.45);
    });

    test('pitch defaults to 1.0', () {
      expect(state.pitch, 1.0);
    });

    test('initialized defaults to false', () {
      expect(state.initialized, isFalse);
    });

    test('recent phrases starts empty', () {
      expect(state.recentPhrases, isEmpty);
    });

    test('suggested symbols starts empty', () {
      expect(state.suggestedSymbols, isEmpty);
    });
  });

  group('AppState import/export config', () {
    late AppState state;

    setUp(() {
      state = AppState();
    });

    tearDown(() {
      state.dispose();
    });

    test('importSymbolConfig returns error for invalid JSON', () async {
      final result = await state.importSymbolConfig('not valid json');
      expect(result, isNotNull);
      expect(result, startsWith('Invalid config file:'));
    });

    test('importSymbolConfig loads custom symbols', () async {
      final configJson = '{"version":1,"customSymbols":[{"id":"custom_1",'
          '"label":"Test","speakText":"test","category":"core","emoji":"🧪"}],'
          '"hiddenSymbolIds":[],"symbolOrder":{}}';
      final result = await state.importSymbolConfig(configJson);
      expect(result, isNull); // success
      expect(state.allSymbols.length, 1);
      expect(state.allSymbols[0].label, 'Test');
    });

    test('importSymbolConfig loads hidden IDs', () async {
      final configJson = '{"version":1,"customSymbols":[],'
          '"hiddenSymbolIds":["core_hello","core_yes"],"symbolOrder":{}}';
      final result = await state.importSymbolConfig(configJson);
      expect(result, isNull);
      expect(state.hiddenSymbolIds.length, 2);
      expect(state.isSymbolHidden('core_hello'), isTrue);
    });
  });
}
