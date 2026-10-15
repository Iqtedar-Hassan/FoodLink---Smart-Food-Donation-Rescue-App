import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/repositories/local_donation_repository.dart';
import '../../models/pickup_request.dart';
import '../../widgets/common/brand_logo.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/donations/donation_card.dart';

// ============================================================
// Dashboard design tokens
//
// Single green palette shared across the whole dashboard so the
// summary card, quick actions, recent donations, and pickup
// requests all look consistent. Tuned for HIGH CONTRAST on mobile:
// darker secondary text, stronger borders, bolder labels.
// ============================================================
const Color _primaryGreen = Color(0xFF117A50);
const Color _darkGreen = Color(0xFF0B6842);
const Color _lightGreen = Color(0xFFE6F4EB);
const Color _background = Color(0xFFF3F6F4);
const Color _surface = Colors.white;

// High-contrast text colors
const Color _textPrimary = Color(0xFF14251C);
const Color _textSecondary = Color(
  0xFF3D4E44,
); // darker than before for readability

// Slightly stronger border so white cards pop on the background
const Color _border = Color(0xFFC4D3C9);

// Badge red (only used for notification count)
const Color _redAccent = Color(0xFFCB4A4A);

// Subtle professional shadow used on every white card.
const List<BoxShadow> _cardShadow = [
  BoxShadow(color: Color(0x14323223), blurRadius: 10, offset: Offset(0, 4)),
];

class DonorDashboardScreen extends StatelessWidget {
  const DonorDashboardScreen({super.key, required this.repository});

  final FoodLinkRepository repository;

  String _greetingForNow() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final donor = repository.currentDonor;

        if (donor == null) {
          return _buildUnauthenticatedScaffold();
        }

        final recent = repository.recentDonations;

        final pending = repository.donorPickupRequests
            .where((request) => request.status == PickupRequestStatus.pending)
            .take(3)
            .toList();

        final firstName = donor.fullName.trim().split(' ').first;

        return Scaffold(
          backgroundColor: _background,
          appBar: _buildAppBar(context, firstName, donor.donorType),
          body: SafeArea(
            top: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final margin = AppTheme.horizontalMargin(width);
                final maxContent = AppTheme.contentMaxWidth(width);

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContent),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      padding: EdgeInsets.fromLTRB(margin, 16, margin, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ---------- Green summary card ----------
                          // (The old "Overview" heading above it was removed.)
                          _DonationOverviewCard(
                            total: repository.totalDonations,
                            available: repository.availableDonations,
                            pendingPickups: repository.pendingPickupRequests,
                            completed: repository.completedDonations,
                          ),
                          const SizedBox(height: 26),

                          // ---------- Quick actions (horizontal scroll) ----------
                          _SectionHeading(title: 'Quick actions'),
                          const SizedBox(height: 12),
                          _QuickActionsStrip(
                            pendingCount: repository.pendingPickupRequests,
                            onNavigate: (route) =>
                                Navigator.pushNamed(context, route),
                          ),
                          const SizedBox(height: 26),

                          // ---------- Recent donations ----------
                          _SectionHeading(
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
                              itemCount: recent.length.clamp(0, 3),
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
                          const SizedBox(height: 26),

                          // ---------- Pickup requests ----------
                          _SectionHeading(
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

  // ============================================================
  // UNAUTHENTICATED STATE
  // ============================================================
  Widget _buildUnauthenticatedScaffold() {
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

  // ============================================================
  // APP BAR
  // ============================================================
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    String firstName,
    String donorType,
  ) {
    return AppBar(
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
                  '$donorType donor',
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
              side: const BorderSide(color: _border, width: 1.2),
            ),
            icon: const Icon(Icons.person_outline_rounded),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// SECTION HEADING — title + optional subtitle + optional action link
// ============================================================
class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
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
                    fontSize: 13,
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
              foregroundColor: _primaryGreen,
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
// GREEN SUMMARY CARD
//
// Improved layout:
//  - icon + eyebrow label row (clearer identity)
//  - big white total
//  - three high-contrast translucent stat panels
//  - polished footer line with a subtle divider
// ============================================================
class _DonationOverviewCard extends StatelessWidget {
  const _DonationOverviewCard({
    required this.total,
    required this.available,
    required this.pendingPickups,
    required this.completed,
  });

  final int total;
  final int available;
  final int pendingPickups;
  final int completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primaryGreen, _darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _darkGreen.withValues(alpha: 0.25),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----- Eyebrow row: icon + label -----
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.volunteer_activism_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'DONATION OVERVIEW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ----- Big total -----
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$total',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    total == 1 ? 'Total Donation' : 'Total Donations',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ----- Three high-contrast stat panels -----
          Row(
            children: [
              Expanded(
                child: _StatPanel(label: 'Available', value: available),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatPanel(
                  label: 'Pickup Requests',
                  value: pendingPickups,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatPanel(label: 'Completed', value: completed),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ----- Divider + footer line -----
          Divider(
            color: Colors.white.withValues(alpha: 0.28),
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.favorite_rounded, color: Colors.white, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Every donation helps feed someone in need. Keep it up!',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// STAT PANEL — one of the three mini panels inside the green card
// High contrast: near-solid white text, stronger border.
// ============================================================
class _StatPanel extends StatelessWidget {
  const _StatPanel({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.38)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// QUICK ACTIONS — ONE horizontal scrollable row (mobile + tablet).
//
// All buttons share the same green palette as Recent Donations:
// white card, light-green icon tile, deep-green icon — consistent.
// ============================================================
class _QuickActionsStrip extends StatelessWidget {
  const _QuickActionsStrip({
    required this.pendingCount,
    required this.onNavigate,
  });

  final int pendingCount;
  final void Function(String route) onNavigate;

  static const double _stripHeight = 116;

  @override
  Widget build(BuildContext context) {
    final actions = [
      const _QuickActionData(
        icon: Icons.add_circle_rounded,
        label: 'Add Donation',
        route: '/create-donation',
      ),
      const _QuickActionData(
        icon: Icons.inventory_2_rounded,
        label: 'My Donations',
        route: '/my-donations',
      ),
      _QuickActionData(
        icon: Icons.notifications_active_rounded,
        label: 'Pickup Requests',
        route: '/pickup-requests',
        badgeCount: pendingCount,
      ),
      const _QuickActionData(
        icon: Icons.person_rounded,
        label: 'My Profile',
        route: '/profile',
      ),
    ];

    return SizedBox(
      height: _stripHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.zero,
        itemCount: actions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final data = actions[index];
          return _QuickActionCard(
            data: data,
            onTap: () => onNavigate(data.route),
          );
        },
      ),
    );
  }
}

class _QuickActionData {
  final IconData icon;
  final String label;
  final String route;
  final int badgeCount;

  const _QuickActionData({
    required this.icon,
    required this.label,
    required this.route,
    this.badgeCount = 0,
  });
}

// ============================================================
// QUICK ACTION CARD — fixed width inside the horizontal strip.
// Same visual language as the Recent Donations cards:
// white surface, visible border, light-green icon tile,
// deep-green icon, bold dark label.
// ============================================================
class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.data, required this.onTap});

  final _QuickActionData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 152,
      child: Material(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _border, width: 1.2),
              boxShadow: _cardShadow,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: _lightGreen,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(data.icon, color: _primaryGreen, size: 24),
                    ),
                    if (data.badgeCount > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: _redAccent,
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
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PENDING REQUEST CARD — now matches the Recent Donations palette
// (white surface, light-green icon tile, deep-green icon/badge)
// so the whole dashboard feels consistent.
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
      color: _surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border, width: 1.2),
            boxShadow: _cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.pending_actions_rounded,
                  color: _primaryGreen,
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
                        fontSize: 15,
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
                        fontSize: 12,
                        color: _textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _primaryGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'PENDING',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
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
