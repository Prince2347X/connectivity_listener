import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'connectivity_listener_platform_interface.dart';

/// An implementation of [ConnectivityListenerPlatform] that uses method channels.
class MethodChannelConnectivityListener extends ConnectivityListenerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel(
      'connectivity_listener/method'); // Renamed for clarity

  /// Event channel for WiFi state changes.
  @visibleForTesting
  final wifiEventChannel =
      const EventChannel('connectivity_listener/wifi_state');

  /// Event channel for Bluetooth state changes.
  @visibleForTesting
  final bluetoothEventChannel =
      const EventChannel('connectivity_listener/bluetooth_state');

  Stream<WifiState>? _onWifiStateChanged;
  Stream<BluetoothState>? _onBluetoothStateChanged;

  @override
  Stream<WifiState> get onWifiStateChanged {
    _onWifiStateChanged ??= wifiEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => _parseWifiState(event as int?));
    return _onWifiStateChanged!;
  }

  @override
  Stream<BluetoothState> get onBluetoothStateChanged {
    _onBluetoothStateChanged ??= bluetoothEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => _parseBluetoothState(event as int?));
    return _onBluetoothStateChanged!;
  }

  // Helper to parse integer state from Android WifiManager to WifiState enum
  WifiState _parseWifiState(int? state) {
    switch (state) {
      case 3: // WIFI_STATE_ENABLED
        return WifiState.enabled;
      case 1: // WIFI_STATE_DISABLED
        return WifiState.disabled;
      default:
        return WifiState.unknown;
    }
  }

  // Helper to parse integer state from Android BluetoothAdapter to BluetoothState enum
  BluetoothState _parseBluetoothState(int? state) {
    switch (state) {
      case 12: // STATE_ON
        return BluetoothState.on;
      case 10: // STATE_OFF
        return BluetoothState.off;
      default:
        return BluetoothState.unknown;
    }
  }
}
