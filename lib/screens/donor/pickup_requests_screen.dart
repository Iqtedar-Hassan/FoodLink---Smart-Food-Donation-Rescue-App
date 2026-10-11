import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_time_utils.dart';
import '../../data/repositories/local_donation_repository.dart';
import '../../models/pickup_request.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/status_badge.dart';

class PickupRequestsScreen extends StatelessWidget {
  const PickupRequestsScreen({super.key, required this.repository});

  final FoodLinkRepository repository;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final requests = repository.donorPickupRequests;

        return Scaffold(
          appBar: AppBar(title: const Text('Pickup Requests')),
          body: SafeArea(
            child: requests.isEmpty
                ? const EmptyState(
                    message: 'No pickup requests have been submitted for your donations yet.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      final donation = repository.donationById(
                        request.donationId,
                      );
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                StatusBadge(status: request.status.label),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              donation != null ? donation.foodName : 'Donation',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${request.requestedQuantity} ${request.requestedUnit} • ${DateTimeUtils.formatForDisplay(request.pickupDate)}',
                              style: const TextStyle(
                                color: AppColors.secondaryText,
                              ),
                            ),
                            if (request.message.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                request.message,
                                style: const TextStyle(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                            if (request.status ==
                                PickupRequestStatus.pending) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text(
                                              'Approve request?',
                                            ),
                                            content: Text(
                                              'Approve ${request.ngoName} for ${donation != null ? donation.foodName : 'this donation'}?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                                child: const Text('Approve'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirmed != true) return;
                                        try {
                                          repository.approvePickupRequest(
                                            request.id,
                                          );
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Pickup request approved. Donation marked as Reserved.',
                                                  ),
                                                ),
                                              );
                                        } catch (error) {
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(error.toString()),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text('Approve'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () async {
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text(
                                              'Reject request?',
                                            ),
                                            content: Text(
                                              'Reject ${request.ngoName} for ${donation != null ? donation.foodName : 'this donation'}?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                                child: const Text('Reject'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirmed != true) return;
                                        repository.rejectPickupRequest(
                                          request.id,
                                        );
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Pickup request rejected.',
                                                ),
                                              ),
                                            );
                                      },
                                      child: const Text('Reject'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
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
