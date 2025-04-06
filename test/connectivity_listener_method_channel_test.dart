import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_listener/connectivity_listener_method_channel.dart';
import 'package:connectivity_listener/connectivity_listener_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelConnectivityListener platform =
      MethodChannelConnectivityListener();
  const String wifiChannelName = 'connectivity_listener/wifi_state';
  const String bluetoothChannelName = 'connectivity_listener/bluetooth_state';

  // Helper to encode messages for event channels
  ByteData? encodeEvent(dynamic event) {
    if (event == null) {
      return null;
    }
    return const StandardMethodCodec().encodeSuccessEnvelope(event);
  }

  tearDown(() {
    // Clear handlers after each test
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(wifiChannelName, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(bluetoothChannelName, null);
  });

  test('onWifiStateChanged emits correct states', () async {
    // Simulate the native side sending events
    Future<void> emitWifiEvent(dynamic event) async {
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
        wifiChannelName,
        encodeEvent(event),
        (ByteData? reply) {},
      );
    }

    // Expect the platform stream to emit the parsed states
    expectLater(
      platform.onWifiStateChanged,
      emitsInOrder(<WifiState>[
        WifiState.enabled, // Simulate native sending 3
        WifiState.disabled, // Simulate native sending 1
        WifiState.unknown, // Simulate native sending null or other int
      ]),
    );

    // Simulate events coming from the native side
    await emitWifiEvent(3); // WIFI_STATE_ENABLED
    await emitWifiEvent(1); // WIFI_STATE_DISABLED
    await emitWifiEvent(null); // Unknown state

    // Add a short delay to allow the event to propagate before the test ends
    await Future<void>.delayed(Duration.zero);
  });

  test('onBluetoothStateChanged emits correct states', () async {
    Future<void> emitBluetoothEvent(dynamic event) async {
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
        bluetoothChannelName,
        encodeEvent(event),
        (ByteData? reply) {},
      );
    }

    expectLater(
      platform.onBluetoothStateChanged,
      emitsInOrder(<BluetoothState>[
        BluetoothState.on, // Simulate native sending 12
        BluetoothState.off, // Simulate native sending 10
        BluetoothState.unknown, // Simulate native sending null or other int
      ]),
    );

    await emitBluetoothEvent(12); // STATE_ON
    await emitBluetoothEvent(10); // STATE_OFF
    await emitBluetoothEvent(13); // Unknown state

    // Add a short delay here as well for consistency
    await Future<void>.delayed(Duration.zero);
  });

  // Remove the old MockStreamHandler class
  // class MockStreamHandler implements MockStreamHandlerPlatform { ... }
}
