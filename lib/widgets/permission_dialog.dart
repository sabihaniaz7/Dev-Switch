import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/dev_settings_bridge.dart';
import 'command_box.dart';

const String kGrantCommand =
    'adb shell pm grant com.example.dev_switch android.permission.WRITE_SECURE_SETTINGS';

/// Shown when the app tries to toggle a setting but does not yet hold
/// WRITE_SECURE_SETTINGS. Explains the one-time fix in short steps.
class PermissionDialog extends StatelessWidget {
  final VoidCallback onCheckAgain;

  const PermissionDialog({super.key, required this.onCheckAgain});

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onCheckAgain,
  }) {
    return showDialog(
      context: context,
      builder: (_) => PermissionDialog(onCheckAgain: onCheckAgain),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text(
        'One-time setup',
        style: TextStyle(color: AppColors.textPrimary, fontSize: 17),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This is required once, on your PC, so the app can switch '
            'these settings directly:',
            style: TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 10),
          const _Step(number: '1', text: 'Open Developer options'),
          const _Step(number: '2', text: 'Turn on USB debugging'),
          const _Step(number: '3', text: 'Connect phone to PC, run:'),
          const SizedBox(height: 6),
          const CommandBox(command: kGrantCommand),
          const SizedBox(height: 10),
          const Text(
            'Works instantly after that. Not needed again.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
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
            DevSettingsBridge.openDeveloperOptions();
          },
          child: const Text(
            'Open settings',
            style: TextStyle(color: AppColors.accent),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onCheckAgain();
          },
          child: const Text(
            'Check again',
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

class _Step extends StatelessWidget {
  final String number;
  final String text;

  const _Step({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.only(top: 1),
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
