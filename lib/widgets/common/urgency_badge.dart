import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_time_utils.dart';
import '../../models/food_donation.dart';

/// Subtle deadline-based urgency indicator.
///
/// Shows "Expiring Soon" when the safe-use deadline is within the next 24
/// hours, and "Past deadline" when it has already passed. Cancelled,
/// collected and delivered donations never show urgency.
class UrgencyBadge extends StatelessWidget {
  const UrgencyBadge({super.key, required this.donation});

  final FoodDonation donation;

  @override
  Widget build(BuildContext context) {
    final isActive =
        donation.status == DonationStatus.available ||
        donation.status == DonationStatus.reserved;

    if (!isActive) return const SizedBox.shrink();

    final deadline = donation.safeUseDeadline;
    final expiringSoon = DateTimeUtils.isExpiringSoon(deadline);
    final pastDeadline = DateTimeUtils.isPastDeadline(deadline);
    if (!expiringSoon && !pastDeadline) return const SizedBox.shrink();

    final Color foreground;
    final Color background;
    final IconData icon;
    final String label;

    if (pastDeadline) {
      foreground = AppColors.errorRed;
      background = AppColors.softRed;
      icon = Icons.event_busy_rounded;
      label = 'Past deadline';
    } else {
      foreground = AppColors.warningAmber;
      background = AppColors.lightAmber;
      icon = Icons.schedule_rounded;
      label = 'Expiring Soon';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
