import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis_assistant/main.dart';

void main() {
  testWidgets('JARVIS app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const JarvisApp());
    expect(find.text('J.A.R.V.I.S.'), findsWidgets);
  });
}
