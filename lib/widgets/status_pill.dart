import 'package:flutter/material.dart';

import '../app_colors.dart';

class StatusPill extends StatelessWidget {
  final String status;
  final bool showIcon;

  const StatusPill({super.key, required this.status, this.showIcon = true});

  @override
  Widget build(BuildContext context) {
    final normalized = status.trim().toLowerCase();
    final config = _config(normalized);
    final label = status.trim().isEmpty ? 'Pending' : status.trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(config.icon, size: 13, color: config.color),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: config.color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _config(String status) {
    if (status.contains('complete') ||
        status.contains('success') ||
        status.contains('confirmed')) {
      return const _StatusConfig(AppColors.success, Icons.check_circle);
    }
    if (status.contains('book')) {
      return const _StatusConfig(AppColors.primaryDark, Icons.event_available);
    }
    if (status.contains('cancel') ||
        status.contains('fail') ||
        status.contains('reject')) {
      return const _StatusConfig(AppColors.error, Icons.cancel);
    }
    if (status.contains('progress') || status.contains('pending')) {
      return const _StatusConfig(AppColors.warning, Icons.hourglass_bottom);
    }
    return const _StatusConfig(AppColors.primary, Icons.temple_hindu);
  }
}

class _StatusConfig {
  final Color color;
  final IconData icon;

  const _StatusConfig(this.color, this.icon);
}
