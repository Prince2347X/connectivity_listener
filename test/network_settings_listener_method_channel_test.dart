import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_settings_listener/network_settings_listener_method_channel.dart';
import 'package:network_settings_listener/network_settings_listener_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelNetworkSettingsListener platform =
      MethodChannelNetworkSettingsListener();
  const String wifiChannelName = 'network_settings_listener/wifi_state';
  const String bluetoothChannelName =
      'network_settings_listener/bluetooth_state';

  // Helper to encode messages for event channels
  ByteData? encodeEvent(dynamic event) {
    if (event == null) {
      return null;
    }
    return const StandardMethodCodec().encodeSuccessEnvelope(event);
  }

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(wifiChannelName, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(bluetoothChannelName, null);
  });

  test('onWifiStateChanged emits correct state changes', () async {
    Future<void> emitWifiEvent(Map<String, dynamic> stateMap) async {
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
        wifiChannelName,
        encodeEvent(stateMap),
        (ByteData? reply) {},
      );
    }

    // Test a complete enable/disable cycle with transitions
    expectLater(
      platform.onWifiStateChanged,
      emitsInOrder(<Matcher>[
        // Initial state should have unknown as previous since it's the first event
        predicate((StateChange<WifiState> change) =>
            change.previousState == WifiState.unknown &&
            change.currentState == WifiState.disabled),
        // Start enabling
        predicate((StateChange<WifiState> change) =>
            change.previousState == WifiState.disabled &&
            change.currentState == WifiState.enabling),
        // Fully enabled
        predicate((StateChange<WifiState> change) =>
            change.previousState == WifiState.enabling &&
            change.currentState == WifiState.enabled),
        // Start disabling
        predicate((StateChange<WifiState> change) =>
            change.previousState == WifiState.enabled &&
            change.currentState == WifiState.disabling),
        // Fully disabled
        predicate((StateChange<WifiState> change) =>
            change.previousState == WifiState.disabling &&
            change.currentState == WifiState.disabled),
      ]),
    );

    // Simulate a complete enable/disable cycle with the correct native Android state values
    await emitWifiEvent({
      'previousState': null,
      'currentState': 1
    }); // Initial WIFI_STATE_DISABLED
    await emitWifiEvent(
        {'previousState': 1, 'currentState': 2}); // WIFI_STATE_ENABLING
    await emitWifiEvent(
        {'previousState': 2, 'currentState': 3}); // WIFI_STATE_ENABLED
    await emitWifiEvent(
        {'previousState': 3, 'currentState': 0}); // WIFI_STATE_DISABLING
    await emitWifiEvent(
        {'previousState': 0, 'currentState': 1}); // Back to WIFI_STATE_DISABLED

    // Add a short delay to ensure all events are processed
    await Future<void>.delayed(Duration.zero);
  });

  test('onBluetoothStateChanged emits correct state changes', () async {
    Future<void> emitBluetoothEvent(Map<String, dynamic> stateMap) async {
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
        bluetoothChannelName,
        encodeEvent(stateMap),
        (ByteData? reply) {},
      );
    }

    expectLater(
      platform.onBluetoothStateChanged,
      emitsInOrder(<Matcher>[
        // Initial state should have unknown as previous since it's the first event
        predicate((StateChange<BluetoothState> change) =>
            change.previousState == BluetoothState.unknown &&
            change.currentState == BluetoothState.off),
        // Start turning on
        predicate((StateChange<BluetoothState> change) =>
            change.previousState == BluetoothState.off &&
            change.currentState == BluetoothState.turningOn),
        // Fully on
        predicate((StateChange<BluetoothState> change) =>
            change.previousState == BluetoothState.turningOn &&
            change.currentState == BluetoothState.on),
        // Start turning off
        predicate((StateChange<BluetoothState> change) =>
            change.previousState == BluetoothState.on &&
            change.currentState == BluetoothState.turningOff),
        // Fully off
        predicate((StateChange<BluetoothState> change) =>
            change.previousState == BluetoothState.turningOff &&
            change.currentState == BluetoothState.off),
      ]),
    );

    // Simulate a complete on/off cycle with correct native Android state values
    await emitBluetoothEvent(
        {'previousState': null, 'currentState': 10}); // Initial STATE_OFF
    await emitBluetoothEvent(
        {'previousState': 10, 'currentState': 11}); // STATE_TURNING_ON
    await emitBluetoothEvent(
        {'previousState': 11, 'currentState': 12}); // STATE_ON
    await emitBluetoothEvent(
        {'previousState': 12, 'currentState': 13}); // STATE_TURNING_OFF
    await emitBluetoothEvent(
        {'previousState': 13, 'currentState': 10}); // Back to STATE_OFF

    // Add a short delay to ensure all events are processed
    await Future<void>.delayed(Duration.zero);
  });
}
