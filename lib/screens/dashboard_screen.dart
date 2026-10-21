import 'package:flutter/material.dart';

import 'add_donation_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$role Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Back to welcome',
            icon: const Icon(Icons.logout),
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: 600,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: Color(0xFFE7F4ED),
                        foregroundColor: Color(0xFF16845B),
                        child: Icon(Icons.volunteer_activism),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, $role',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Small acts. Big impact.',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'FoodLink preview • Sample content only.',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
              const SizedBox(height: 20),
              if (role == 'Admin') ...[
                const Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.people_outline,
                      color: Color(0xFF16845B),
                    ),
                    title: Text('Sample users'),
                    trailing: Text('5'),
                  ),
                ),
                const SizedBox(height: 12),
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.restaurant, color: Color(0xFF16845B)),
                    title: Text('Sample donations'),
                    trailing: Text('2'),
                  ),
                ),
                const SizedBox(height: 12),
                const Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.local_shipping_outlined,
                      color: Color(0xFF16845B),
                    ),
                    title: Text('Sample pickup requests'),
                    trailing: Text('1'),
                  ),
                ),
              ] else ...[
                if (role == 'Donor') ...[
                  FilledButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Donation'),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddDonationScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                Text(
                  role == 'Donor' ? 'My Donations' : 'Available Donations',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                for (final food in ['Cooked Rice', 'Fresh Bread'])
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text('10 portions • Islamabad'),
                          const SizedBox(height: 4),
                          const Text(
                            'Available',
                            style: TextStyle(color: Color(0xFF16845B)),
                          ),
                          if (role == 'NGO')
                            TextButton(
                              onPressed: () => ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Pickup preview only. No request was sent.',
                                      ),
                                    ),
                                  ),
                              child: const Text('Request Pickup'),
                            ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                const Text(
                  'Pickup Requests',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.local_shipping_outlined),
                    title: Text('Community Kitchen'),
                    subtitle: Text('Cooked Rice • Pending (sample)'),
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
