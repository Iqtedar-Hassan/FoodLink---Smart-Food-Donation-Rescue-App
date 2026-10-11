import 'package:flutter/material.dart';

import 'add_donation_screen.dart';
import 'my_donations_screen.dart';
import 'pickup_requests_screen.dart';

class DonorDashboard extends StatelessWidget {
  const DonorDashboard({super.key});

  static const Color green = Color(0xFF16845B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        backgroundColor: green,
        foregroundColor: Colors.white,
        title: const Text('FoodLink - Donor'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome, Donor!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Share extra food and help your community.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 120,
                child: Card(
                  color: const Color(0xFFE2F4E9),
                  child: const Padding(
                    padding: EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Icon(Icons.volunteer_activism, size: 45, color: green),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rescue Food',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: green,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text('Your extra food can help others.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'What would you like to do?',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              _DashboardButton(
                icon: Icons.add_circle_outline,
                title: 'Add Food Donation',
                subtitle: 'Share available food with NGOs',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddDonationScreen(),
                    ),
                  );
                },
              ),

              _DashboardButton(
                icon: Icons.inventory_2_outlined,
                title: 'My Donations',
                subtitle: 'View your food donations',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MyDonationsScreen(),
                    ),
                  );
                },
              ),

              _DashboardButton(
                icon: Icons.notifications_active_outlined,
                title: 'Pickup Requests',
                subtitle: 'Check requests from NGOs',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PickupRequestsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String title) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$title will be available soon.')));
  }
}

class _DashboardButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DashboardButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Icon(icon, color: const Color(0xFF16845B), size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
