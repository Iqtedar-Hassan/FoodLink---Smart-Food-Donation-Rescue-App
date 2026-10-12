import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_time_utils.dart';
import '../../data/repositories/local_donation_repository.dart';
import '../../models/food_donation.dart';
import '../../models/pickup_request.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/urgency_badge.dart';

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
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel donation?'),
        content: const Text(
          'This will cancel the donation and any of its pending pickup '
          'requests. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep donation'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      repository.cancelDonation(donation.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donation cancelled successfully.')),
      );
      Navigator.pop(context);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_friendlyError(error))));
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
      listenable: repository,
      builder: (context, _) {
        final donation = repository.donationById(donationId);

        if (donation == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Donation Details')),
            body: const Center(
              child: Text('This donation is no longer available.'),
            ),
          );
        }

        final relatedRequests = repository.requestsForDonation(donation.id);
        final canEdit =
            donation.status == DonationStatus.available ||
            donation.status == DonationStatus.reserved;
        final canCancel =
            donation.status == DonationStatus.available ||
            donation.status == DonationStatus.reserved;

        return Scaffold(
          appBar: AppBar(title: const Text('Donation Details')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          donation.foodName,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(status: donation.status.label),
                    ],
                  ),
                  const SizedBox(height: 10),
                  UrgencyBadge(donation: donation),
                  const SizedBox(height: 16),
                  const Text(
                    'Food Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  _InfoCard(
                    rows: [
                      _InfoRow(label: 'Category', value: donation.category),
                      _InfoRow(
                        label: 'Quantity',
                        value: '${donation.quantity} ${donation.quantityUnit}',
                      ),
                      _InfoRow(
                        label: 'Created',
                        value: DateTimeUtils.formatForDisplay(
                          donation.createdAt,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Deadline and Pickup',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  _InfoCard(
                    highlight: DateTimeUtils.isExpiringSoon(
                      donation.safeUseDeadline,
                    ),
                    rows: [
                      _InfoRow(
                        label: 'Safe-use deadline',
                        value:
                            '${DateTimeUtils.formatForDisplay(donation.safeUseDeadline)}'
                            ' • ${DateTimeUtils.timeLeftLabel(donation.safeUseDeadline)}',
                      ),
                      _InfoRow(
                        label: 'Pickup window',
                        value:
                            '${DateTimeUtils.formatForDisplay(donation.pickupStart)}'
                            ' - ${DateTimeUtils.formatForDisplay(donation.pickupEnd)}',
                      ),
                      _InfoRow(
                        label: 'Pickup area',
                        value: donation.pickupArea,
                      ),
                      _InfoRow(
                        label: 'Pickup address',
                        value: donation.pickupAddress,
                      ),
                      if (donation.notes.isNotEmpty)
                        _InfoRow(label: 'Notes', value: donation.notes),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pickup Requests',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (relatedRequests.isNotEmpty)
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/pickup-requests'),
                          child: const Text('Manage'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (relatedRequests.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        donation.status == DonationStatus.cancelled
                            ? 'This donation is cancelled and no longer accepts requests.'
                            : 'No pickup requests for this donation yet.',
                        style: const TextStyle(color: AppColors.secondaryText),
                      ),
                    )
                  else
                    ...relatedRequests.map(
                      (request) => _RequestSummaryTile(
                        request: request,
                        onTap: () =>
                            Navigator.pushNamed(context, '/pickup-requests'),
                      ),
                    ),
                  const SizedBox(height: 24),
                  if (canEdit || canCancel)
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        if (canEdit)
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/create-donation',
                                arguments: {'donationId': donation.id},
                              );
                            },
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Edit Donation'),
                          ),
                        if (canCancel)
                          OutlinedButton.icon(
                            onPressed: () => _confirmCancel(context, donation),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.errorRed,
                              side: const BorderSide(color: AppColors.errorRed),
                            ),
                            icon: const Icon(Icons.cancel_outlined, size: 18),
                            label: const Text('Cancel Donation'),
                          ),
                      ],
                    ),
                  if (!canEdit && !canCancel)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.lightGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'This donation is ${donation.status.label.toLowerCase()}, '
                        'so it can no longer be edited or cancelled.',
                        style: const TextStyle(
                          color: AppColors.darkGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows, this.highlight = false});

  final List<Widget> rows;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight ? AppColors.warningAmber : AppColors.border,
          width: highlight ? 1.4 : 1,
        ),
      ),
      child: Column(children: rows),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 128,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestSummaryTile extends StatelessWidget {
  const _RequestSummaryTile({required this.request, required this.onTap});

  final PickupRequest request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.ngoName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${request.requestedQuantity} ${request.requestedUnit} • '
                        'pickup ${DateTimeUtils.formatForDisplay(request.pickupDate)}',
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: request.status.label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
