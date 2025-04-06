import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_listener/connectivity_listener.dart';
import 'package:connectivity_listener/connectivity_listener_platform_interface.dart';
import 'package:connectivity_listener/connectivity_listener_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockConnectivityListenerPlatform
    with MockPlatformInterfaceMixin
    implements ConnectivityListenerPlatform {
  // Mock the stream getters
  @override
  Stream<WifiState> get onWifiStateChanged =>
      Stream.value(WifiState.enabled); // Example stream

  @override
  Stream<BluetoothState> get onBluetoothStateChanged =>
      Stream.value(BluetoothState.on); // Example stream

  // Remove getPlatformVersion mock
  // @override
  // Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ConnectivityListenerPlatform initialPlatform =
      ConnectivityListenerPlatform.instance;

  test('$MethodChannelConnectivityListener is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelConnectivityListener>());
  });

  // Remove the old getPlatformVersion test
  // test('getPlatformVersion', () async {
  //   ConnectivityListener connectivityListenerPlugin = ConnectivityListener();
  //   MockConnectivityListenerPlatform fakePlatform = MockConnectivityListenerPlatform();
  //   ConnectivityListenerPlatform.instance = fakePlatform;
  //
  //   expect(await connectivityListenerPlugin.getPlatformVersion(), '42');
  // });

  test('onWifiStateChanged returns stream from platform', () {
    ConnectivityListener connectivityListenerPlugin = ConnectivityListener();
    MockConnectivityListenerPlatform fakePlatform =
        MockConnectivityListenerPlatform();
    ConnectivityListenerPlatform.instance = fakePlatform;

    expect(connectivityListenerPlugin.onWifiStateChanged,
        isA<Stream<WifiState>>());
    // Optionally, test if it emits the expected mock value
    expectLater(connectivityListenerPlugin.onWifiStateChanged,
        emits(WifiState.enabled));
  });

  test('onBluetoothStateChanged returns stream from platform', () {
    ConnectivityListener connectivityListenerPlugin = ConnectivityListener();
    MockConnectivityListenerPlatform fakePlatform =
        MockConnectivityListenerPlatform();
    ConnectivityListenerPlatform.instance = fakePlatform;

    expect(connectivityListenerPlugin.onBluetoothStateChanged,
        isA<Stream<BluetoothState>>());
    // Optionally, test if it emits the expected mock value
    expectLater(connectivityListenerPlugin.onBluetoothStateChanged,
        emits(BluetoothState.on));
  });
}
