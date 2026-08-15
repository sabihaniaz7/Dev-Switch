// Main screen: header + 3 toggles
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/dev_settings_bridge.dart';
import '../widgets/toggle_row.dart';
import '../widgets/permission_dialog.dart';
import 'instruction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _loading = true;
  bool _hasPermission = false;
  bool _devOptionsOn = false;
  bool _usbDebugOn = false;
  bool _wirelessDebugOn = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshStatus();
    }
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

  Future<bool> _guardPermission() async {
    final granted = await DevSettingsBridge.hasWriteSecureSettingsPermission();
    if (granted != _hasPermission && mounted) {
      setState(() => _hasPermission = granted);
    }
    if (granted) return true;
    if (mounted) {
      PermissionDialog.show(context, onCheckAgain: _refreshStatus);
    }
    return false;
  }

  Future<void> _toggleDeveloperOptions(bool value) async {
    if (!await _guardPermission()) return;
    setState(() => _busy = true);
    final ok = await DevSettingsBridge.setDeveloperOptionsEnabled(value);
    if (ok) {
      setState(() => _devOptionsOn = value);
      // Turning Developer options off cascades: USB and Wireless
      // debugging live inside it, so Android turns them off too.
      // Mirror that here instead of leaving stale "on" switches.
      if (!value) {
        if (_usbDebugOn) {
          await DevSettingsBridge.setUsbDebuggingEnabled(false);
        }
        if (_wirelessDebugOn) {
          await DevSettingsBridge.setWirelessDebuggingEnabled(false);
        }
        setState(() {
          _usbDebugOn = false;
          _wirelessDebugOn = false;
        });
      }
    } else {
      _showFailureSnack();
    }
    setState(() => _busy = false);
  }

  Future<void> _toggleUsbDebugging(bool value) async {
    if (!_devOptionsOn) return; // locked in the UI, extra guard here
    if (!await _guardPermission()) return;
    setState(() => _busy = true);
    final ok = await DevSettingsBridge.setUsbDebuggingEnabled(value);
    if (ok) setState(() => _usbDebugOn = value);
    if (!ok) _showFailureSnack();
    setState(() => _busy = false);
  }

  Future<void> _toggleWirelessDebugging(bool value) async {
    if (!_devOptionsOn) return;
    if (!await _guardPermission()) return;
    setState(() => _busy = true);
    final ok = await DevSettingsBridge.setWirelessDebuggingEnabled(value);
    if (ok) setState(() => _wirelessDebugOn = value);
    if (!ok) _showFailureSnack();
    setState(() => _busy = false);
  }

  void _showFailureSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not change that setting.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: _refreshStatus,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  children: [
                    ToggleRow(
                      icon: Icons.developer_mode_rounded,
                      title: 'Developer options',
                      subtitle: 'Enable Developer settings',
                      enabled: _devOptionsOn,
                      loading: _loading || _busy,
                      onChanged: _toggleDeveloperOptions,
                    ),
                    const SizedBox(height: 12),
                    ToggleRow(
                      icon: Icons.usb_rounded,
                      title: 'USB debugging',
                      subtitle: 'Debug over a USB cable',
                      enabled: _usbDebugOn,
                      loading: _loading || _busy,
                      locked: !_devOptionsOn,
                      lockedReason: 'Turn on Developer options first',
                      onChanged: _toggleUsbDebugging,
                    ),
                    const SizedBox(height: 12),
                    ToggleRow(
                      icon: Icons.wifi_rounded,
                      title: 'Wireless debugging',
                      subtitle: 'Debug over Wi-Fi',
                      enabled: _wirelessDebugOn,
                      loading: _loading || _busy,
                      locked: !_devOptionsOn,
                      lockedReason: 'Turn on Developer options first',
                      extraIcon: Icons.qr_code_scanner_rounded,
                      onExtraTap: () =>
                          DevSettingsBridge.openWirelessDebugging(),
                      onChanged: _toggleWirelessDebugging,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // Dynamic top height of status bar/notch
    final double topPadding = MediaQuery.of(context).padding.top;
    return ClipPath(
      clipper: _HeaderClipper(),
      child: Container(
        width: double.infinity,
        // Combine status bar height + custom top padding (20)
        padding: EdgeInsets.fromLTRB(20, 20 + topPadding, 20, 46),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.headerStart, AppColors.headerEnd],
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  const Text(
                    'Dev Switch',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _hasPermission
                        ? 'Ready to switch'
                        : 'Setup needed - Check Instructions',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                _HeaderIconButton(
                  icon: Icons.info_outline,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InstructionsScreen(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _HeaderIconButton(
                  icon: Icons.refresh_rounded,
                  onTap: _refreshStatus,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Cuts an asymmetric curve into the bottom of the header: mostly
/// straight across, sweeping down into a deeper curve on the right side,
/// echoing the reference screen's swoop without reproducing it exactly.
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width * 0.4,
      size.height,
      size.width * 0.72,
      size.height - 22,
    );
    path.quadraticBezierTo(
      size.width * 0.92,
      size.height - 48,
      size.width,
      size.height - 20,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: Colors.white, size: 19),
        onPressed: onTap,
      ),
    );
  }
}
