import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'Pending':
      case 'Reserved':
        color = AppColors.warningAmber;
        break;
      case 'Approved':
      case 'Available':
      case 'Completed':
        color = AppColors.primaryGreen;
        break;
      case 'Collected':
      case 'Delivered':
        color = AppColors.darkGreen;
        break;
      case 'Rejected':
        color = AppColors.errorRed;
        break;
      case 'Cancelled':
        color = AppColors.secondaryText;
        break;
      default:
        color = AppColors.primaryGreen;
    }

    // AnimatedContainer smoothly transitions the color when a status changes.
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.compactRadius),
      ),
      child: Text(
        status,
        maxLines: 1,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
