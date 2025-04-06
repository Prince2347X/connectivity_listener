package dev.Prince2347X.connectivity_listener

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.BroadcastReceiver
import android.net.wifi.WifiManager
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager // Added for newer Android versions
import android.os.Build
import android.Manifest
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** ConnectivityListenerPlugin */
class ConnectivityListenerPlugin: FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
    private lateinit var wifiEventChannel: EventChannel
    private lateinit var bluetoothEventChannel: EventChannel
    private lateinit var methodChannel: MethodChannel // Keep method channel if needed later
    private var wifiStateReceiver: BroadcastReceiver? = null
    private var bluetoothStateReceiver: BroadcastReceiver? = null
    private var applicationContext: Context? = null

    // Use BluetoothManager for newer APIs
    private val bluetoothAdapter: BluetoothAdapter? by lazy {
        val bluetoothManager = applicationContext?.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
        bluetoothManager?.adapter
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = flutterPluginBinding.applicationContext
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "connectivity_listener/method")
        wifiEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "connectivity_listener/wifi_state")
        bluetoothEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "connectivity_listener/bluetooth_state")

        methodChannel.setMethodCallHandler(this)
        wifiEventChannel.setStreamHandler(this) // Use 'this' for StreamHandler
        bluetoothEventChannel.setStreamHandler(this) // Use 'this' for StreamHandler
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        // Keep this structure if you plan to add methods later
        result.notImplemented()
    }

    // --- StreamHandler Implementation ---
    private var currentEventSink: EventChannel.EventSink? = null
    private var currentStreamType: String? = null // To differentiate between wifi/bluetooth setup

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        currentEventSink = events
        // Determine which stream is being listened to based on the channel name (passed implicitly)
        // This is a simplification; a better approach might involve arguments or separate handlers.
        // For now, we'll assume the channel name implies the type.
        // A more robust way is needed if both streams are listened to simultaneously by the same handler instance.
        // Let's create separate handlers for clarity.

        // This approach is flawed. We need separate StreamHandler instances.
        // Refactoring to use separate handlers...

        // --- Corrected Approach: Separate Stream Handlers --- 
        // We need to instantiate separate handlers for each channel.
        // The current structure with a single class implementing StreamHandler for multiple channels
        // makes it hard to manage state (like which receiver to register/unregister).
        // Let's adjust the onAttachedToEngine to set separate handlers.

        // Reverting the single handler approach. See corrected onAttachedToEngine below.
        // This onListen method will now be part of the dedicated handler classes.
    }

    override fun onCancel(arguments: Any?) {
        // This onCancel method will now be part of the dedicated handler classes.
        currentEventSink = null
    }
    // --- End StreamHandler Implementation (will be moved) ---


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = null
        methodChannel.setMethodCallHandler(null)
        wifiEventChannel.setStreamHandler(null)
        bluetoothEventChannel.setStreamHandler(null)
        // Ensure receivers are unregistered if engine detaches while listening
        unregisterWifiReceiver()
        unregisterBluetoothReceiver()
    }

    // --- Helper Methods for Receivers ---
    private fun registerWifiReceiver(events: EventChannel.EventSink) {
        if (wifiStateReceiver == null) {
            val wifiManager = applicationContext?.getSystemService(Context.WIFI_SERVICE) as? WifiManager
            // Send initial state
            events.success(wifiManager?.wifiState)

            wifiStateReceiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context, intent: Intent) {
                    if (WifiManager.WIFI_STATE_CHANGED_ACTION == intent.action) {
                        val wifiState = intent.getIntExtra(WifiManager.EXTRA_WIFI_STATE, WifiManager.WIFI_STATE_UNKNOWN)
                        events.success(wifiState)
                    }
                }
            }
            val filter = IntentFilter(WifiManager.WIFI_STATE_CHANGED_ACTION)
            applicationContext?.registerReceiver(wifiStateReceiver, filter)
        }
    }

    private fun unregisterWifiReceiver() {
        if (wifiStateReceiver != null) {
            applicationContext?.unregisterReceiver(wifiStateReceiver)
            wifiStateReceiver = null
        }
    }

    private fun registerBluetoothReceiver(events: EventChannel.EventSink) {
        if (bluetoothStateReceiver == null) {
            // Check for Bluetooth permission (especially for Android 12+)
            val hasPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                ContextCompat.checkSelfPermission(applicationContext!!, Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED
            } else {
                // Older versions might implicitly have permission or require BLUETOOTH
                ContextCompat.checkSelfPermission(applicationContext!!, Manifest.permission.BLUETOOTH) == PackageManager.PERMISSION_GRANTED
            }

            if (!hasPermission) {
                 events.error("PERMISSION_DENIED", "Bluetooth permission (BLUETOOTH_CONNECT or BLUETOOTH) is required.", null)
                 // Don't register receiver if permission is missing
                 return 
            }

            // Send initial state
            try {
                 events.success(bluetoothAdapter?.state)
            } catch (e: SecurityException) {
                 events.error("PERMISSION_ERROR", "Failed to get initial Bluetooth state due to missing permission.", e.message)
                 return
            }
           

            bluetoothStateReceiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context, intent: Intent) {
                    if (BluetoothAdapter.ACTION_STATE_CHANGED == intent.action) {
                        val bluetoothState = intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, BluetoothAdapter.ERROR)
                        // Check for ERROR state if needed
                        if (bluetoothState != BluetoothAdapter.ERROR) {
                             events.success(bluetoothState)
                        } else {
                             // Optionally send an unknown/error state back to Flutter
                             events.success(null) // Or a specific error code/enum value
                        }
                    }
                }
            }
            val filter = IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED)
            applicationContext?.registerReceiver(bluetoothStateReceiver, filter)
        }
    }

    private fun unregisterBluetoothReceiver() {
        if (bluetoothStateReceiver != null) {
            applicationContext?.unregisterReceiver(bluetoothStateReceiver)
            bluetoothStateReceiver = null
        }
    }

    // --- Corrected onAttachedToEngine with Separate Handlers ---
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = flutterPluginBinding.applicationContext
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "connectivity_listener/method")
        wifiEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "connectivity_listener/wifi_state")
        bluetoothEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "connectivity_listener/bluetooth_state")

        methodChannel.setMethodCallHandler(this) // Keep for potential future methods

        // Setup WiFi Stream Handler
        wifiEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                if (events != null) {
                    registerWifiReceiver(events)
                }
            }

            override fun onCancel(arguments: Any?) {
                unregisterWifiReceiver()
            }
        })

        // Setup Bluetooth Stream Handler
        bluetoothEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                 if (events != null) {
                    registerBluetoothReceiver(events)
                }
            }

            override fun onCancel(arguments: Any?) {
                unregisterBluetoothReceiver()
            }
        })
    }
}
