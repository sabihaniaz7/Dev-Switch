package com.example.dev_switch

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "dev_switch/settings"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isDeveloperOptionsEnabled" -> {
                        result.success(isDeveloperOptionsEnabled())
                    }
                    "isUsbDebuggingEnabled" -> {
                        result.success(isUsbDebuggingEnabled())
                    }
                    "isWirelessDebuggingEnabled" -> {
                        result.success(isWirelessDebuggingEnabled())
                    }
                    "hasWriteSecureSettingsPermission" -> {
                        result.success(hasWriteSecureSettingsPermission())
                    }
                    "setDeveloperOptionsEnabled" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: false
                        result.success(setDeveloperOptionsEnabled(enabled))
                    }
                    "setUsbDebuggingEnabled" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: false
                        result.success(setUsbDebuggingEnabled(enabled))
                    }
                    "setWirelessDebuggingEnabled" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: false
                        result.success(setWirelessDebuggingEnabled(enabled))
                    }
                    "openDeveloperOptions" -> {
                        openDeveloperOptions()
                        result.success(null)
                    }
                    "openWirelessDebugging" -> {
                        openWirelessDebugging()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    // Reading these values does not require any special permission on
    // most Android versions since they live in Settings.Global / .Secure
    // and are readable by any app. Writing them is what is restricted.

    private fun isDeveloperOptionsEnabled(): Boolean {
        return try {
            Settings.Global.getInt(
                contentResolver,
                Settings.Global.DEVELOPMENT_SETTINGS_ENABLED,
                0
            ) == 1
        } catch (e: Exception) {
            false
        }
    }

    private fun isUsbDebuggingEnabled(): Boolean {
        return try {
            Settings.Global.getInt(
                contentResolver,
                Settings.Global.ADB_ENABLED,
                0
            ) == 1
        } catch (e: Exception) {
            false
        }
    }

    private fun isWirelessDebuggingEnabled(): Boolean {
        // No public constant exists for this on most API levels; it is
        // exposed under a vendor-specific Settings.Global key on API 30+.
        return try {
            Settings.Global.getInt(
                contentResolver,
                "adb_wifi_enabled",
                0
            ) == 1
        } catch (e: Exception) {
            false
        }
    }

    // Direct writes require the WRITE_SECURE_SETTINGS permission, which
    // Android only lets you grant via adb (not through a normal in-app
    // runtime permission dialog):
    //
    //   adb shell pm grant com.example.dev_switch android.permission.WRITE_SECURE_SETTINGS
    //
    // Run that once per device/install. After that, the calls below work
    // directly with no settings screen involved.

    private fun hasWriteSecureSettingsPermission(): Boolean {
        return checkSelfPermission(android.Manifest.permission.WRITE_SECURE_SETTINGS) ==
            android.content.pm.PackageManager.PERMISSION_GRANTED
    }

    private fun setDeveloperOptionsEnabled(enabled: Boolean): Boolean {
        if (!hasWriteSecureSettingsPermission()) return false
        return try {
            Settings.Global.putInt(
                contentResolver,
                Settings.Global.DEVELOPMENT_SETTINGS_ENABLED,
                if (enabled) 1 else 0
            )
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun setUsbDebuggingEnabled(enabled: Boolean): Boolean {
        if (!hasWriteSecureSettingsPermission()) return false
        return try {
            Settings.Global.putInt(
                contentResolver,
                Settings.Global.ADB_ENABLED,
                if (enabled) 1 else 0
            )
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun setWirelessDebuggingEnabled(enabled: Boolean): Boolean {
        if (!hasWriteSecureSettingsPermission()) return false
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) return false
        return try {
            Settings.Global.putInt(
                contentResolver,
                "adb_wifi_enabled",
                if (enabled) 1 else 0
            )
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun openDeveloperOptions() {
        val intent = Intent(Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        try {
            startActivity(intent)
        } catch (e: Exception) {
            openAppSettingsFallback()
        }
    }

    private fun openWirelessDebugging() {
        // There's no officially documented public constant for the
        // Wireless debugging sub-screen, but AOSP's Settings app ships it
        // under this action string on API 30+. We try it first, and fall
        // back to the main Developer options screen if the device/ROM
        // doesn't expose it (some OEM skins rename or hide it).
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val intent = Intent("android.settings.WIRELESS_DEBUGGING_SETTINGS")
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            try {
                startActivity(intent)
                return
            } catch (e: Exception) {
                // Falls through to Developer options below.
            }
        }
        openDeveloperOptions()
    }

    private fun openAppSettingsFallback() {
        val intent = Intent(Settings.ACTION_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }
}