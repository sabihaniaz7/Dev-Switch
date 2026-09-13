import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final bool loading;
  final bool locked;
  final String? lockedReason;
  final VoidCallback? onExtraTap;
  final IconData? extraIcon;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onLockedTap;

  const ToggleRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.loading,
    required this.onChanged,
    this.locked = false,
    this.lockedReason,
    this.onExtraTap,
    this.extraIcon,
    this.onLockedTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: enabled
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: enabled ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                // Always shows the plain subtitle. The locked reason is
                // surfaced only when the user actually tries to toggle
                // it (see onLockedTap), not just because Developer
                // options happens to be off right now.
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (onExtraTap != null && extraIcon != null && enabled) ...[
            InkWell(
              onTap: onExtraTap,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(extraIcon, size: 18, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 4),
          ],
          if (loading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          else if (locked)
            // The switch itself stays visually dimmed/disabled, but a
            // GestureDetector on top catches the tap (IgnorePointer stops
            // the disabled Switch from swallowing it first) so tapping a
            // locked toggle can still respond with a message.
            GestureDetector(
              onTap: onLockedTap,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.5,
                  child: Switch(
                    value: enabled,
                    onChanged: null,
                    activeThumbColor: AppColors.headerEnd,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.25),
                    inactiveThumbColor: AppColors.textSecondary,
                    inactiveTrackColor: AppColors.background,
                  ),
                ),
              ),
            )
          else
            Switch(
              value: enabled,
              onChanged: onChanged,
              activeThumbColor: AppColors.headerEnd,
              activeTrackColor: AppColors.primary.withValues(alpha: 0.25),
              inactiveThumbColor: AppColors.textSecondary,
              inactiveTrackColor: AppColors.background,
            ),
        ],
      ),
    );
  }
}
