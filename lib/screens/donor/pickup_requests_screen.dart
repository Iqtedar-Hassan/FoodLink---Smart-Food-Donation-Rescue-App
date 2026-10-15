import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/date_time_utils.dart';
import '../../data/repositories/local_donation_repository.dart';
import '../../models/food_donation.dart';
import '../../models/pickup_request.dart';
import '../../widgets/common/empty_state.dart';

// ============================================================
// Design tokens — same palette as Dashboard and My Donations.
// ============================================================
const Color _primaryGreen = Color(0xFF117A50);
const Color _darkGreen = Color(0xFF0B6842);
const Color _lightGreen = Color(0xFFE6F4EB);
const Color _background = Color(0xFFF3F6F4);
const Color _textPrimary = Color(0xFF14251C);
const Color _textSecondary = Color(0xFF3D4E44);
const Color _border = Color(0xFFC4D3C9);

const Color _pendingColor = Color(0xFFA96208); // dark amber
const Color _dangerRed = Color(0xFFB23A3A); // dark red
const Color _cancelledColor = Color(0xFF5A675F); // dark grey

const Map<String, Color> _statusColors = {
  'All': _primaryGreen,
  'Pending': _pendingColor,
  'Approved': _primaryGreen,
  'Rejected': _dangerRed,
  'Cancelled': _cancelledColor,
};

const List<BoxShadow> _cardShadow = [
  BoxShadow(color: Color(0x14323223), blurRadius: 10, offset: Offset(0, 4)),
];

class PickupRequestsScreen extends StatefulWidget {
  const PickupRequestsScreen({super.key, required this.repository});

  final FoodLinkRepository repository;

  @override
  State<PickupRequestsScreen> createState() => _PickupRequestsScreenState();
}

class _PickupRequestsScreenState extends State<PickupRequestsScreen> {
  String _statusFilter = 'All';

  static const List<String> _statusFilters = [
    'All',
    'Pending',
    'Approved',
    'Rejected',
    'Cancelled',
  ];

  List<PickupRequest> _filteredRequests() {
    final requests = widget.repository.donorPickupRequests;
    if (_statusFilter == 'All') return requests;
    return requests
        .where((request) => request.status.label == _statusFilter)
        .toList();
  }

  void _showResult(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _approveRequest(PickupRequest request) async {
    final donation = widget.repository.donationById(request.donationId);
    final foodName = donation?.foodName ?? 'this donation';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _ConfirmDialog(
        title: 'Approve request?',
        icon: Icons.check_circle_outline_rounded,
        iconColor: _primaryGreen,
        body:
            '${request.ngoName} will be able to pick up $foodName. The donation '
            'will be marked as Reserved and other requests for it can no '
            'longer be approved.',
        confirmLabel: 'Approve',
        confirmColor: _primaryGreen,
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      widget.repository.approvePickupRequest(request.id);
      if (!mounted) return;
      _showResult('Request from ${request.ngoName} approved.');
    } catch (error) {
      if (!mounted) return;
      _showResult(_friendlyError(error));
    }
  }

  Future<void> _rejectRequest(PickupRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _ConfirmDialog(
        title: 'Reject request?',
        icon: Icons.cancel_outlined,
        iconColor: _dangerRed,
        body:
            'The request from ${request.ngoName} will be rejected. The '
            'donation will stay available for other NGOs.',
        confirmLabel: 'Reject',
        confirmColor: _dangerRed,
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      widget.repository.rejectPickupRequest(request.id);
      if (!mounted) return;
      _showResult('Request from ${request.ngoName} rejected.');
    } catch (error) {
      if (!mounted) return;
      _showResult(_friendlyError(error));
    }
  }

  static String _friendlyError(Object error) {
    return error.toString().replaceFirst('Bad state: ', '');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repository,
      builder: (context, _) {
        final requests = widget.repository.donorPickupRequests;
        final filtered = _filteredRequests();

        return Scaffold(
          backgroundColor: _background,
          appBar: _buildAppBar(),
          body: SafeArea(
            child: requests.isEmpty
                ? _buildInitialEmptyState()
                : _buildContent(
                    filtered: filtered,
                    totalCount: requests.length,
                  ),
          ),
        );
      },
    );
  }

  // ============================================================
  // MAIN CONTENT — one simple ListView
  // ============================================================
  Widget _buildContent({
    required List<PickupRequest> filtered,
    required int totalCount,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _buildSummaryCard(widget.repository.donorPickupRequests),
            const SizedBox(height: 16),

            _buildFilterChips(),
            const SizedBox(height: 10),

            Text(
              'Showing ${filtered.length} of $totalCount requests',
              style: const TextStyle(
                color: _textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            if (filtered.isEmpty)
              const EmptyState(
                icon: Icons.search_off_rounded,
                message: 'No requests match this status. Try another filter.',
              )
            else
              ...filtered.map((request) {
                final donation = widget.repository.donationById(
                  request.donationId,
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RequestCard(
                    request: request,
                    donationName: donation?.foodName ?? 'Donation',
                    donationStatusLabel: donation?.status.label ?? '',
                    onApprove: () => _approveRequest(request),
                    onReject: () => _rejectRequest(request),
                    onViewDetails: donation == null
                        ? null
                        : () => Navigator.pushNamed(
                            context,
                            '/donation-details',
                            arguments: donation.id,
                          ),
                  ),
                );
              }),

            const SizedBox(height: 6),
            _buildDemoNote(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _background,
      foregroundColor: _textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      toolbarHeight: 72,
      titleSpacing: 20,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: _primaryGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pickup Requests',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: _textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'REVIEW NGO REQUESTS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY CARD — clean and simple:
  // title → big number → divider → inline stats (no boxes)
  // ============================================================
  Widget _buildSummaryCard(List<PickupRequest> requests) {
    int countByStatus(String label) =>
        requests.where((request) => request.status.label == label).length;

    final pending = countByStatus('Pending');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primaryGreen, _darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _darkGreen.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Pending Requests',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),

          // Big number + label + total
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$pending',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    pending == 1
                        ? 'request waiting for you'
                        : 'requests waiting for you',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '${requests.length} total',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Thin divider
          Divider(
            color: Colors.white.withValues(alpha: 0.25),
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: 12),

          // Simple inline stats — no boxes
          Row(
            children: [
              Expanded(
                child: _summaryStat('Approved', countByStatus('Approved')),
              ),
              Expanded(
                child: _summaryStat('Rejected', countByStatus('Rejected')),
              ),
              Expanded(
                child: _summaryStat('Cancelled', countByStatus('Cancelled')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryStat(String label, int value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$value',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FILTER CHIPS — one horizontal scrollable row
  // ============================================================
  Widget _buildFilterChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: _statusFilters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _statusFilters[index];
          final selected = _statusFilter == filter;
          final color = _statusColors[filter] ?? _primaryGreen;
          return ChoiceChip(
            label: Text(filter),
            selected: selected,
            onSelected: (_) => setState(() => _statusFilter = filter),
            selectedColor: color,
            checkmarkColor: Colors.white,
            side: BorderSide(color: selected ? color : _border, width: 1.4),
            labelStyle: TextStyle(
              color: selected ? Colors.white : _textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // DEMO NOTE
  // ============================================================
  Widget _buildDemoNote() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _lightGreen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primaryGreen.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, size: 18, color: _darkGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppConstants.demoDataNote,
              style: const TextStyle(
                fontSize: 12,
                color: _darkGreen,
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INITIAL EMPTY STATE
  // ============================================================
  Widget _buildInitialEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: EmptyState(
        icon: Icons.mark_email_unread_outlined,
        message:
            'No pickup requests have been submitted for your donations yet.',
      ),
    );
  }
}

// ============================================================
// REQUEST CARD — clean white card, NO color strip on top.
// Header: icon tile + NGO name + food name + status pill.
// ============================================================
class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.donationName,
    required this.donationStatusLabel,
    required this.onApprove,
    required this.onReject,
    this.onViewDetails,
  });

  final PickupRequest request;
  final String donationName;
  final String donationStatusLabel;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback? onViewDetails;

  Widget _detail(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 15, color: _textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPending = request.status == PickupRequestStatus.pending;
    final statusColor = _statusColors[request.status.label] ?? _primaryGreen;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: _cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Header: icon tile + names + status pill (right)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.handshake_outlined,
                  color: _primaryGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      donationName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _textSecondary,
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
                  color: statusColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  request.status.label.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ---- Detail lines
          _detail(
            'Requested',
            '${request.requestedQuantity} ${request.requestedUnit}',
            Icons.scale_outlined,
          ),
          _detail(
            'Pickup',
            DateTimeUtils.formatForDisplay(request.pickupDate),
            Icons.event_outlined,
          ),
          _detail(
            'Submitted',
            DateTimeUtils.formatForDisplay(request.submittedAt),
            Icons.schedule_outlined,
          ),

          // ---- NGO message
          if (request.message.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.format_quote_rounded,
                    size: 16,
                    color: _textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      request.message,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _textPrimary,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ---- View donation details
          if (onViewDetails != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onViewDetails,
                icon: const Icon(Icons.visibility_outlined, size: 16),
                label: const Text('View Donation Details'),
                style: TextButton.styleFrom(
                  foregroundColor: _primaryGreen,
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],

          // ---- Approve / Reject buttons (only when pending)
          if (isPending) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Approve'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 46),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _dangerRed,
                      side: const BorderSide(color: _dangerRed, width: 1.6),
                      minimumSize: const Size(0, 46),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// CONFIRM DIALOG
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
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              body,
              style: const TextStyle(
                fontSize: 14,
                color: _textSecondary,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _textPrimary,
                      side: const BorderSide(color: _border, width: 1.4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: confirmColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      confirmLabel,
                      style: const TextStyle(fontWeight: FontWeight.w800),
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
