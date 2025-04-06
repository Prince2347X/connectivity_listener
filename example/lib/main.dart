import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:network_settings_listener/network_settings_listener.dart';
import 'package:network_settings_listener/network_settings_listener_platform_interface.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StateChange<WifiState>? _wifiStateChange;
  StateChange<BluetoothState>? _bluetoothStateChange;
  final _networkSettingsListener = NetworkSettingsListener();
  late StreamSubscription<StateChange<WifiState>> _wifiSubscription;
  late StreamSubscription<StateChange<BluetoothState>> _bluetoothSubscription;

  // Track transition messages
  String? _wifiTransitionMessage;
  String? _bluetoothTransitionMessage;

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
    _wifiSubscription = _networkSettingsListener.onWifiStateChanged.listen(
      (StateChange<WifiState> stateChange) {
        if (!mounted) return;
        setState(() {
          _wifiStateChange = stateChange;
          _wifiTransitionMessage = _getWifiTransitionMessage(stateChange);
        });
      },
      onError: (dynamic error) {
        if (!mounted) return;
        setState(() {
          _wifiStateChange = null;
          _wifiTransitionMessage = 'Error: $error';
        });
      },
    );

    // Listen to Bluetooth state changes
    _bluetoothSubscription = _networkSettingsListener.onBluetoothStateChanged.listen(
      (StateChange<BluetoothState> stateChange) {
        if (!mounted) return;
        setState(() {
          _bluetoothStateChange = stateChange;
          _bluetoothTransitionMessage = _getBluetoothTransitionMessage(stateChange);
        });
      },
      onError: (dynamic error) {
        if (!mounted) return;
        setState(() {
          if (error is PlatformException && error.code == 'PERMISSION_DENIED') {
            _showSnackBar('Bluetooth permission denied. Please grant permission.');
          }
          _bluetoothStateChange = null;
          _bluetoothTransitionMessage = 'Error: $error';
        });
      },
    );

    if (!mounted) return;
  }

  String _getWifiTransitionMessage(StateChange<WifiState> stateChange) {
    if (stateChange.previousState == null) {
      return 'Initial state: ${stateChange.currentState.name}';
    }

    // Handle specific transitions
    if (stateChange.previousState == WifiState.enabling && 
        stateChange.currentState == WifiState.enabled) {
      return 'WiFi successfully enabled';
    }
    if (stateChange.previousState == WifiState.enabling && 
        stateChange.currentState == WifiState.disabled) {
      return 'Failed to enable WiFi';
    }
    if (stateChange.previousState == WifiState.disabling && 
        stateChange.currentState == WifiState.disabled) {
      return 'WiFi successfully disabled';
    }

    // Default transition message
    return 'Transitioning from ${stateChange.previousState?.name ?? 'unknown'} to ${stateChange.currentState.name}';
  }

  String _getBluetoothTransitionMessage(StateChange<BluetoothState> stateChange) {
    if (stateChange.previousState == null) {
      return 'Initial state: ${stateChange.currentState.name}';
    }

    // Handle specific transitions
    if (stateChange.previousState == BluetoothState.turningOn && 
        stateChange.currentState == BluetoothState.on) {
      return 'Bluetooth successfully turned on';
    }
    if (stateChange.previousState == BluetoothState.turningOn && 
        stateChange.currentState == BluetoothState.off) {
      return 'Failed to turn on Bluetooth';
    }
    if (stateChange.previousState == BluetoothState.turningOff && 
        stateChange.currentState == BluetoothState.off) {
      return 'Bluetooth successfully turned off';
    }

    // Default transition message
    return 'Transitioning from ${stateChange.previousState?.name ?? 'unknown'} to ${stateChange.currentState.name}';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildStateCard(String title, StateChange? stateChange, String? transitionMessage) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (stateChange != null) ...[
              Text('Current: ${stateChange.currentState.name}',
                  style: Theme.of(context).textTheme.titleMedium),
              Text('Previous: ${stateChange.previousState?.name ?? 'none'}',
                  style: Theme.of(context).textTheme.titleMedium),
              if (transitionMessage != null) ...[
                const SizedBox(height: 8),
                Text(transitionMessage,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.blue,
                    )),
              ],
            ] else
              const Text('Unknown'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Connectivity Listener Example'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStateCard('WiFi State', _wifiStateChange, _wifiTransitionMessage),
                _buildStateCard('Bluetooth State', _bluetoothStateChange, _bluetoothTransitionMessage),
                const SizedBox(height: 20),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text('Instructions:', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('1. Toggle WiFi/Bluetooth in system settings'),
                        Text('2. Watch the state transitions in real-time'),
                        Text('3. Notice how previous states are tracked'),
                        SizedBox(height: 8),
                        Text('Note: Bluetooth requires permissions on Android 12+',
                            style: TextStyle(fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
