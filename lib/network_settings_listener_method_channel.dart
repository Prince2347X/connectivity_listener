import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'network_settings_listener_platform_interface.dart';

/// An implementation of [NetworkSettingsListenerPlatform] that uses method channels.
class MethodChannelNetworkSettingsListener
    extends NetworkSettingsListenerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('network_settings_listener/method');

  /// Event channel for WiFi state changes.
  @visibleForTesting
  final wifiEventChannel =
      const EventChannel('network_settings_listener/wifi_state');

  /// Event channel for Bluetooth state changes.
  @visibleForTesting
  final bluetoothEventChannel =
      const EventChannel('network_settings_listener/bluetooth_state');

  Stream<StateChange<WifiState>>? _onWifiStateChanged;
  Stream<StateChange<BluetoothState>>? _onBluetoothStateChanged;

  @override
  Stream<StateChange<WifiState>> get onWifiStateChanged {
    _onWifiStateChanged ??=
        wifiEventChannel.receiveBroadcastStream().map((dynamic event) {
      final Map<dynamic, dynamic> stateMap = event as Map<dynamic, dynamic>;
      return StateChange(_parseWifiState(stateMap['previousState'] as int?),
          _parseWifiState(stateMap['currentState'] as int?));
    });
    return _onWifiStateChanged!;
  }

  @override
  Stream<StateChange<BluetoothState>> get onBluetoothStateChanged {
    _onBluetoothStateChanged ??=
        bluetoothEventChannel.receiveBroadcastStream().map((dynamic event) {
      final Map<dynamic, dynamic> stateMap = event as Map<dynamic, dynamic>;
      return StateChange(
          _parseBluetoothState(stateMap['previousState'] as int?),
          _parseBluetoothState(stateMap['currentState'] as int?));
    });
    return _onBluetoothStateChanged!;
  }

  // Helper to parse integer state from Android WifiManager to WifiState enum
  WifiState _parseWifiState(int? state) {
    switch (state) {
      case 0: // WifiManager.WIFI_STATE_DISABLING
        return WifiState.disabling;
      case 1: // WifiManager.WIFI_STATE_DISABLED
        return WifiState.disabled;
      case 2: // WifiManager.WIFI_STATE_ENABLING
        return WifiState.enabling;
      case 3: // WifiManager.WIFI_STATE_ENABLED
        return WifiState.enabled;
      case 4: // WifiManager.WIFI_STATE_UNKNOWN
      case null:
      default:
        return WifiState.unknown;
    }
  }

  // Helper to parse integer state from Android BluetoothAdapter to BluetoothState enum
  BluetoothState _parseBluetoothState(int? state) {
    switch (state) {
      case 11: // BluetoothAdapter.STATE_TURNING_ON
        return BluetoothState.turningOn;
      case 12: // BluetoothAdapter.STATE_ON
        return BluetoothState.on;
      case 13: // BluetoothAdapter.STATE_TURNING_OFF
        return BluetoothState.turningOff;
      case 10: // BluetoothAdapter.STATE_OFF
        return BluetoothState.off;
      case 15: // BluetoothAdapter.STATE_DISCONNECTING
      case 16: // BluetoothAdapter.STATE_DISCONNECTED
      case 20: // BluetoothAdapter.STATE_CONNECTING
      case 0: // BluetoothAdapter.ERROR
      case null:
      default:
        return BluetoothState.unknown;
    }
  }
}
