import 'dart:async';

import 'network_settings_listener_platform_interface.dart';

/// A Flutter plugin for listening to Android connectivity state changes.
///
/// Provides streams to monitor WiFi and Bluetooth state changes, including
/// transitional states (enabling/disabling) and previous states.
class NetworkSettingsListener {
  /// Stream that emits [StateChange<WifiState>] changes, including both current and previous states.
  ///
  /// The states can be:
  /// * [WifiState.enabling] - WiFi is currently being enabled
  /// * [WifiState.enabled] - WiFi is fully enabled
  /// * [WifiState.disabling] - WiFi is currently being disabled
  /// * [WifiState.disabled] - WiFi is fully disabled
  /// * [WifiState.unknown] - WiFi state is unknown
  Stream<StateChange<WifiState>> get onWifiStateChanged {
    return NetworkSettingsListenerPlatform.instance.onWifiStateChanged;
  }

  /// Stream that emits [StateChange<BluetoothState>] changes, including both current and previous states.
  ///
  /// The states can be:
  /// * [BluetoothState.turningOn] - Bluetooth is currently being turned on
  /// * [BluetoothState.on] - Bluetooth is fully turned on
  /// * [BluetoothState.turningOff] - Bluetooth is currently being turned off
  /// * [BluetoothState.off] - Bluetooth is fully turned off
  /// * [BluetoothState.unknown] - Bluetooth state is unknown
  Stream<StateChange<BluetoothState>> get onBluetoothStateChanged {
    return NetworkSettingsListenerPlatform.instance.onBluetoothStateChanged;
  }
}
