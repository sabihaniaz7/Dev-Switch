package com.example.dev_switch

import android.content.Intent
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
                    "isDeveloperOptionsEnabled" ->
                        result.success(DevSettingsHelper.isDeveloperOptionsEnabled(this))
                    "isUsbDebuggingEnabled" ->
                        result.success(DevSettingsHelper.isUsbDebuggingEnabled(this))
                    "isWirelessDebuggingEnabled" ->
                        result.success(DevSettingsHelper.isWirelessDebuggingEnabled(this))
                    "hasWriteSecureSettingsPermission" ->
                        result.success(DevSettingsHelper.hasPermission(this))
                    "setDeveloperOptionsEnabled" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: false
                        val ok = DevSettingsHelper.setDeveloperOptionsEnabled(this, enabled)
                        if (ok) DevSwitchWidgetProvider.refreshAll(this)
                        result.success(ok)
                    }
                    "setUsbDebuggingEnabled" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: false
                        val ok = DevSettingsHelper.setUsbDebuggingEnabled(this, enabled)
                        if (ok) DevSwitchWidgetProvider.refreshAll(this)
                        result.success(ok)
                    }
                    "setWirelessDebuggingEnabled" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: false
                        val ok = DevSettingsHelper.setWirelessDebuggingEnabled(this, enabled)
                        if (ok) DevSwitchWidgetProvider.refreshAll(this)
                        result.success(ok)
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

    private fun openDeveloperOptions() {
        val intent = Intent(Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        try {
            startActivity(intent)
        } catch (e: Exception) {
            val fallback = Intent(Settings.ACTION_SETTINGS)
            fallback.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(fallback)
        }
    }

    private fun openWirelessDebugging() {
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
}