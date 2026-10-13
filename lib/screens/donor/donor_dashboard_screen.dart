import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/local_donation_repository.dart';
import '../../models/food_donation.dart';
import '../../models/pickup_request.dart';
import '../../widgets/common/brand_logo.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/donations/donation_card.dart';
import '../../widgets/donations/summary_card.dart';

// Brand palette (consistent across all screens)
const Color _green = AppColors.primaryGreen;
const Color _background = AppColors.warmBackground;
const Color _darkGreen = Color(0xFF106B49);
const Color _lightGreen = Color(0xFFE8F5EC);
const Color _textPrimary = Color(0xFF19352A);
const Color _textSecondary = Color(0xFF738178);
const Color _border = Color(0xFFE8EDE8);

class DonorDashboardScreen extends StatelessWidget {
  const DonorDashboardScreen({super.key, required this.repository});

  final FoodLinkRepository repository;

  String _greetingForNow() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour < 17) return 'Good afternoon';
    if (hour >= 17 && hour < 21) return 'Good evening';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final donor = repository.currentDonor;

        if (donor == null) {
          return Scaffold(
            backgroundColor: _background,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: _lightGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        size: 36,
                        color: _darkGreen,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Please log in to continue',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'You need an active donor session to view this dashboard.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          );
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

        final firstName = donor.fullName.trim().split(' ').first;

        return Scaffold(
          backgroundColor: _background,
          appBar: AppBar(
            backgroundColor: _background,
            foregroundColor: _textPrimary,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            centerTitle: false,
            toolbarHeight: 76,
            titleSpacing: 20,
            title: Row(
              children: [
                const BrandLogo(size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_greetingForNow()}, $firstName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${donor.donorType} donor',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: IconButton(
                  tooltip: 'Profile',
                  onPressed: () => Navigator.pushNamed(context, '/profile'),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _textPrimary,
                    fixedSize: const Size(46, 46),
                  ),
                  icon: const Icon(Icons.person_outline_rounded),
                ),
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final margin = AppTheme.horizontalMargin(width);
                final columns = AppTheme.summaryColumns(width);

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: AppTheme.contentMaxWidth(width),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      padding: EdgeInsets.fromLTRB(margin, 12, margin, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Overview section
                          _SectionTitle(
                            title: 'Overview',
                            subtitle:
                                'Your food donation activity at a glance.',
                          ),
                          const SizedBox(height: 14),
                          _SummaryGrid(
                            repository: repository,
                            columns: columns,
                          ),
                          const SizedBox(height: 24),

                          // Quick actions
                          _SectionTitle(
                            title: 'Quick actions',
                            actionLabel: 'View all',
                            onAction: () =>
                                Navigator.pushNamed(context, '/my-donations'),
                          ),
                          const SizedBox(height: 12),
                          _QuickActions(
                            repository: repository,
                            onNavigate: (route) =>
                                Navigator.pushNamed(context, route),
                          ),
                          const SizedBox(height: 24),

                          // Recent donations
                          _SectionTitle(
                            title: 'Recent donations',
                            actionLabel: 'View all',
                            onAction: () =>
                                Navigator.pushNamed(context, '/my-donations'),
                          ),
                          const SizedBox(height: 12),
                          if (recent.isEmpty)
                            EmptyState(
                              message:
                                  'You have no donations in progress yet. '
                                  'Add your first food donation to get started.',
                              actionLabel: 'Add Food Donation',
                              onAction: () => Navigator.pushNamed(
                                context,
                                '/create-donation',
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: recent.length.clamp(0, 4),
                              itemBuilder: (context, index) {
                                final donation = recent[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: DonationCard(
                                    donation: donation,
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      '/donation-details',
                                      arguments: donation.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 24),

                          // Pickup requests
                          _SectionTitle(
                            title: 'Pickup requests',
                            subtitle: 'Requests waiting for your decision.',
                            actionLabel: 'Open',
                            onAction: () => Navigator.pushNamed(
                              context,
                              '/pickup-requests',
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (pending.isEmpty)
                            const EmptyState(
                              icon: Icons.mark_email_unread_outlined,
                              message:
                                  'No pickup requests are waiting right now. '
                                  'They will appear here when NGOs request '
                                  'your food.',
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: pending.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final request = pending[index];
                                final donation = repository.donationById(
                                  request.donationId,
                                );
                                return _PendingRequestCard(
                                  request: request,
                                  foodName: donation?.foodName ?? 'Donation',
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    '/pickup-requests',
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// # SECTION TITLE (consistent with other screens)
// ============================================================
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: _green,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel!,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ),
      ],
    );
  }
}

// ============================================================
// # SUMMARY GRID (uses imported SummaryCard)
// ============================================================
class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.repository, required this.columns});

  final FoodLinkRepository repository;
  final int columns;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppTheme.itemGap,
      crossAxisSpacing: AppTheme.itemGap,
      childAspectRatio: columns >= 4 ? 1.25 : 1.15,
      children: [
        SummaryCard(
          label: 'Total Donations',
          value: '${repository.totalDonations}',
          icon: Icons.inventory_2_outlined,
          tintColor: AppColors.lightGreen,
          iconColor: AppColors.primaryGreen,
        ),
        SummaryCard(
          label: 'Available',
          value: '${repository.availableDonations}',
          icon: Icons.restaurant_outlined,
          tintColor: AppColors.softBlue,
          iconColor: AppColors.darkGreen,
        ),
        SummaryCard(
          label: 'Pickup Requests',
          value: '${repository.pendingPickupRequests}',
          icon: Icons.access_time_rounded,
          tintColor: AppColors.lightAmber,
          iconColor: AppColors.warningAmber,
        ),
        SummaryCard(
          label: 'Completed',
          value: '${repository.completedDonations}',
          icon: Icons.check_circle_rounded,
          tintColor: AppColors.lightGreen,
          iconColor: AppColors.primaryGreen,
        ),
      ],
    );
  }
}

// ============================================================
// # QUICK ACTIONS — horizontal scroll with narrow cards (~150px)
// ============================================================
class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.repository, required this.onNavigate});

  final FoodLinkRepository repository;
  final void Function(String route) onNavigate;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickActionData(
        icon: Icons.add_circle_rounded,
        label: 'Add Food\nDonation',
        color: _green,
        backgroundColor: _lightGreen,
        route: '/create-donation',
      ),
      _QuickActionData(
        icon: Icons.inventory_2_rounded,
        label: 'My\nDonations',
        color: const Color(0xFF4778C7),
        backgroundColor: const Color(0xFFEAF1FF),
        route: '/my-donations',
      ),
      _QuickActionData(
        icon: Icons.notifications_active_rounded,
        label: 'Pickup\nRequests',
        color: const Color(0xFFD58A19),
        backgroundColor: const Color(0xFFFFF3DB),
        route: '/pickup-requests',
        badgeCount: repository.pendingPickupRequests,
      ),
      _QuickActionData(
        icon: Icons.person_rounded,
        label: 'My\nProfile',
        color: _darkGreen,
        backgroundColor: _lightGreen,
        route: '/profile',
      ),
    ];

    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 150,
            child: _QuickActionCard(
              data: actions[index],
              onTap: () => onNavigate(actions[index].route),
            ),
          );
        },
      ),
    );
  }
}

class _QuickActionData {
  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;
  final String route;
  final int badgeCount;

  const _QuickActionData({
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.route,
    this.badgeCount = 0,
  });
}

// ============================================================
// # QUICK ACTION CARD
// ============================================================
class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.data, required this.onTap});

  final _QuickActionData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: data.backgroundColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(data.icon, color: data.color, size: 22),
                  ),
                  if (data.badgeCount > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFCB4A4A),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          '${data.badgeCount}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                data.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// # PENDING REQUEST CARD
// ============================================================
class _PendingRequestCard extends StatelessWidget {
  const _PendingRequestCard({
    required this.request,
    required this.foodName,
    required this.onTap,
  });

  final PickupRequest request;
  final String foodName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3DB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.pending_actions_rounded,
                  color: Color(0xFFD58A19),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
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
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
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
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD58A19).withOpacity(0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'PENDING',
                  style: TextStyle(
                    color: Color(0xFFD58A19),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
