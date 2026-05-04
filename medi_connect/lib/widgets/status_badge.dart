import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusType type;

  const StatusBadge({super.key, required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (type) {
      case StatusType.upcoming:
        bg = AppColors.primaryLight;
        fg = AppColors.primary;
        break;
      case StatusType.completed:
        bg = AppColors.surfaceVariant;
        fg = AppColors.textSecondary;
        break;
      case StatusType.cancelled:
        bg = const Color(0xFFFFDAD6);
        fg = AppColors.error;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

enum StatusType { upcoming, completed, cancelled }
