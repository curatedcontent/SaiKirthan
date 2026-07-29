// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:saikirthan/main.dart';

void main() {
  testWidgets('App loads and shows language selection',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SaiKirthanApp());

    // Verify that landing page shows language selection and buttons.
    expect(find.text('Select a language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('हिन्दी'), findsOneWidget);
    expect(find.text('తెలుగు'), findsOneWidget);
  });
}
