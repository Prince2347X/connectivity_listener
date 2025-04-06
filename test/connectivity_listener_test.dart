import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_listener/connectivity_listener.dart';
import 'package:connectivity_listener/connectivity_listener_platform_interface.dart';
import 'package:connectivity_listener/connectivity_listener_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockConnectivityListenerPlatform
    with MockPlatformInterfaceMixin
    implements ConnectivityListenerPlatform {
  // Remove unused state tracking fields
  // We don't need them since we're using Stream.fromIterable

  @override
  Stream<StateChange<WifiState>> get onWifiStateChanged {
    return Stream.fromIterable([
      StateChange(null, WifiState.disabled),
      StateChange(WifiState.disabled, WifiState.enabling),
      StateChange(WifiState.enabling, WifiState.enabled),
    ]);
  }

  @override
  Stream<StateChange<BluetoothState>> get onBluetoothStateChanged {
    return Stream.fromIterable([
      StateChange(null, BluetoothState.off),
      StateChange(BluetoothState.off, BluetoothState.turningOn),
      StateChange(BluetoothState.turningOn, BluetoothState.on),
    ]);
  }
}

void main() {
  final ConnectivityListenerPlatform initialPlatform = ConnectivityListenerPlatform.instance;

  test('$MethodChannelConnectivityListener is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelConnectivityListener>());
  });

  test('onWifiStateChanged emits state changes in correct order', () async {
    final plugin = ConnectivityListener();
    final fakePlatform = MockConnectivityListenerPlatform();
    ConnectivityListenerPlatform.instance = fakePlatform;

    expect(
      plugin.onWifiStateChanged,
      emitsInOrder([
        // Initial state
        predicate((StateChange<WifiState> state) =>
            state.previousState == null && state.currentState == WifiState.disabled),
        // Enabling transition
        predicate((StateChange<WifiState> state) =>
            state.previousState == WifiState.disabled &&
            state.currentState == WifiState.enabling),
        // Fully enabled
        predicate((StateChange<WifiState> state) =>
            state.previousState == WifiState.enabling &&
            state.currentState == WifiState.enabled),
      ]),
    );
  });

  test('onBluetoothStateChanged emits state changes in correct order', () async {
    final plugin = ConnectivityListener();
    final fakePlatform = MockConnectivityListenerPlatform();
    ConnectivityListenerPlatform.instance = fakePlatform;

    expect(
      plugin.onBluetoothStateChanged,
      emitsInOrder([
        // Initial state
        predicate((StateChange<BluetoothState> state) =>
            state.previousState == null && state.currentState == BluetoothState.off),
        // Turning on transition
        predicate((StateChange<BluetoothState> state) =>
            state.previousState == BluetoothState.off &&
            state.currentState == BluetoothState.turningOn),
        // Fully on
        predicate((StateChange<BluetoothState> state) =>
            state.previousState == BluetoothState.turningOn &&
            state.currentState == BluetoothState.on),
      ]),
    );
  });

  test('StateChange toString returns formatted string', () {
    final stateChange = StateChange(WifiState.disabled, WifiState.enabled);
    expect(
      stateChange.toString(),
      'StateChange(previous: disabled, current: enabled)',
    );
  });
}
