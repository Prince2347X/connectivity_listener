// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:connectivity_listener_example/main.dart';

void main() {
  testWidgets('Verify initial UI elements', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the initial state texts are present.
    // The exact initial state might vary, so we check for the labels.
    expect(find.textContaining('WiFi State:'), findsOneWidget);
    expect(find.textContaining('Bluetooth State:'), findsOneWidget);

    // Example of tapping (not needed for this test, but shows capability)
    // await tester.tap(find.byIcon(Icons.add));
    // await tester.pump();

    // Verify that our counter has incremented.
    // expect(find.text('0'), findsNothing);
    // expect(find.text('1'), findsOneWidget);
  });
}
