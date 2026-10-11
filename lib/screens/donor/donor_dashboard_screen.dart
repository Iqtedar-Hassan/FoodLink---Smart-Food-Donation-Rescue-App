import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/repositories/local_donation_repository.dart';
import '../../models/food_donation.dart';
import '../../models/pickup_request.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/donations/donation_card.dart';
import '../../widgets/donations/summary_card.dart';

class DonorDashboardScreen extends StatelessWidget {
  const DonorDashboardScreen({super.key, required this.repository});

  final FoodLinkRepository repository;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final donor = repository.currentDonor;
        if (donor == null) {
          return const Center(child: Text('Please log in to continue.'));
        }

        final recent =
            repository.donorDonations
                .where(
                  (donation) => donation.status != DonationStatus.cancelled,
                )
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final pending = repository.donorPickupRequests
            .where((request) => request.status == PickupRequestStatus.pending)
            .take(3)
            .toList();

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 21,
                  backgroundColor: AppColors.lightGreen,
                  child: Text(
                    donor.fullName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${donor.fullName.split(' ').first}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(
                        'Your donations are making an impact.',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pushNamed(context, '/profile'),
                  icon: const Icon(Icons.person_outline),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.2,
                    children: [
                      SummaryCard(
                        label: 'Total Donations',
                        value: '${repository.totalDonations}',
                        icon: Icons.inventory_2_outlined,
                        tintColor: AppColors.lightGreen,
                        iconColor: AppColors.primaryGreen,
                      ),
                      SummaryCard(
                        label: 'Available Donations',
                        value: '${repository.availableDonations}',
                        icon: Icons.restaurant_outlined,
                        tintColor: AppColors.softBlue,
                        iconColor: AppColors.darkGreen,
                      ),
                      SummaryCard(
                        label: 'Pending Requests',
                        value: '${repository.pendingPickupRequests}',
                        icon: Icons.access_time_rounded,
                        tintColor: AppColors.lightAmber,
                        iconColor: AppColors.warningAmber,
                      ),
                      SummaryCard(
                        label: 'Completed Donations',
                        value: '${repository.completedDonations}',
                        icon: Icons.check_circle_rounded,
                        tintColor: AppColors.lightGreen,
                        iconColor: AppColors.primaryGreen,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/create-donation'),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Create Donation'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Donations',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/my-donations'),
                        child: const Text('View all'),
                      ),
                    ],
                  ),
                  if (recent.isEmpty)
                    const EmptyState(
                      message: 'No donations published yet. Create your first donation.',
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recent.length,
                      itemBuilder: (context, index) {
                        final donation = recent[index];
                        return DonationCard(
                          donation: donation,
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/donation-details',
                            arguments: donation.id,
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pending Pickup Requests',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/pickup-requests'),
                        child: const Text('Open'),
                      ),
                    ],
                  ),
                  if (pending.isEmpty)
                    const EmptyState(
                      message: 'No pickup requests awaiting your decision.',
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pending.length,
                      itemBuilder: (context, index) {
                        final request = pending[index];
                        final donation = repository.donationById(
                          request.donationId,
                        );
                        return ListTile(
                          tileColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          leading: const Icon(
                            Icons.pending_actions_outlined,
                            color: AppColors.warningAmber,
                          ),
                          title: Text(request.ngoName),
                          subtitle: Text(
                            donation != null
                                ? '${donation.foodName} • ${request.requestedQuantity} ${request.requestedUnit}'
                                : 'Donation',
                          ),
                          trailing: StatusBadge(status: request.status.label),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
