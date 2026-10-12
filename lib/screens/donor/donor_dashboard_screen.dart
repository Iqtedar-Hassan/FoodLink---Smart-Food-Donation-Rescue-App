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

  String _greetingForNow() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour < 17) return 'Good afternoon';
    if (hour >= 17 && hour < 21) return 'Good evening';
    return 'Good night';
  }

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
                  (donation) =>
                      donation.status != DonationStatus.cancelled &&
                      donation.status != DonationStatus.delivered,
                )
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final pending = repository.donorPickupRequests
            .where((request) => request.status == PickupRequestStatus.pending)
            .take(3)
            .toList();

        final quickActions = [
          _QuickActionCard(
            icon: Icons.add_circle_outline_rounded,
            label: 'Create Donation',
            color: AppColors.primaryGreen,
            onTap: () => Navigator.pushNamed(context, '/create-donation'),
          ),
          _QuickActionCard(
            icon: Icons.inventory_2_outlined,
            label: 'My Donations',
            color: AppColors.darkGreen,
            onTap: () => Navigator.pushNamed(context, '/my-donations'),
          ),
          _QuickActionCard(
            icon: Icons.request_page_outlined,
            label: 'Pickup Requests',
            color: AppColors.warningAmber,
            badgeCount: repository.pendingPickupRequests,
            onTap: () => Navigator.pushNamed(context, '/pickup-requests'),
          ),
        ];

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.volunteer_activism_rounded,
                    color: AppColors.primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_greetingForNow()}, ${donor.fullName.split(' ').first}!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        donor.fullName,
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Profile',
                  onPressed: () => Navigator.pushNamed(context, '/profile'),
                  icon: const Icon(Icons.account_circle_outlined),
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
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final narrow = constraints.maxWidth < 360;
                      return GridView.count(
                        crossAxisCount: narrow ? 1 : 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: constraints.maxWidth < 220
                            ? 1.1
                            : narrow
                            ? 2
                            : 1.2,
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
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 440) {
                        return Column(
                          children: [
                            for (final action in quickActions) ...[
                              action,
                              if (action != quickActions.last)
                                const SizedBox(height: 10),
                            ],
                          ],
                        );
                      }
                      return Row(
                        children: [
                          for (var index = 0;
                              index < quickActions.length;
                              index++) ...[
                            if (index > 0) const SizedBox(width: 10),
                            Expanded(child: quickActions[index]),
                          ],
                        ],
                      );
                    },
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
                    EmptyState(
                      message: 'No donations published yet. Create your first donation.',
                      actionLabel: 'Create Donation',
                      onAction: () =>
                          Navigator.pushNamed(context, '/create-donation'),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recent.length.clamp(0, 3),
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
                            side: const BorderSide(color: AppColors.border),
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

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Badge(
                isLabelVisible: badgeCount > 0,
                label: Text('$badgeCount'),
                backgroundColor: AppColors.errorRed,
                alignment: AlignmentDirectional.topEnd,
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
