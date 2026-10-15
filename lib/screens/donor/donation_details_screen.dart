import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_time_utils.dart';
import '../../data/repositories/local_donation_repository.dart';
import '../../models/food_donation.dart';
import '../../models/pickup_request.dart';
import '../../widgets/common/urgency_badge.dart';

// Brand palette (consistent across all screens)
const Color _green = AppColors.primaryGreen;
const Color _background = AppColors.warmBackground;
const Color _darkGreen = Color(0xFF106B49);
const Color _lightGreen = Color(0xFFE8F5EC);
const Color _textPrimary = Color(0xFF19352A);
const Color _textSecondary = Color(0xFF738178);
const Color _border = Color(0xFFE8EDE8);
const Color _dangerRed = Color(0xFFCB4A4A);

// Status color map
const Map<String, Color> _statusColors = {
  'Available': Color(0xFF19845A),
  'Reserved': Color(0xFF4778C7),
  'Collected': Color(0xFFD58A19),
  'Delivered': Color(0xFF0E6B47),
  'Cancelled': Color(0xFFCB4A4A),
};

class DonationDetailsScreen extends StatelessWidget {
  const DonationDetailsScreen({
    super.key,
    required this.repository,
    required this.donationId,
  });

  final FoodLinkRepository repository;
  final String donationId;

  Future<void> _confirmCancel(
    BuildContext context,
    FoodDonation donation,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _ConfirmDialog(
        title: 'Cancel donation?',
        body:
            'This will cancel the donation and any of its pending pickup '
            'requests. This action cannot be undone.',
        icon: Icons.cancel_outlined,
        iconColor: _dangerRed,
        confirmLabel: 'Yes, cancel',
        confirmColor: _dangerRed,
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      repository.cancelDonation(donation.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('Donation cancelled successfully.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      Navigator.pop(context);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_friendlyError(error)),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
  }

  static String _friendlyError(Object error) {
    return error.toString().replaceFirst('Bad state: ', '');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final donation = repository.donationById(donationId);

        if (donation == null) {
          return Scaffold(
            backgroundColor: _background,
            appBar: AppBar(
              backgroundColor: _background,
              foregroundColor: _textPrimary,
              elevation: 0,
              title: const Text('Donation Details'),
            ),
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
                        Icons.inventory_2_outlined,
                        size: 36,
                        color: _darkGreen,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Donation not available',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'This donation is no longer available.',
                      style: TextStyle(color: _textSecondary, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final relatedRequests = repository.requestsForDonation(donation.id);
        final requestPreview = relatedRequests.take(3).toList();
        final canCancel =
            donation.status == DonationStatus.available ||
            donation.status == DonationStatus.reserved;
        final canEdit =
            canCancel &&
            !DateTimeUtils.isPastDeadline(donation.safeUseDeadline);

        return Scaffold(
          backgroundColor: _background,
          appBar: AppBar(
            backgroundColor: _background,
            foregroundColor: _textPrimary,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: false,
            toolbarHeight: 64,
            titleSpacing: 20,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Flexible(
                  child: Text(
                    'Donation Details',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: _textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: AppTheme.contentMaxWidth(
                    MediaQuery.sizeOf(context).width,
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero header
                      _HeroHeader(donation: donation),
                      const SizedBox(height: 20),

                      // Section 1: Food information
                      const _SectionHeader(
                        number: '1',
                        title: 'Food information',
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(
                        rows: [
                          _InfoRow(
                            icon: Icons.category_outlined,
                            label: 'Category',
                            value: donation.category,
                          ),
                          _InfoRow(
                            icon: Icons.scale_outlined,
                            label: 'Quantity',
                            value:
                                '${donation.quantity} ${donation.quantityUnit}',
                          ),
                          _InfoRow(
                            icon: Icons.schedule_outlined,
                            label: 'Created',
                            value: DateTimeUtils.formatForDisplay(
                              donation.createdAt,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Section 2: Deadline and pickup
                      const _SectionHeader(
                        number: '2',
                        title: 'Deadline and pickup',
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(
                        highlight: DateTimeUtils.isExpiringSoon(
                          donation.safeUseDeadline,
                        ),
                        rows: [
                          _InfoRow(
                            icon: Icons.event_available_outlined,
                            label: 'Safe-use deadline',
                            value:
                                '${DateTimeUtils.formatForDisplay(donation.safeUseDeadline)} '
                                '• ${DateTimeUtils.timeLeftLabel(donation.safeUseDeadline)}',
                          ),
                          _InfoRow(
                            icon: Icons.access_time_outlined,
                            label: 'Pickup window',
                            value:
                                '${DateTimeUtils.formatForDisplay(donation.pickupStart)} '
                                '- ${DateTimeUtils.formatForDisplay(donation.pickupEnd)}',
                          ),
                          _InfoRow(
                            icon: Icons.location_on_outlined,
                            label: 'Pickup area',
                            value: donation.pickupArea,
                          ),
                          _InfoRow(
                            icon: Icons.home_outlined,
                            label: 'Pickup address',
                            value: donation.pickupAddress,
                          ),
                          if (donation.notes.isNotEmpty)
                            _InfoRow(
                              icon: Icons.sticky_note_2_outlined,
                              label: 'Notes',
                              value: donation.notes,
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Section 3: Pickup requests
                      _SectionHeader(
                        number: '3',
                        title: 'Pickup requests',
                        subtitle: relatedRequests.isEmpty
                            ? null
                            : '${relatedRequests.length} '
                                  '${relatedRequests.length == 1 ? 'request' : 'requests'} '
                                  'for this donation',
                        actionLabel: relatedRequests.isNotEmpty
                            ? relatedRequests.length > requestPreview.length
                                  ? 'View all'
                                  : 'Manage'
                            : null,
                        onAction: relatedRequests.isNotEmpty
                            ? () => Navigator.pushNamed(
                                context,
                                '/pickup-requests',
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      if (relatedRequests.isEmpty)
                        _EmptyRequestsCard(
                          isCancelled:
                              donation.status == DonationStatus.cancelled,
                        )
                      else
                        ...requestPreview.map(
                          (request) => _RequestSummaryTile(
                            request: request,
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/pickup-requests',
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Actions
                      if (canEdit || canCancel)
                        Column(
                          children: [
                            _GradientButton(
                              label: canEdit
                                  ? 'Edit Donation'
                                  : 'Editing locked',
                              icon: Icons.edit_outlined,
                              onTap: canEdit
                                  ? () => Navigator.pushNamed(
                                      context,
                                      '/create-donation',
                                      arguments: {'donationId': donation.id},
                                    )
                                  : () {},
                              enabled: canEdit,
                            ),
                            const SizedBox(height: 10),
                            _OutlineActionButton(
                              label: 'Cancel Donation',
                              icon: Icons.cancel_outlined,
                              color: _dangerRed,
                              onTap: canCancel
                                  ? () => _confirmCancel(context, donation)
                                  : () {},
                              enabled: canCancel,
                            ),
                          ],
                        )
                      else
                        _LockedBanner(statusLabel: donation.status.label),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// HERO HEADER (food name + status + urgency)
// ============================================================
class _HeroHeader extends StatelessWidget {
  final FoodDonation donation;
  const _HeroHeader({required this.donation});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColors[donation.status.label] ?? _green;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF19845A), Color(0xFF106B49)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _darkGreen.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  donation.status.label.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.restaurant_menu_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            donation.foodName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          UrgencyBadge(donation: donation),
        ],
      ),
    );
  }
}

// ============================================================
// SECTION HEADER (numbered badge + optional action)
// ============================================================
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.number,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String number;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 28,
          width: 28,
          decoration: BoxDecoration(
            color: _green,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(fontSize: 12, color: _textSecondary),
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
// INFO CARD
// ============================================================
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows, this.highlight = false});

  final List<Widget> rows;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: highlight
              ? const Color(0xFFD58A19).withValues(alpha: 0.4)
              : _border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      ),
    );
  }
}

// ============================================================
// INFO ROW (icon + label + value)
// ============================================================
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              color: _lightGreen,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: _darkGreen, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: _textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EMPTY REQUESTS CARD
// ============================================================
class _EmptyRequestsCard extends StatelessWidget {
  final bool isCancelled;
  const _EmptyRequestsCard({required this.isCancelled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _textSecondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCancelled
                  ? Icons.block_rounded
                  : Icons.mark_email_unread_outlined,
              color: _textSecondary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isCancelled
                  ? 'This donation is cancelled and no longer accepts requests.'
                  : 'No pickup requests for this donation yet.',
              style: const TextStyle(
                fontSize: 13,
                color: _textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// REQUEST SUMMARY TILE
// ============================================================
class _RequestSummaryTile extends StatelessWidget {
  const _RequestSummaryTile({required this.request, required this.onTap});

  final PickupRequest request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColors[request.status.label] ?? _green;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.handshake_outlined,
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.ngoName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${request.requestedQuantity} ${request.requestedUnit} • '
                      'pickup ${DateTimeUtils.formatForDisplay(request.pickupDate)}',
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  request.status.label.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
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

// ============================================================
// GRADIENT BUTTON (Edit)
// ============================================================
class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: enabled ? _green : _green.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: _green.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
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
// OUTLINE ACTION BUTTON (Cancel)
// ============================================================
class _OutlineActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;

  const _OutlineActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: enabled ? color.withValues(alpha: 0.06) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: enabled
                    ? color.withValues(alpha: 0.4)
                    : color.withValues(alpha: 0.15),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: enabled ? color : color.withValues(alpha: 0.4),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: enabled ? color : color.withValues(alpha: 0.4),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
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
// LOCKED BANNER
// ============================================================
class _LockedBanner extends StatelessWidget {
  final String statusLabel;
  const _LockedBanner({required this.statusLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _lightGreen,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _green.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              size: 16,
              color: _darkGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This donation is ${statusLabel.toLowerCase()}, so it can no '
              'longer be edited or cancelled.',
              style: const TextStyle(
                fontSize: 13,
                color: _darkGreen,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CONFIRM DIALOG (cancel donation)
// ============================================================
class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;
  final Color iconColor;
  final String confirmLabel;
  final Color confirmColor;

  const _ConfirmDialog({
    required this.title,
    required this.body,
    required this.icon,
    required this.iconColor,
    required this.confirmLabel,
    required this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              body,
              style: TextStyle(
                fontSize: 13,
                color: _textPrimary.withValues(alpha: 0.7),
                height: 1.55,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      foregroundColor: _textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: _border),
                      ),
                    ),
                    child: const Text(
                      'Keep donation',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Material(
                    color: confirmColor,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => Navigator.pop(context, true),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: confirmColor.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Text(
                          confirmLabel,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
