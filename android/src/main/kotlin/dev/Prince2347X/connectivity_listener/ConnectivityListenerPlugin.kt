package dev.Prince2347X.connectivity_listener

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.BroadcastReceiver
import android.net.wifi.WifiManager
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
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
class ConnectivityListenerPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var wifiEventChannel: EventChannel
    private lateinit var bluetoothEventChannel: EventChannel
    private var applicationContext: Context? = null
    
    // Track current states
    private var currentWifiState: Int = WifiManager.WIFI_STATE_UNKNOWN
    private var currentBluetoothState: Int = BluetoothAdapter.ERROR

    private var wifiStateReceiver: BroadcastReceiver? = null
    private var bluetoothStateReceiver: BroadcastReceiver? = null

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

        // Setup WiFi Stream Handler with state tracking
        wifiEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            private var eventSink: EventChannel.EventSink? = null

            override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
                if (sink != null) {
                    eventSink = sink
                    registerWifiReceiver(sink)
                }
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
                unregisterWifiReceiver()
            }
        })

        // Setup Bluetooth Stream Handler with state tracking
        bluetoothEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            private var eventSink: EventChannel.EventSink? = null

            override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
                if (sink != null) {
                    eventSink = sink
                    registerBluetoothReceiver(sink)
                }
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
                unregisterBluetoothReceiver()
            }
        })
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        result.notImplemented()
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = null
        methodChannel.setMethodCallHandler(null)
        wifiEventChannel.setStreamHandler(null)
        bluetoothEventChannel.setStreamHandler(null)
        unregisterWifiReceiver()
        unregisterBluetoothReceiver()
    }

    private fun registerWifiReceiver(events: EventChannel.EventSink) {
        if (wifiStateReceiver == null) {
            val wifiManager = applicationContext?.getSystemService(Context.WIFI_SERVICE) as? WifiManager
            // Get initial state
            currentWifiState = wifiManager?.wifiState ?: WifiManager.WIFI_STATE_UNKNOWN
            // Send initial state with null as previous state
            events.success(mapOf(
                "previousState" to null,
                "currentState" to currentWifiState
            ))

            wifiStateReceiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context, intent: Intent) {
                    if (WifiManager.WIFI_STATE_CHANGED_ACTION == intent.action) {
                        val previousState = currentWifiState
                        val newState = intent.getIntExtra(WifiManager.EXTRA_WIFI_STATE, WifiManager.WIFI_STATE_UNKNOWN)
                        currentWifiState = newState
                        events.success(mapOf(
                            "previousState" to previousState,
                            "currentState" to newState
                        ))
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
            // Check for Bluetooth permission
            val hasPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                ContextCompat.checkSelfPermission(applicationContext!!, Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED
            } else {
                ContextCompat.checkSelfPermission(applicationContext!!, Manifest.permission.BLUETOOTH) == PackageManager.PERMISSION_GRANTED
            }

            if (!hasPermission) {
                events.error("PERMISSION_DENIED", "Bluetooth permission (BLUETOOTH_CONNECT or BLUETOOTH) is required.", null)
                return
            }

            try {
                // Get initial state
                currentBluetoothState = bluetoothAdapter?.state ?: BluetoothAdapter.ERROR
                // Send initial state with null as previous state
                events.success(mapOf(
                    "previousState" to null,
                    "currentState" to currentBluetoothState
                ))
            } catch (e: SecurityException) {
                events.error("PERMISSION_ERROR", "Failed to get initial Bluetooth state due to missing permission.", e.message)
                return
            }

            bluetoothStateReceiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context, intent: Intent) {
                    if (BluetoothAdapter.ACTION_STATE_CHANGED == intent.action) {
                        val previousState = currentBluetoothState
                        val newState = intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, BluetoothAdapter.ERROR)
                        currentBluetoothState = newState
                        if (newState != BluetoothAdapter.ERROR) {
                            events.success(mapOf(
                                "previousState" to previousState,
                                "currentState" to newState
                            ))
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
}
