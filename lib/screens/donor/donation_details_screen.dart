import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_time_utils.dart';
import '../../data/repositories/local_donation_repository.dart';
import '../../models/food_donation.dart';
import '../../models/pickup_request.dart';
import '../../widgets/common/status_badge.dart';

class DonationDetailsScreen extends StatelessWidget {
  const DonationDetailsScreen({
    super.key,
    required this.repository,
    required this.donationId,
  });

  final FoodLinkRepository repository;
  final String donationId;

  @override
  Widget build(BuildContext context) {
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
        donation.status != DonationStatus.cancelled &&
        donation.status != DonationStatus.collected &&
        donation.status != DonationStatus.delivered;

    return Scaffold(
      appBar: AppBar(title: const Text('Donation Details')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  StatusBadge(status: donation.status.label),
                ],
              ),
              const SizedBox(height: 16),
              _InfoRow(label: 'Category', value: donation.category),
              _InfoRow(
                label: 'Quantity',
                value: '${donation.quantity} ${donation.quantityUnit}',
              ),
              _InfoRow(
                label: 'Safe-use deadline',
                value: DateTimeUtils.formatForDisplay(donation.safeUseDeadline),
              ),
              _InfoRow(
                label: 'Pickup availability',
                value:
                    '${DateTimeUtils.formatForDisplay(donation.pickupStart)} - ${DateTimeUtils.formatForDisplay(donation.pickupEnd)}',
              ),
              _InfoRow(label: 'Pickup area', value: donation.pickupArea),
              _InfoRow(label: 'Pickup address', value: donation.pickupAddress),
              _InfoRow(
                label: 'Created',
                value: DateTimeUtils.formatForDisplay(donation.createdAt),
              ),
              if (donation.notes.isNotEmpty)
                _InfoRow(label: 'Notes', value: donation.notes),
              const SizedBox(height: 20),
              if (relatedRequests.isNotEmpty) ...[
                const Text(
                  'Pickup Requests',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                ...relatedRequests.map(
                  (request) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                request.ngoName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            StatusBadge(status: request.status.label),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${request.requestedQuantity} ${request.requestedUnit} • ${DateTimeUtils.formatForDisplay(request.pickupDate)}',
                        ),
                        if (request.message.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            request.message,
                            style: const TextStyle(
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),
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
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit Donation'),
                    ),
                  if (canCancel)
                    OutlinedButton.icon(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Cancel donation?'),
                            content: const Text(
                              'This will cancel the donation and related pending requests. Are you sure?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Yes, cancel'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          repository.cancelDonation(donation.id);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Donation cancelled successfully.'),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancel Donation'),
                    ),
                  if (relatedRequests.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/pickup-requests'),
                      icon: const Icon(Icons.list_alt_outlined),
                      label: const Text('View Requests'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
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
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
