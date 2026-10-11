import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'Available':
        color = AppColors.primaryGreen;
        break;
      case 'Reserved':
        color = AppColors.warningAmber;
        break;
      case 'Collected':
      case 'Delivered':
        color = AppColors.darkGreen;
        break;
      case 'Cancelled':
      case 'Rejected':
        color = AppColors.errorRed;
        break;
      default:
        color = AppColors.primaryGreen;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
