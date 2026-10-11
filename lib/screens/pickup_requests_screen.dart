import 'package:flutter/material.dart';

class PickupRequestsScreen extends StatefulWidget {
  const PickupRequestsScreen({super.key});

  @override
  State<PickupRequestsScreen> createState() => _PickupRequestsScreenState();
}

class _PickupRequestsScreenState extends State<PickupRequestsScreen> {
  static const Color green = Color(0xFF16845B);

  final List<Map<String, String>> requests = [
    {
      'ngo': 'Hope Welfare Organization',
      'food': 'Cooked Rice',
      'quantity': '10 servings',
      'location': 'Islamabad',
      'status': 'Pending',
    },
    {
      'ngo': 'Helping Hands NGO',
      'food': 'Fresh Bread',
      'quantity': '20 pieces',
      'location': 'Rawalpindi',
      'status': 'Pending',
    },
  ];

  void updateRequest(int index, String status) {
    setState(() {
      requests[index]['status'] = status;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Request $status successfully.'),
        backgroundColor: green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        title: const Text('Pickup Requests'),
        backgroundColor: green,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'NGO Requests',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: green,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Review requests for your food donations.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),

          ...requests.asMap().entries.map((entry) {
            final index = entry.key;
            final request = entry.value;
            final status = request['status']!;

            final statusColor = status == 'Approved'
                ? Colors.green
                : status == 'Rejected'
                ? Colors.red
                : Colors.orange;

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request['ngo']!,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Food: ${request['food']}'),
                    Text('Quantity: ${request['quantity']}'),
                    Text('Pickup location: ${request['location']}'),
                    const SizedBox(height: 14),

                    Chip(
                      label: Text(status),
                      backgroundColor: statusColor.withValues(alpha: 0.12),
                      labelStyle: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    if (status == 'Pending') ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                updateRequest(index, 'Approved');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Approve'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                updateRequest(index, 'Rejected');
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Reject'),
                            ),
                          ),
                        ],
                      ),
                    ],
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
