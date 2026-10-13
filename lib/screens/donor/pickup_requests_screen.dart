import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_time_utils.dart';
import '../../data/repositories/local_donation_repository.dart';
import '../../models/food_donation.dart';
import '../../models/pickup_request.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/status_badge.dart';

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
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _approveRequest(PickupRequest request) async {
    final donation = widget.repository.donationById(request.donationId);
    final foodName = donation?.foodName ?? 'this donation';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Approve request?'),
        content: Text(
          '${request.ngoName} will be able to pick up $foodName. '
          'The donation will be marked as Reserved and other requests '
          'for it can no longer be approved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      widget.repository.approvePickupRequest(request.id);
      if (!mounted) return;
      _showResult(
        'Request from ${request.ngoName} approved. "$foodName" is now Reserved.',
      );
    } catch (error) {
      if (!mounted) return;
      _showResult(_friendlyError(error));
    }
  }

  Future<void> _rejectRequest(PickupRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject request?'),
        content: Text(
          'The request from ${request.ngoName} will be rejected. The donation '
          'will stay available for other NGOs.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: const Text('Reject'),
          ),
        ],
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
    final message = error.toString();
    const prefix = 'Bad state: ';
    return message.startsWith(prefix)
        ? message.substring(prefix.length)
        : message;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repository,
      builder: (context, _) {
        final requests = widget.repository.donorPickupRequests;
        final filtered = _filteredRequests();

        return Scaffold(
          appBar: AppBar(title: const Text('Pickup Requests')),
          body: SafeArea(
            child: requests.isEmpty
                ? const EmptyState(
                    icon: Icons.mark_email_unread_outlined,
                    message: 'No pickup requests have been submitted for your donations yet.',
                  )
                : Column(
                    children: [
                      SizedBox(
                        height: 52,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          scrollDirection: Axis.horizontal,
                          itemCount: _statusFilters.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final filter = _statusFilters[index];
                            final selected = _statusFilter == filter;
                            return ChoiceChip(
                              label: Text(filter),
                              selected: selected,
                              selectedColor: AppColors.lightGreen,
                              labelStyle: TextStyle(
                                color: selected
                                    ? AppColors.darkGreen
                                    : AppColors.secondaryText,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                              side: BorderSide(
                                color: selected
                                    ? AppColors.primaryGreen
                                    : AppColors.border,
                              ),
                              showCheckmark: false,
                              onSelected: (_) =>
                                  setState(() => _statusFilter = filter),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        // AnimatedSwitcher fades the list briefly whenever the
                        // status filter changes.
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: KeyedSubtree(
                            key: ValueKey(_statusFilter),
                            child: filtered.isEmpty
                                ? const EmptyState(
                                    icon: Icons.search_off_rounded,
                                    message: 'No requests with this status. Try another filter.',
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      4,
                                      16,
                                      16,
                                    ),
                                    itemCount: filtered.length,
                                    itemBuilder: (context, index) {
                                      final request = filtered[index];
                                      final donation = widget.repository
                                          .donationById(request.donationId);
                                      return _RequestCard(
                                        request: request,
                                        donationName:
                                            donation?.foodName ??
                                            'Unknown donation',
                                        donationStatusLabel:
                                            donation?.status.label ?? '',
                                        onApprove: () =>
                                            _approveRequest(request),
                                        onReject: () => _rejectRequest(request),
                                        onViewDetails: donation == null
                                            ? null
                                            : () => Navigator.pushNamed(
                                                context,
                                                '/donation-details',
                                                arguments: donation.id,
                                              ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                        child: Text(
                          AppConstants.demoDataNote,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.secondaryText),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
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

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      request.ngoName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.softBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Demo NGO',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: request.status.label),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onViewDetails,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.restaurant_outlined,
                    size: 15,
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      '$donationName'
                      '${donationStatusLabel.isEmpty ? '' : ' • $donationStatusLabel'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  if (onViewDetails != null) ...[
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 17,
                      color: AppColors.primaryGreen,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Requested: ${request.requestedQuantity} ${request.requestedUnit}',
            style: const TextStyle(color: AppColors.secondaryText),
          ),
          const SizedBox(height: 4),
          Text(
            'Proposed pickup: ${DateTimeUtils.formatForDisplay(request.pickupDate)}',
            style: const TextStyle(color: AppColors.secondaryText),
          ),
          const SizedBox(height: 4),
          Text(
            'Submitted: ${DateTimeUtils.formatForDisplay(request.submittedAt)}',
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 13,
            ),
          ),
          if (request.message.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warmBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '"${request.message}"',
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                ),
              ),
            ),
          ],
          if (isPending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Approve'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.errorRed,
                      side: const BorderSide(color: AppColors.errorRed),
                    ),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Reject'),
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
