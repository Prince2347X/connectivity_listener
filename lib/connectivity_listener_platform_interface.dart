import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'connectivity_listener_method_channel.dart';

/// Enum representing the possible states of WiFi connectivity.
enum WifiState { enabled, disabled, unknown }

/// Enum representing the possible states of Bluetooth connectivity.
enum BluetoothState { on, off, unknown }

abstract class ConnectivityListenerPlatform extends PlatformInterface {
  /// Constructs a ConnectivityListenerPlatform.
  ConnectivityListenerPlatform() : super(token: _token);

  static final Object _token = Object();

  static ConnectivityListenerPlatform _instance =
      MethodChannelConnectivityListener();

  /// The default instance of [ConnectivityListenerPlatform] to use.
  ///
  /// Defaults to [MethodChannelConnectivityListener].
  static ConnectivityListenerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ConnectivityListenerPlatform] when
  /// they register themselves.
  static set instance(ConnectivityListenerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Stream that emits [WifiState] changes.
  Stream<WifiState> get onWifiStateChanged {
    throw UnimplementedError('onWifiStateChanged has not been implemented.');
  }

  /// Stream that emits [BluetoothState] changes.
  Stream<BluetoothState> get onBluetoothStateChanged {
    throw UnimplementedError(
        'onBluetoothStateChanged has not been implemented.');
  }
}
