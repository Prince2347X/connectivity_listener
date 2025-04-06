import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:connectivity_listener/connectivity_listener.dart';
import 'package:connectivity_listener/connectivity_listener_platform_interface.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StateChange<WifiState>? _wifiState;
  StateChange<BluetoothState>? _bluetoothState;
  final _connectivityListenerPlugin = ConnectivityListener();
  late StreamSubscription<StateChange<WifiState>> _wifiSubscription;
  late StreamSubscription<StateChange<BluetoothState>> _bluetoothSubscription;

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
      (StateChange<WifiState> state) {
        if (!mounted) return;
        setState(() {
          _wifiState = state;
        });
      },
      onError: (dynamic error) {
        if (!mounted) return;
        setState(() {
          _wifiState = null; // Handle error state
        });
      },
    );

    // Listen to Bluetooth state changes
    _bluetoothSubscription = _connectivityListenerPlugin.onBluetoothStateChanged.listen(
      (StateChange<BluetoothState> state) {
        if (!mounted) return;
        setState(() {
          _bluetoothState = state;
        });
      },
      onError: (dynamic error) {
        if (!mounted) return;
        setState(() {
          if (error is PlatformException && error.code == 'PERMISSION_DENIED') {
            // Handle permission error
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bluetooth permission denied. Please grant permission.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
          _bluetoothState = null; // Handle error state
        });
      },
    );

    if (!mounted) return;
  }

  String _getWifiStateText() {
    if (_wifiState == null) return 'Unknown';
    final previous = _wifiState!.previousState?.name ?? 'unknown';
    final current = _wifiState!.currentState.name;
    return 'Current: $current\nPrevious: $previous';
  }

  String _getBluetoothStateText() {
    if (_bluetoothState == null) return 'Unknown';
    final previous = _bluetoothState!.previousState?.name ?? 'unknown';
    final current = _bluetoothState!.currentState.name;
    return 'Current: $current\nPrevious: $previous';
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
              Text('WiFi State:\n${_getWifiStateText()}\n',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Text('Bluetooth State:\n${_getBluetoothStateText()}\n',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              const Text('Toggle WiFi/Bluetooth in system settings to see changes.',
                  textAlign: TextAlign.center),
              const SizedBox(height: 10),
              const Text('You\'ll see transitional states (enabling/disabling)\nand previous states.',
                  textAlign: TextAlign.center),
              const SizedBox(height: 10),
              const Text('(Note: Bluetooth requires permissions on Android 12+)',
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
