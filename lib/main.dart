import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const DevToggleApp());
}

class DevToggleApp extends StatelessWidget {
  const DevToggleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dev Switch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

class AppColors {
  static const background = Color(0xFF21222D);
  static const accent = Color(0xFF958CE8);
  static const accentLight = Color(0xFFACD1FD);
  static const muted = Color(0xFFDBDBE5);
  static const cardBackground = Color(0xFF2A2B38);
  static const cardBorder = Color(0xFF3A3B4A);
}

// Platform channel used to talk to the native Android side.
// See android/app/src/main/kotlin/.../MainActivity.kt for the handlers.
class DevSettingsBridge {
  static const _channel = MethodChannel('dev_switch/settings');

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

  static Future<void> openWirelessDebugging() async {
    await _channel.invokeMethod('openWirelessDebugging');
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  bool _hasPermission = false;
  bool _devOptionsOn = false;
  bool _usbDebugOn = false;
  bool _wirelessDebugOn = false;
  // Prevents overlapping toggles / duplicate taps while a write is in flight.
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  Future<void> _refreshStatus() async {
    setState(() => _loading = true);
    final permission =
        await DevSettingsBridge.hasWriteSecureSettingsPermission();
    final devOptions = await DevSettingsBridge.isDeveloperOptionsEnabled();
    final usb = await DevSettingsBridge.isUsbDebuggingEnabled();
    final wireless = await DevSettingsBridge.isWirelessDebuggingEnabled();
    if (!mounted) return;
    setState(() {
      _hasPermission = permission;
      _devOptionsOn = devOptions;
      _usbDebugOn = usb;
      _wirelessDebugOn = wireless;
      _loading = false;
    });
  }

  Future<void> _toggleDeveloperOptions(bool value) async {
    if (!await _guardPermission()) return;
    setState(() => _busy = true);
    final ok = await DevSettingsBridge.setDeveloperOptionsEnabled(value);
    if (ok) setState(() => _devOptionsOn = value);
    if (!ok) _showFailureSnack();
    setState(() => _busy = false);
  }

  Future<void> _toggleUsbDebugging(bool value) async {
    if (!await _guardPermission()) return;
    setState(() => _busy = true);
    final ok = await DevSettingsBridge.setUsbDebuggingEnabled(value);
    if (ok) setState(() => _usbDebugOn = value);
    if (!ok) _showFailureSnack();
    setState(() => _busy = false);
  }

  Future<void> _toggleWirelessDebugging(bool value) async {
    if (!await _guardPermission()) return;
    setState(() => _busy = true);
    final ok = await DevSettingsBridge.setWirelessDebuggingEnabled(value);
    if (ok) setState(() => _wirelessDebugOn = value);
    if (!ok) _showFailureSnack();
    setState(() => _busy = false);
  }

  Future<bool> _guardPermission() async {
    if (_hasPermission) return true;
    _showPermissionDialog();
    return false;
  }

  void _showFailureSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not change that setting.')),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'One-time setup required',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'To switch these settings directly, this app needs the '
          'WRITE_SECURE_SETTINGS permission. Android only allows granting '
          'this over adb, once per install:\n\n'
          'adb shell pm grant com.example.dev_switch '
          'android.permission.WRITE_SECURE_SETTINGS\n\n'
          'After running that command, reopen the app and the switches '
          'will work directly, with no settings screen involved.',
          style: TextStyle(color: AppColors.muted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Got it',
              style: TextStyle(color: AppColors.accentLight),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _refreshStatus();
            },
            child: const Text(
              'I already ran it',
              style: TextStyle(color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.cardBackground,
          onRefresh: _refreshStatus,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            children: [
              _buildHeader(),
              const SizedBox(height: 28),
              _StatusCard(
                icon: Icons.developer_mode_rounded,
                title: 'Developer options',
                subtitle: 'Master switch for all developer tools',
                enabled: _devOptionsOn,
                loading: _loading || _busy,
                onChanged: _toggleDeveloperOptions,
              ),
              const SizedBox(height: 14),
              _StatusCard(
                icon: Icons.usb_rounded,
                title: 'USB debugging',
                subtitle: 'Debug this device over a USB cable',
                enabled: _usbDebugOn,
                loading: _loading || _busy,
                locked: !_devOptionsOn,
                onChanged: _toggleUsbDebugging,
              ),
              const SizedBox(height: 14),
              _StatusCard(
                icon: Icons.wifi_tethering_rounded,
                title: 'Wireless debugging',
                subtitle: 'Debug this device over Wi-Fi',
                enabled: _wirelessDebugOn,
                loading: _loading || _busy,
                locked: !_devOptionsOn,
                onChanged: _toggleWirelessDebugging,
              ),
              const SizedBox(height: 28),
              _buildInfoNote(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dev Switch',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage debugging settings',
                style: TextStyle(
                  color: AppColors.muted.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.accentLight,
              size: 20,
            ),
            onPressed: _refreshStatus,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.accentLight,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _hasPermission
                  ? 'WRITE_SECURE_SETTINGS is granted. Switches below apply '
                        'directly, no settings screen involved.'
                  : 'These switches need the WRITE_SECURE_SETTINGS permission, '
                        'granted once via adb. Tap a switch to see the command.',
              style: TextStyle(
                color: AppColors.muted.withValues(alpha: 0.75),
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final bool loading;
  final bool locked;
  final ValueChanged<bool> onChanged;

  const _StatusCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.loading,
    required this.onChanged,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: enabled
                ? AppColors.accent.withValues(alpha: 0.5)
                : AppColors.cardBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: enabled
                    ? AppColors.accent.withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: enabled ? AppColors.accent : AppColors.muted,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    locked ? 'Requires developer options' : subtitle,
                    style: TextStyle(
                      color: AppColors.muted.withValues(alpha: 0.6),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (loading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accentLight,
                ),
              )
            else
              Switch(
                value: enabled,
                onChanged: onChanged,
                activeThumbColor: AppColors.accent,
                activeTrackColor: AppColors.accent.withValues(alpha: 0.35),
                inactiveThumbColor: AppColors.muted,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
              ),
          ],
        ),
      ),
    );
  }
}
