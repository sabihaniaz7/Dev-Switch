import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/dev_settings_bridge.dart';

/// Explains that pairing (the 6-digit code / QR screen) is handled by
/// Android itself, not by this app, and offers a shortcut to it.
class WirelessPairDialog extends StatelessWidget {
  const WirelessPairDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const WirelessPairDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text(
        'Pair with a computer',
        style: TextStyle(color: AppColors.textPrimary, fontSize: 17),
      ),
      content: const Text(
        'The pairing code and QR scanner are part of Android\'s own '
        'security screen, so this app cannot show them directly. Tap '
        'below to open it, pair once, then this app can control '
        'wireless debugging normally.',
        style: TextStyle(color: AppColors.textSecondary, height: 1.4),
      ),
      actionsPadding: const EdgeInsets.only(right: 12, bottom: 8),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Close',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            DevSettingsBridge.openWirelessDebugging();
          },
          child: const Text(
            'Open pairing screen',
            style: TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
