# connectivity_listener

A Flutter plugin for Android to listen for WiFi and Bluetooth connectivity state changes.

[![pub version](https://img.shields.io/pub/v/connectivity_listener.svg)](https://pub.dev/packages/connectivity_listener)
[![likes](https://img.shields.io/pub/likes/connectivity_listener)](https://pub.dev/packages/connectivity_listener)
[![popularity](https://img.shields.io/pub/popularity/connectivity_listener)](https://pub.dev/packages/connectivity_listener)
[![pub points](https://img.shields.io/pub/points/connectivity_listener)](https://pub.dev/packages/connectivity_listener)

## Features

*   Provides streams to monitor changes in WiFi state (enabled, disabled, unknown).
*   Provides streams to monitor changes in Bluetooth state (on, off, unknown).
*   Android only implementation.

## Getting Started

This plugin focuses solely on the Android platform.

### Prerequisites

*   Flutter SDK
*   Android development environment

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  connectivity_listener: ^0.0.1 # Use the latest version
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
import 'package:connectivity_listener/connectivity_listener.dart';
import 'package:connectivity_listener/connectivity_listener_platform_interface.dart'; // For enums
import 'dart:async';
```

Create an instance of the plugin and listen to the streams:

```dart
final _connectivityListener = ConnectivityListener();
late StreamSubscription<WifiState> _wifiSubscription;
late StreamSubscription<BluetoothState> _bluetoothSubscription;

WifiState currentWifiState = WifiState.unknown;
BluetoothState currentBluetoothState = BluetoothState.unknown;

void startListening() {
  _wifiSubscription = _connectivityListener.onWifiStateChanged.listen((WifiState state) {
    print("WiFi state changed: ${state.name}");
    setState(() {
      currentWifiState = state;
    });
  }, onError: (error) {
    print("Error listening to WiFi state: $error");
  });

  _bluetoothSubscription = _connectivityListener.onBluetoothStateChanged.listen((BluetoothState state) {
    print("Bluetooth state changed: ${state.name}");
    setState(() {
      currentBluetoothState = state;
    });
  }, onError: (error) {
    print("Error listening to Bluetooth state: $error");
    // Handle potential permission errors
    if (error is PlatformException && error.code == 'PERMISSION_DENIED') {
       print('BLUETOOTH_CONNECT permission denied. Please request it.');
       // Implement runtime permission request logic here
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

See the `example` directory for a more complete implementation.

## API Reference

*   `ConnectivityListener()`: Creates an instance of the plugin.
*   `Stream<WifiState> get onWifiStateChanged`: A broadcast stream that emits `WifiState` enum values (`enabled`, `disabled`, `unknown`) whenever the device's WiFi state changes.
*   `Stream<BluetoothState> get onBluetoothStateChanged`: A broadcast stream that emits `BluetoothState` enum values (`on`, `off`, `unknown`) whenever the device's Bluetooth adapter state changes.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

