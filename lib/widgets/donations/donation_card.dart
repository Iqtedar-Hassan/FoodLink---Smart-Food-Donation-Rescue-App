import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_time_utils.dart';
import '../../models/food_donation.dart';
import '../common/status_badge.dart';

class DonationCard extends StatelessWidget {
  const DonationCard({super.key, required this.donation, required this.onTap});

  final FoodDonation donation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.restaurant_outlined,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          donation.foodName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      StatusBadge(status: donation.status.label),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${donation.category} • ${donation.quantity} ${donation.quantityUnit}',
                    style: const TextStyle(color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Safe-use deadline: ${DateTimeUtils.formatForDisplay(donation.safeUseDeadline)}',
                    style: const TextStyle(color: AppColors.secondaryText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
