import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'network_settings_listener_method_channel.dart';

/// Represents all possible WiFi states as defined in Android's WifiManager
enum WifiState {
  /// WiFi is currently being enabled
  enabling,
  /// WiFi is fully enabled
  enabled,
  /// WiFi is currently being disabled
  disabling,
  /// WiFi is fully disabled
  disabled,
  /// WiFi state is unknown
  unknown
}

/// Represents all possible Bluetooth states as defined in Android's BluetoothAdapter
enum BluetoothState {
  /// Bluetooth is currently being turned on
  turningOn,
  /// Bluetooth is fully turned on
  on,
  /// Bluetooth is currently being turned off
  turningOff,
  /// Bluetooth is fully turned off
  off,
  /// Bluetooth state is unknown
  unknown
}

/// Class to hold state change information including previous and current states
class StateChange<T extends Enum> {
  /// The previous state before the change
  final T? previousState;
  /// The current state after the change
  final T currentState;

  /// Creates a new StateChange instance
  const StateChange(this.previousState, this.currentState);

  @override
  String toString() => 'StateChange(previous: ${previousState?.name}, current: ${currentState.name})';
}

abstract class NetworkSettingsListenerPlatform extends PlatformInterface {
  /// Constructs a NetworkSettingsListenerPlatform.
  NetworkSettingsListenerPlatform() : super(token: _token);

  static final Object _token = Object();

  static NetworkSettingsListenerPlatform _instance = MethodChannelNetworkSettingsListener();

  /// The default instance of [NetworkSettingsListenerPlatform] to use.
  ///
  /// Defaults to [MethodChannelNetworkSettingsListener].
  static NetworkSettingsListenerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NetworkSettingsListenerPlatform] when
  /// they register themselves.
  static set instance(NetworkSettingsListenerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Stream that emits [StateChange<WifiState>] when WiFi state changes.
  Stream<StateChange<WifiState>> get onWifiStateChanged {
    throw UnimplementedError('onWifiStateChanged has not been implemented.');
  }

  /// Stream that emits [StateChange<BluetoothState>] when Bluetooth state changes.
  Stream<StateChange<BluetoothState>> get onBluetoothStateChanged {
    throw UnimplementedError('onBluetoothStateChanged has not been implemented.');
  }
}
