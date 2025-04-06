import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart'; // Import for PlatformException

import 'package:connectivity_listener/connectivity_listener.dart';
import 'package:connectivity_listener/connectivity_listener_platform_interface.dart'; // Import enums

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  WifiState _wifiState = WifiState.unknown;
  BluetoothState _bluetoothState = BluetoothState.unknown;
  final _connectivityListenerPlugin = ConnectivityListener();
  late StreamSubscription<WifiState> _wifiSubscription;
  late StreamSubscription<BluetoothState> _bluetoothSubscription;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    _wifiSubscription.cancel();
    _bluetoothSubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Listen to WiFi state changes
    _wifiSubscription = _connectivityListenerPlugin.onWifiStateChanged.listen(
        (WifiState state) {
      if (!mounted) return;
      setState(() {
        _wifiState = state;
      });
    }, onError: (dynamic error) {
      // print('Error listening to WiFi state: $error');
      if (!mounted) return;
      setState(() {
        _wifiState = WifiState.unknown; // Handle error state
      });
    });

    // Listen to Bluetooth state changes
    _bluetoothSubscription = _connectivityListenerPlugin.onBluetoothStateChanged
        .listen((BluetoothState state) {
      if (!mounted) return;
      setState(() {
        _bluetoothState = state;
      });
    }, onError: (dynamic error) {
      // print('Error listening to Bluetooth state: $error');
      if (!mounted) return;
      setState(() {
        // Handle potential permission errors reported from native side
        if (error is PlatformException && error.code == 'PERMISSION_DENIED') {
          // print('Bluetooth permission denied. Please grant permission.');
          // Optionally show a message to the user
        }
        _bluetoothState = BluetoothState.unknown; // Handle error state
      });
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    // Initial states might be set quickly by the stream's first event
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Connectivity Listener Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('WiFi State: ${_wifiState.name}\n',
                  style: Theme.of(context).textTheme.headlineSmall),
              Text('Bluetooth State: ${_bluetoothState.name}\n',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),
              const Text(
                  'Toggle WiFi/Bluetooth in system settings to see changes.'),
              const SizedBox(height: 10),
              const Text(
                  '(Note: Bluetooth requires permissions on Android 12+)'),
            ],
          ),
        ),
      ),
    );
  }
}
