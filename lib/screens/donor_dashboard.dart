import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../widgets/common/app_card.dart';

class DonorDashboard extends StatelessWidget {
  const DonorDashboard({super.key});

  static const Color green = AppColors.primaryGreen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmBackground,
      appBar: AppBar(
        backgroundColor: AppColors.warmBackground,
        foregroundColor: AppColors.primaryText,
        title: const Text('FoodLink - Donor'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.pagePadding),
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

              const AppCard(
                margin: EdgeInsets.zero,
                padding: EdgeInsets.all(18),
                child: Padding(
                  padding: EdgeInsets.zero,
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
                  _showMessage(context, 'Add Food Donation');
                },
              ),

              _DashboardButton(
                icon: Icons.inventory_2_outlined,
                title: 'My Donations',
                subtitle: 'View your food donations',
                onTap: () {
                  _showMessage(context, 'My Donations');
                },
              ),

              _DashboardButton(
                icon: Icons.notifications_active_outlined,
                title: 'Pickup Requests',
                subtitle: 'Check requests from NGOs',
                onTap: () {
                  _showMessage(context, 'Pickup Requests');
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
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppTheme.cardPadding),
        leading: Icon(icon, color: const Color(0xFF16845B), size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
