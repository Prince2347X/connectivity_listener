import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_settings_listener_example/main.dart';

void main() {
  testWidgets('Smoke test - app can start', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Network Settings Listener Example'), findsOneWidget);
    expect(find.byType(Card),
        findsNWidgets(3)); // Two state cards and one instruction card
  });
}
