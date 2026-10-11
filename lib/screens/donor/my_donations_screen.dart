import 'package:flutter/material.dart';

import '../../data/repositories/local_donation_repository.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/donations/donation_card.dart';

class MyDonationsScreen extends StatelessWidget {
  const MyDonationsScreen({super.key, required this.repository});

  final FoodLinkRepository repository;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final donations = repository.donorDonations;
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Donations'),
            actions: [
              IconButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/create-donation'),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE1E8E1)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: 'All',
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: 'All',
                            child: Text('All Donations'),
                          ),
                          DropdownMenuItem(
                            value: 'Available',
                            child: Text('Available'),
                          ),
                          DropdownMenuItem(
                            value: 'Reserved',
                            child: Text('Reserved'),
                          ),
                          DropdownMenuItem(
                            value: 'Collected',
                            child: Text('Collected'),
                          ),
                          DropdownMenuItem(
                            value: 'Delivered',
                            child: Text('Delivered'),
                          ),
                          DropdownMenuItem(
                            value: 'Cancelled',
                            child: Text('Cancelled'),
                          ),
                        ],
                        onChanged: null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: donations.isEmpty
                        ? const EmptyState(
                            message:
                                'You have not published any donations yet.',
                          )
                        : ListView.builder(
                            itemCount: donations.length,
                            itemBuilder: (context, index) {
                              final donation = donations[index];
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
