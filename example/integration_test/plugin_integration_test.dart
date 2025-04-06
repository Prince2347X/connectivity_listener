import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:connectivity_listener/connectivity_listener.dart';
import 'package:connectivity_listener/connectivity_listener_platform_interface.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Streams are accessible', (WidgetTester tester) async {
    final ConnectivityListener plugin = ConnectivityListener();

    // Verify that accessing the streams doesn't throw an immediate error.
    // We'll listen for a short duration.
    StreamSubscription<WifiState>? wifiSubscription;
    StreamSubscription<BluetoothState>? bluetoothSubscription;

    expect(() {
      wifiSubscription = plugin.onWifiStateChanged.listen((_) {});
    }, returnsNormally);

    expect(() {
      bluetoothSubscription = plugin.onBluetoothStateChanged.listen((_) {});
    }, returnsNormally);

    // Allow some time for any initial events or errors (like permission errors)
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Clean up subscriptions
    await wifiSubscription?.cancel();
    await bluetoothSubscription?.cancel();

    // The test passes if no exceptions were thrown during stream access and initial listen.
  });
}
