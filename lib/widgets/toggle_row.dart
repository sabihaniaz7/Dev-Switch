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
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  locked && lockedReason != null ? lockedReason! : subtitle,
                  style: TextStyle(
                    color: locked ? AppColors.warning : AppColors.textSecondary,
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
          else
            Switch(
              value: enabled,
              onChanged: locked ? null : onChanged,
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
