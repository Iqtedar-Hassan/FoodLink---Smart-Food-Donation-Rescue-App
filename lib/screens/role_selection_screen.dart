import 'package:flutter/material.dart';

import '../data/repositories/local_donation_repository.dart';
import '../screens/auth/login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key, required this.repository});

  final FoodLinkRepository repository;

  static const Color primaryGreen = Color(0xFF16845B);
  static const Color darkGreen = Color(0xFF105C40);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FAF8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Choose Your Role',
          style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1F3E9),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(
                      Icons.volunteer_activism,
                      size: 54,
                      color: primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'How would you like to help?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Choose your role to continue with FoodLink '
                    'and help reduce food waste in your community.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _RoleCard(
                    icon: Icons.storefront_outlined,
                    title: 'Food Donor',
                    description:
                        'Donate surplus food from your home, '
                        'restaurant, bakery or shop.',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoginScreen(repository: repository),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _RoleCard(
                    icon: Icons.volunteer_activism_outlined,
                    title: 'NGO / Welfare Organization',
                    description:
                        'Discover available food donations and '
                        'request pickups for people in need.',
                    onTap: () => _showRoleMessage(context, 'NGO'),
                  ),
                  const SizedBox(height: 16),
                  _RoleCard(
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Administrator',
                    description:
                        'Monitor users, donations and '
                        'overall platform activity.',
                    onTap: () => _showRoleMessage(context, 'Administrator'),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Together, we can rescue food and reduce waste.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: primaryGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void _showRoleMessage(BuildContext context, String role) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$role selected'),
        backgroundColor: darkGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  static const Color primaryGreen = Color(0xFF16845B);
  static const Color darkGreen = Color(0xFF105C40);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFDCEBE1)),
          ),
          child: Row(
            children: [
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F5EC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 30, color: primaryGreen),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                size: 17,
                color: primaryGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
