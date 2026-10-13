import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_time_utils.dart';
import '../../data/repositories/local_donation_repository.dart';
import '../../models/food_donation.dart';
import '../../models/pickup_request.dart';
import '../../widgets/common/empty_state.dart';

const Color _green = AppColors.primaryGreen;
const Color _background = AppColors.warmBackground;
const Color _darkGreen = Color(0xFF106B49);
const Color _lightGreen = Color(0xFFE8F5EC);
const Color _textPrimary = Color(0xFF19352A);
const Color _textSecondary = Color(0xFF738178);
const Color _border = Color(0xFFE8EDE8);
const Color _dangerRed = Color(0xFFCB4A4A);

const Map<String, Color> _statusColors = {
  'All': _green,
  'Pending': Color(0xFFD58A19),
  'Approved': Color(0xFF19845A),
  'Rejected': _dangerRed,
  'Cancelled': Color(0xFF8E9890),
};

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
        iconColor: _green,
        body:
            '${request.ngoName} will be able to pick up $foodName. The donation '
            'will be marked as Reserved and other requests for it can no '
            'longer be approved.',
        confirmLabel: 'Approve',
        confirmColor: _green,
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
          appBar: _buildAppBar(context),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final horizontalPadding = width >= 1100
                    ? 48.0
                    : width >= 700
                    ? 32.0
                    : 20.0;
                final contentWidth = width >= 1200 ? 1100.0 : 900.0;

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentWidth),
                    child: requests.isEmpty
                        ? _buildInitialEmptyState(horizontalPadding)
                        : CustomScrollView(
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            slivers: [
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  horizontalPadding,
                                  16,
                                  horizontalPadding,
                                  12,
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: _buildSummaryCard(
                                    requests,
                                    filtered.length,
                                  ),
                                ),
                              ),
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  horizontalPadding,
                                  0,
                                  horizontalPadding,
                                  10,
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: _buildFilterChips(),
                                ),
                              ),
                              SliverPadding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                  vertical: 4,
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: _buildCountRow(
                                    filtered.length,
                                    requests.length,
                                  ),
                                ),
                              ),
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  horizontalPadding,
                                  8,
                                  horizontalPadding,
                                  24,
                                ),
                                sliver: filtered.isEmpty
                                    ? SliverToBoxAdapter(
                                        child: EmptyState(
                                          icon: Icons.search_off_rounded,
                                          message:
                                              'No requests match this status. '
                                              'Try another filter.',
                                        ),
                                      )
                                    : SliverList(
                                        delegate: SliverChildBuilderDelegate((
                                          context,
                                          index,
                                        ) {
                                          final request = filtered[index];
                                          final donation = widget.repository
                                              .donationById(request.donationId);
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 12,
                                            ),
                                            child: _RequestCard(
                                              request: request,
                                              donationName:
                                                  donation?.foodName ??
                                                  'Donation',
                                              donationStatusLabel:
                                                  donation?.status.label ?? '',
                                              onApprove: () =>
                                                  _approveRequest(request),
                                              onReject: () =>
                                                  _rejectRequest(request),
                                              onViewDetails: donation == null
                                                  ? null
                                                  : () => Navigator.pushNamed(
                                                      context,
                                                      '/donation-details',
                                                      arguments: donation.id,
                                                    ),
                                            ),
                                          );
                                        }, childCount: filtered.length),
                                      ),
                              ),
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  horizontalPadding,
                                  0,
                                  horizontalPadding,
                                  26,
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: _buildDemoNote(),
                                ),
                              ),
                            ],
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
              color: _green,
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
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
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

  Widget _buildSummaryCard(List<PickupRequest> requests, int showingCount) {
    int countByStatus(String label) =>
        requests.where((request) => request.status.label == label).length;

    final pending = countByStatus('Pending');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF19845A), Color(0xFF106B49)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _darkGreen.withOpacity(0.18),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PENDING YOUR RESPONSE',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$pending',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            pending == 1 ? 'request' : 'requests',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Text(
                      'TOTAL',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${requests.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _miniStat('Approved', countByStatus('Approved')),
              const SizedBox(width: 8),
              _miniStat('Rejected', countByStatus('Rejected')),
              const SizedBox(width: 8),
              _miniStat('Cancelled', countByStatus('Cancelled')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, int count) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: _statusFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _statusFilters[index];
          final selected = _statusFilter == filter;
          final color = _statusColors[filter] ?? _green;
          return _FilterChip(
            label: filter,
            selected: selected,
            color: color,
            borderColor: _border,
            textColor: _textSecondary,
            onTap: () => setState(() => _statusFilter = filter),
          );
        },
      ),
    );
  }

  Widget _buildCountRow(int filteredCount, int totalCount) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Showing $filteredCount of $totalCount requests',
        style: const TextStyle(
          color: _textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDemoNote() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _lightGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, size: 16, color: _darkGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppConstants.demoDataNote,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 11,
                color: _darkGreen,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialEmptyState(double horizontalPadding) {
    return Padding(
      padding: EdgeInsets.all(horizontalPadding),
      child: const EmptyState(
        icon: Icons.mark_email_unread_outlined,
        message:
            'No pickup requests have been submitted for your donations yet.',
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.borderColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color : Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? color : borderColor,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 6),
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    final isPending = request.status == PickupRequestStatus.pending;
    final statusColor = _statusColors[request.status.label] ?? _green;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 4, color: statusColor),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.handshake_outlined,
                        color: statusColor,
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
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _textPrimary,
                              letterSpacing: -0.2,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.14),
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
                  ],
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: onViewDetails,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _lightGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.restaurant_outlined,
                          size: 18,
                          color: _darkGreen,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            donationName +
                                (donationStatusLabel.isEmpty
                                    ? ''
                                    : ' • $donationStatusLabel'),
                            style: const TextStyle(
                              fontSize: 13,
                              color: _darkGreen,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (onViewDetails != null)
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: _darkGreen,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _DetailLine(
                  label: 'Requested',
                  value:
                      '${request.requestedQuantity} ${request.requestedUnit}',
                  icon: Icons.scale_outlined,
                ),
                _DetailLine(
                  label: 'Pickup',
                  value: DateTimeUtils.formatForDisplay(request.pickupDate),
                  icon: Icons.event_outlined,
                ),
                _DetailLine(
                  label: 'Submitted',
                  value: DateTimeUtils.formatForDisplay(request.submittedAt),
                  icon: Icons.schedule_outlined,
                ),
                if (request.message.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8F6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border(
                        left: BorderSide(color: statusColor, width: 3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.format_quote_rounded,
                              size: 14,
                              color: _textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'MESSAGE',
                              style: TextStyle(
                                color: _textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          request.message,
                          style: TextStyle(
                            fontSize: 13,
                            color: _textPrimary.withOpacity(0.85),
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (isPending) ...[
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _GradientButton(
                          label: 'Approve',
                          icon: Icons.check_rounded,
                          color: _green,
                          onTap: onApprove,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _OutlineButton(
                          label: 'Reject',
                          icon: Icons.close_rounded,
                          color: _dangerRed,
                          onTap: onReject,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: _textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _OutlineButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.06),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.4), width: 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
                    color: iconColor.withOpacity(0.12),
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
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
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
                    child: Text(confirmLabel),
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
