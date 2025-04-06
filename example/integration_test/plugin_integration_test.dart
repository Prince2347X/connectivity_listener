import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:network_settings_listener/network_settings_listener.dart';
import 'package:network_settings_listener/network_settings_listener_platform_interface.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('State change streams are accessible and include previous states', (WidgetTester tester) async {
    final NetworkSettingsListener plugin = NetworkSettingsListener();
    
    // For tracking state changes
    StateChange<WifiState>? lastWifiStateChange;
    StateChange<BluetoothState>? lastBluetoothStateChange;
    
    // Listen to both streams
    final wifiSubscription = plugin.onWifiStateChanged.listen((change) {
      lastWifiStateChange = change;
    });

    final bluetoothSubscription = plugin.onBluetoothStateChanged.listen((change) {
      lastBluetoothStateChange = change;
    });

    // Wait for initial states (might take a moment on real device)
    await Future<void>.delayed(const Duration(seconds: 1));

    // Verify that we received state changes with proper structure
    expect(lastWifiStateChange, isNotNull);
    expect(lastWifiStateChange?.currentState, isA<WifiState>());
    // Initial state should have null previous state
    expect(lastWifiStateChange?.previousState, isNull);

    if (lastBluetoothStateChange != null) { // Might be null if permission denied
      expect(lastBluetoothStateChange?.currentState, isA<BluetoothState>());
      // Initial state should have null previous state
      expect(lastBluetoothStateChange?.previousState, isNull);
    }

    // Clean up
    await wifiSubscription.cancel();
    await bluetoothSubscription.cancel();
  });
}
