// One-time setup guide (from app bar)
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/command_box.dart';
import '../widgets/permission_dialog.dart';

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: const Text(
          'How this works',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPadding),
        children: const [
          _InfoCard(
            icon: Icons.admin_panel_settings_rounded,
            title: 'One-time setup, not every time',
            body:
                'Android blocks any app from changing these settings until '
                'you grant one special permission. It is a single command, '
                'run once, ever. After that every switch works instantly.',
          ),
          SizedBox(height: 14),
          _InfoCard(
            icon: Icons.terminal_rounded,
            title: 'The command',
            body:
                'Turn on USB debugging first, connect your phone to a PC, '
                'then run this in a terminal:',
            trailing: CommandBox(command: kGrantCommand),
          ),
          SizedBox(height: 14),
          _InfoCard(
            icon: Icons.lock_outline_rounded,
            title: 'Why it can\'t be automatic',
            body:
                'This is Android\'s own security design, not a limit of '
                'this app. If apps could grant themselves this power, '
                'malicious apps would abuse it to silently unlock USB '
                'debugging on any phone.',
          ),
          // SizedBox(height: 14),
          // _InfoCard(
          //   icon: Icons.link_off_rounded,
          //   title: 'Turning Developer options off',
          //   body:
          //       'USB debugging and Wireless debugging both live inside '
          //       'Developer options. Turning it off switches both of them '
          //       'off too, and they stay locked until it is back on. This '
          //       'matches how Android itself behaves.',
          // ),
          SizedBox(height: 14),
          _InfoCard(
            icon: Icons.wifi_rounded,
            title: 'Wireless debugging pairing',
            body:
                'Already paired your phone with a computer before? Then '
                'the toggle here just works, no scanning needed.\n\n'
                'Pairing with a new computer, or the very first time, '
                'needs Android\'s own pairing code screen — the scan icon '
                'next to Wireless debugging opens it directly. This app '
                'cannot generate or read that code itself, since it is '
                'part of Android\'s own security handshake.',
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Widget? trailing;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          if (trailing != null) ...[const SizedBox(height: 10), trailing!],
        ],
      ),
    );
  }
}
