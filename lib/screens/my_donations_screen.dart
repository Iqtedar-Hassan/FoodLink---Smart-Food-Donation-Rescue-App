import 'package:flutter/material.dart';

class MyDonationsScreen extends StatelessWidget {
  const MyDonationsScreen({super.key});

  static const Color green = Color(0xFF16845B);

  final List<Map<String, String>> donations = const [
    {
      'food': 'Cooked Rice',
      'quantity': '10 servings',
      'location': 'Islamabad',
      'status': 'Available',
    },
    {
      'food': 'Fresh Bread',
      'quantity': '20 pieces',
      'location': 'Rawalpindi',
      'status': 'Requested',
    },
    {
      'food': 'Fresh Vegetables',
      'quantity': '5 kg',
      'location': 'Islamabad',
      'status': 'Collected',
    },
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'Available':
        return Colors.green;
      case 'Requested':
        return Colors.orange;
      case 'Collected':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        title: const Text('My Donations'),
        backgroundColor: green,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Your Food Donations',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: green,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'View the food donations you have shared.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),

          ...donations.map((donation) {
            final status = donation['status']!;

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 14),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.restaurant, color: green, size: 30),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            donation['food']!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text('Quantity: ${donation['quantity']}'),
                    const SizedBox(height: 6),
                    Text('Location: ${donation['location']}'),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(status).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: _statusColor(status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
