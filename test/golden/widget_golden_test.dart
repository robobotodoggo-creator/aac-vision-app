import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aac_vision_app/models/aac_symbol.dart';
import 'package:aac_vision_app/widgets/symbol_tile.dart';
import 'package:aac_vision_app/widgets/sentence_bar.dart';
import 'package:aac_vision_app/widgets/aac_grid.dart';
import 'package:aac_vision_app/widgets/onboarding_overlay.dart';
import 'package:aac_vision_app/widgets/symbol_search_bar.dart';
import 'package:aac_vision_app/services/app_state.dart';

// Test symbols
const _symbols = [
  AacSymbol(id: 'core_yes', label: 'Yes', speakText: 'yes', category: 'core', emoji: '\u2705'),
  AacSymbol(id: 'core_no', label: 'No', speakText: 'no', category: 'core', emoji: '\u274C'),
  AacSymbol(id: 'core_help', label: 'Help', speakText: 'help', category: 'core', emoji: '\u{1F198}'),
  AacSymbol(id: 'core_hello', label: 'Hello', speakText: 'hello', category: 'core', emoji: '\u{1F44B}'),
  AacSymbol(id: 'food_water', label: 'Water', speakText: 'water', category: 'food', emoji: '\u{1F4A7}'),
  AacSymbol(id: 'food_eat', label: 'Eat', speakText: 'eat', category: 'food', emoji: '\u{1F37D}'),
];

/// Dark theme matching the app's default.
ThemeData _darkTheme() => ThemeData(
      brightness: Brightness.dark,
      colorSchemeSeed: Colors.blue,
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.black,
    );

/// Wraps a widget with Provider and dark MaterialApp for golden testing.
Widget _goldenApp(AppState state, Widget child, {Size size = const Size(400, 300)}) {
  return ChangeNotifierProvider<AppState>.value(
    value: state,
    child: MaterialApp(
      theme: _darkTheme(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SizedBox(width: size.width, height: size.height, child: child),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (MethodCall methodCall) async => null,
    );
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SymbolTile golden', () {
    testWidgets('dark theme tile renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: _darkTheme(),
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 120,
                height: 120,
                child: SymbolTile(
                  symbol: _symbols[0], // Yes
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/symbol_tile_dark.png'),
      );
    });

    testWidgets('light theme tile renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            colorSchemeSeed: Colors.blue,
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 120,
                height: 120,
                child: SymbolTile(
                  symbol: _symbols[0], // Yes
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/symbol_tile_light.png'),
      );
    });
  });

  group('SentenceBar golden', () {
    testWidgets('empty sentence bar shows placeholder', (tester) async {
      final state = AppState();
      addTearDown(state.dispose);

      await tester.pumpWidget(
        _goldenApp(state, const SentenceBar(), size: const Size(500, 70)),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/sentence_bar_empty.png'),
      );
    });

    testWidgets('sentence bar with symbols shows chips and controls', (tester) async {
      final state = AppState();
      addTearDown(state.dispose);

      state.addToSentence(_symbols[0]); // Yes
      state.addToSentence(_symbols[3]); // Hello
      state.addToSentence(_symbols[4]); // Water

      await tester.pumpWidget(
        _goldenApp(state, const SentenceBar(), size: const Size(600, 70)),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/sentence_bar_with_symbols.png'),
      );
    });
  });

  group('AacGrid golden', () {
    testWidgets('4-column grid with symbols', (tester) async {
      final state = AppState();
      addTearDown(state.dispose);

      // Import symbols via config so they appear in filteredSymbols
      await state.importSymbolConfig(
        '{"version":1,"customSymbols":['
        '{"id":"core_yes","label":"Yes","speakText":"yes","category":"core","emoji":"\\u2705"},'
        '{"id":"core_no","label":"No","speakText":"no","category":"core","emoji":"\\u274C"},'
        '{"id":"core_help","label":"Help","speakText":"help","category":"core","emoji":"\\u{1F198}"},'
        '{"id":"core_hello","label":"Hello","speakText":"hello","category":"core","emoji":"\\u{1F44B}"},'
        '{"id":"core_thanks","label":"Thanks","speakText":"thanks","category":"core","emoji":"\\u{1F64F}"},'
        '{"id":"core_please","label":"Please","speakText":"please","category":"core","emoji":"\\u{1F932}"},'
        '{"id":"core_more","label":"More","speakText":"more","category":"core","emoji":"\\u2795"},'
        '{"id":"core_stop","label":"Stop","speakText":"stop","category":"core","emoji":"\\u{1F6D1}"}'
        '],"hiddenSymbolIds":[],"symbolOrder":{}}',
      );

      await tester.pumpWidget(
        _goldenApp(state, const AacGrid(), size: const Size(400, 400)),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/aac_grid_4col.png'),
      );
    });
  });

  group('OnboardingOverlay golden', () {
    testWidgets('first step renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: _darkTheme(),
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: OnboardingOverlay(onComplete: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/onboarding_step1.png'),
      );
    });

    testWidgets('last step renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: _darkTheme(),
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: OnboardingOverlay(onComplete: () {}),
          ),
        ),
      );

      // Advance to step 5 (last)
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/onboarding_step5.png'),
      );
    });
  });

  group('SymbolSearchBar golden', () {
    testWidgets('empty search bar with hint text', (tester) async {
      final state = AppState();
      addTearDown(state.dispose);

      await tester.pumpWidget(
        _goldenApp(state, const SymbolSearchBar(), size: const Size(400, 70)),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/search_bar_empty.png'),
      );
    });
  });
}
