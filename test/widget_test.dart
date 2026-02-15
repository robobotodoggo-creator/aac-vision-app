import 'package:flutter_test/flutter_test.dart';
import 'package:aac_vision_app/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const AacVisionApp());
    expect(find.text('AAC Vision'), findsNothing); // no visible title bar
  });
}
