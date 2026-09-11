package com.example.dev_switch

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings

/**
 * Single source of truth for reading and writing the three settings.
 * Used by both MainActivity (Flutter bridge) and DevSwitchWidgetProvider
 * (home screen widget), so the cascade rule — turning Developer options
 * off also turns USB and Wireless debugging off — behaves identically
 * whether the toggle came from the app or from the widget.
 */
object DevSettingsHelper {

    fun hasPermission(context: Context): Boolean {
        return context.checkSelfPermission(android.Manifest.permission.WRITE_SECURE_SETTINGS) ==
                PackageManager.PERMISSION_GRANTED
    }

    fun isDeveloperOptionsEnabled(context: Context): Boolean = try {
        Settings.Global.getInt(
            context.contentResolver,
            Settings.Global.DEVELOPMENT_SETTINGS_ENABLED, 0
        ) == 1
    } catch (e: Exception) {
        false
    }

    fun isUsbDebuggingEnabled(context: Context): Boolean = try {
        Settings.Global.getInt(context.contentResolver, Settings.Global.ADB_ENABLED, 0) == 1
    } catch (e: Exception) {
        false
    }

    fun isWirelessDebuggingEnabled(context: Context): Boolean = try {
        Settings.Global.getInt(context.contentResolver, "adb_wifi_enabled", 0) == 1
    } catch (e: Exception) {
        false
    }

    /** Returns true if the write succeeded. Cascades USB/Wireless off when turning dev options off. */
    fun setDeveloperOptionsEnabled(context: Context, enabled: Boolean): Boolean {
        if (!hasPermission(context)) return false
        return try {
            Settings.Global.putInt(
                context.contentResolver,
                Settings.Global.DEVELOPMENT_SETTINGS_ENABLED,
                if (enabled) 1 else 0
            )
            if (!enabled) {
                if (isUsbDebuggingEnabled(context)) setUsbDebuggingEnabled(context, false)
                if (isWirelessDebuggingEnabled(context)) setWirelessDebuggingEnabled(context, false)
            }
            true
        } catch (e: Exception) {
            false
        }
    }

    /** Refuses to turn on if Developer options is off, mirroring the locked UI in-app. */
    fun setUsbDebuggingEnabled(context: Context, enabled: Boolean): Boolean {
        if (!hasPermission(context)) return false
        if (enabled && !isDeveloperOptionsEnabled(context)) return false
        return try {
            Settings.Global.putInt(
                context.contentResolver, Settings.Global.ADB_ENABLED, if (enabled) 1 else 0
            )
            true
        } catch (e: Exception) {
            false
        }
    }

    fun setWirelessDebuggingEnabled(context: Context, enabled: Boolean): Boolean {
        if (!hasPermission(context)) return false
        if (enabled && !isDeveloperOptionsEnabled(context)) return false
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) return false
        return try {
            Settings.Global.putInt(
                context.contentResolver, "adb_wifi_enabled", if (enabled) 1 else 0
            )
            true
        } catch (e: Exception) {
            false
        }
    }
}