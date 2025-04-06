import 'dart:async';

import 'connectivity_listener_platform_interface.dart';

/// A Flutter plugin for listening to Android connectivity state changes.
///
/// Provides streams to monitor WiFi and Bluetooth state.
class ConnectivityListener {
  /// Stream that emits [WifiState] changes.
  Stream<WifiState> get onWifiStateChanged {
    return ConnectivityListenerPlatform.instance.onWifiStateChanged;
  }

  /// Stream that emits [BluetoothState] changes.
  Stream<BluetoothState> get onBluetoothStateChanged {
    return ConnectivityListenerPlatform.instance.onBluetoothStateChanged;
  }
}
