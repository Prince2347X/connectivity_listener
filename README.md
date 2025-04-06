# network_settings_listener

A Flutter plugin for Android to listen for WiFi and Bluetooth connectivity state changes.

[![pub version](https://img.shields.io/pub/v/network_settings_listener.svg)](https://pub.dev/packages/network_settings_listener)
[![likes](https://img.shields.io/pub/likes/network_settings_listener)](https://pub.dev/packages/network_settings_listener)
[![popularity](https://img.shields.io/pub/popularity/network_settings_listener)](https://pub.dev/packages/network_settings_listener)
[![pub points](https://img.shields.io/pub/points/network_settings_listener)](https://pub.dev/packages/network_settings_listener)
[![Vibe Coded ✨](https://img.shields.io/badge/Vibe_Coded-✨-purple)](https://github.com/Prince2347X/network_settings_listener)

> ⚠️ **Use with Caution**: This library is AI-assisted. While it aims to provide reliable functionality, thorough testing in your specific use case is recommended.

## Features

*   Provides streams to monitor changes in WiFi states:
    * `enabling` - WiFi is currently being enabled
    * `enabled` - WiFi is fully enabled
    * `disabling` - WiFi is currently being disabled
    * `disabled` - WiFi is fully disabled
    * `unknown` - WiFi state is unknown
*   Provides streams to monitor changes in Bluetooth states:
    * `turningOn` - Bluetooth is currently being turned on
    * `on` - Bluetooth is fully turned on
    * `turningOff` - Bluetooth is currently being turned off
    * `off` - Bluetooth is fully turned off
    * `unknown` - Bluetooth state is unknown
*   Tracks and provides both current and previous states for each state change
*   Android only implementation

## Getting Started

This plugin focuses solely on the Android platform.

### Prerequisites

*   Flutter SDK
*   Android development environment

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  network_settings_listener: ^0.0.1 # Use the latest version
```

Then run `flutter pub get`.

### Android Setup

You need to add the required permissions to your app's main `AndroidManifest.xml` file, located at `<your_app>/android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android" ...>
    <!-- Required for checking WiFi state -->
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />

    <!-- Required for checking Bluetooth state -->
    <uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
    <!-- Required for checking Bluetooth state on Android 12+ -->
    <!-- IMPORTANT: You might need to request this permission at runtime -->
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />

    <application ...>
      ...
    </application>
</manifest>
```

**Important for Android 12 (API 31) and above:**

The `BLUETOOTH_CONNECT` permission is a runtime permission. Your application must request this permission from the user before it can listen to Bluetooth state changes. You can use a package like `permission_handler` to manage runtime permission requests.

## Usage

Import the package:

```dart
import 'package:network_settings_listener/network_settings_listener.dart';
import 'package:network_settings_listener/network_settings_listener_platform_interface.dart';
import 'dart:async';
```

Create an instance of the plugin and listen to the streams:

```dart
final _networkSettingsListener = NetworkSettingsListener();
late StreamSubscription<StateChange<WifiState>> _wifiSubscription;
late StreamSubscription<StateChange<BluetoothState>> _bluetoothSubscription;

// Initialize state tracking
StateChange<WifiState>? _wifiStateChange;
StateChange<BluetoothState>? _bluetoothStateChange;

void startListening() {
  _wifiSubscription = _networkSettingsListener.onWifiStateChanged.listen((StateChange<WifiState> stateChange) {
    print("WiFi state changed: ${stateChange.currentState.name} (previous: ${stateChange.previousState?.name ?? 'none'})");
    setState(() {
      _wifiStateChange = stateChange;
    });
  });
  
  _bluetoothSubscription = _networkSettingsListener.onBluetoothStateChanged.listen((StateChange<BluetoothState> stateChange) {
    print("Bluetooth state changed: ${stateChange.currentState.name} (previous: ${stateChange.previousState?.name ?? 'none'})");
    setState(() {
      _bluetoothStateChange = stateChange;
    });
  }, onError: (error) {
    if (error is PlatformException && error.code == 'PERMISSION_DENIED') {
      print('BLUETOOTH_CONNECT permission denied. Please request it.');
    }
  });
}

@override
void dispose() {
  _wifiSubscription.cancel();
  _bluetoothSubscription.cancel();
  super.dispose();
}
```

### State Change Detection Examples

You can track state transitions and handle different scenarios:

```dart
void onWifiStateChanged(StateChange<WifiState> stateChange) {
  // Check if WiFi is turning on
  if (stateChange.currentState == WifiState.enabling) {
    showLoadingIndicator();
  }
  
  // Check if WiFi has finished turning on
  if (stateChange.previousState == WifiState.enabling && 
      stateChange.currentState == WifiState.enabled) {
    hideLoadingIndicator();
    showSuccessMessage('WiFi Connected');
  }

  // Check for failed enable attempt
  if (stateChange.previousState == WifiState.enabling && 
      stateChange.currentState == WifiState.disabled) {
    showErrorMessage('Failed to enable WiFi');
  }
}

void onBluetoothStateChanged(StateChange<BluetoothState> stateChange) {
  // Track Bluetooth turning on process
  if (stateChange.currentState == BluetoothState.turningOn) {
    showProgress('Turning on Bluetooth...');
  }

  // Detect successful enable
  if (stateChange.previousState == BluetoothState.turningOn && 
      stateChange.currentState == BluetoothState.on) {
    showSuccess('Bluetooth is ready');
  }

  // Handle interrupted state changes
  if (stateChange.previousState == BluetoothState.turningOn && 
      stateChange.currentState == BluetoothState.off) {
    showError('Failed to turn on Bluetooth');
  }
}
```

See the `example` directory for a complete implementation.

## API Reference

### ConnectivityListener

*   `ConnectivityListener()`: Creates an instance of the plugin.

### Streams

*   `Stream<StateChange<WifiState>> get onWifiStateChanged`: A broadcast stream that emits `StateChange` objects containing both current and previous WiFi states.
*   `Stream<StateChange<BluetoothState>> get onBluetoothStateChanged`: A broadcast stream that emits `StateChange` objects containing both current and previous Bluetooth states.

### StateChange<T>

A class that holds both the current and previous states during a state transition:

*   `T? previousState`: The state before the change occurred. Null for the first event.
*   `T currentState`: The current state after the change.
*   `String toString()`: Returns a formatted string representation of the state change.

### WifiState

Enum representing all possible WiFi states:
*   `enabling`: WiFi is in the process of being enabled
*   `enabled`: WiFi is fully enabled and ready
*   `disabling`: WiFi is in the process of being disabled
*   `disabled`: WiFi is fully disabled
*   `unknown`: WiFi state could not be determined

### BluetoothState

Enum representing all possible Bluetooth states:
*   `turningOn`: Bluetooth adapter is in the process of turning on
*   `on`: Bluetooth is fully on and ready
*   `turningOff`: Bluetooth adapter is in the process of turning off
*   `off`: Bluetooth is fully off
*   `unknown`: Bluetooth state could not be determined

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/Prince2347X/network_settings_listener/blob/main/LICENSE) file for details.

