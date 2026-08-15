import 'package:flutter/services.dart';

/// Talks to the native Android side over a MethodChannel.
/// See android/app/.../MainActivity.kt for the implementation of each call.
class DevSettingsBridge {
  static const _channel = MethodChannel('dev_switch/settings');

  static Future<bool> hasWriteSecureSettingsPermission() async {
    try {
      return await _channel.invokeMethod<bool>(
            'hasWriteSecureSettingsPermission',
          ) ??
          false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isDeveloperOptionsEnabled() async {
    try {
      return await _channel.invokeMethod<bool>('isDeveloperOptionsEnabled') ??
          false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isUsbDebuggingEnabled() async {
    try {
      return await _channel.invokeMethod<bool>('isUsbDebuggingEnabled') ??
          false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isWirelessDebuggingEnabled() async {
    try {
      return await _channel.invokeMethod<bool>('isWirelessDebuggingEnabled') ??
          false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> setDeveloperOptionsEnabled(bool enabled) async {
    try {
      return await _channel.invokeMethod<bool>('setDeveloperOptionsEnabled', {
            'enabled': enabled,
          }) ??
          false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> setUsbDebuggingEnabled(bool enabled) async {
    try {
      return await _channel.invokeMethod<bool>('setUsbDebuggingEnabled', {
            'enabled': enabled,
          }) ??
          false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> setWirelessDebuggingEnabled(bool enabled) async {
    try {
      return await _channel.invokeMethod<bool>('setWirelessDebuggingEnabled', {
            'enabled': enabled,
          }) ??
          false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> openDeveloperOptions() async {
    await _channel.invokeMethod('openDeveloperOptions');
  }

  /// Opens the system's wireless debugging screen, where the built-in
  /// pairing code / QR flow lives. A third-party app cannot generate or
  /// scan that pairing session itself, since it is part of Android's
  /// own security handshake between device and computer.
  static Future<void> openWirelessDebugging() async {
    await _channel.invokeMethod('openWirelessDebugging');
  }
}
