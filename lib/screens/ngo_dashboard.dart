import 'package:flutter/material.dart';

import '../services/donation_service.dart';

class NgoDashboard extends StatelessWidget {
  const NgoDashboard({super.key});

  static const Color green = Color(0xFF16845B);

  void _requestPickup(BuildContext context, String food) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pickup request sent for $food! '),
        backgroundColor: green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final donations = DonationService.getAvailableDonations();
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        title: const Text('FoodLink - NGO'),
        backgroundColor: green,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Welcome, NGO!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: green,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Find surplus food and help your community.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Available Food Donations',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                if (donations.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No food donations available yet.',
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  ...donations.map((donation) {
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              donation.foodName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Type: ${donation.foodType}'),
                            Text(
                              'Quantity: ${donation.quantity} servings/units',
                            ),
                            Text('Location: ${donation.location}'),
                            Text(
                              'Safe-use date: '
                              '${donation.safeUseDate.day}/'
                              '${donation.safeUseDate.month}/'
                              '${donation.safeUseDate.year}',
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Available',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
