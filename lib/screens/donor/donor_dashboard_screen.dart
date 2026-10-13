import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/local_donation_repository.dart';
import '../../models/food_donation.dart';
import '../../models/pickup_request.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/app_card.dart';
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
                    borderRadius: BorderRadius.circular(AppTheme.compactRadius),
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
                        '${_greetingForNow()}, '
                        '${donor.fullName.split(' ').first}!',
                        style: const TextStyle(
                          fontSize: 18,
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Donation summary cards
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final narrow = width < 340;

                      return GridView.extent(
                        maxCrossAxisExtent: narrow ? width : 190,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: AppTheme.itemGap,
                        crossAxisSpacing: AppTheme.itemGap,
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
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Quick actions heading
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Horizontally scrollable quick actions
                  SizedBox(
                    height: 88,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: quickActions.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        return SizedBox(width: 132, child: quickActions[index]);
                      },
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Recent donations heading
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Recent Donations',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
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
                      padding: EdgeInsets.zero,
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

                  const SizedBox(height: 18),

                  // Pending requests heading
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Pending Pickup Requests',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/pickup-requests'),
                        child: const Text('Open'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 2),

                  // Compact pending request cards
                  if (pending.isEmpty)
                    const EmptyState(
                      message: 'No pickup requests awaiting your decision.',
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: pending.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 7),
                      itemBuilder: (context, index) {
                        final request = pending[index];

                        final donation = repository.donationById(
                          request.donationId,
                        );

                        return _PendingRequestCard(
                          request: request,
                          foodName: donation?.foodName ?? 'Donation',
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

// Quick action card
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
    return AppCard(
      onTap: onTap,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Badge(
            isLabelVisible: badgeCount > 0,
            label: Text('$badgeCount'),
            backgroundColor: AppColors.errorRed,
            alignment: AlignmentDirectional.topEnd,
            child: Icon(icon, color: color, size: 25),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}

// Compact pending pickup request card
class _PendingRequestCard extends StatelessWidget {
  const _PendingRequestCard({required this.request, required this.foodName});

  final PickupRequest request;
  final String foodName;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.lightAmber,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.pending_actions_outlined,
              color: AppColors.warningAmber,
              size: 19,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  request.ngoName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$foodName • ${request.requestedQuantity} '
                  '${request.requestedUnit}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.2,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          StatusBadge(status: request.status.label),
        ],
      ),
    );
  }
}
