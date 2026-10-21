import 'package:flutter/material.dart';

import 'auth_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Your Role')),
      body: Center(
        child: SizedBox(
          width: 500,
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'How would you like to help?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose the option that best describes you.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 20),
              for (final role in ['Donor', 'NGO', 'Admin'])
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFE7F4ED),
                        foregroundColor: const Color(0xFF16845B),
                        child: Icon(_roleIcon(role)),
                      ),
                      title: Text(
                        role,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(_roleDescription(role)),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AuthScreen(
                            role: role,
                            isSignup: role != 'Admin',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _roleIcon(String role) {
    if (role == 'Donor') return Icons.restaurant;
    if (role == 'NGO') return Icons.favorite_outline;
    return Icons.admin_panel_settings;
  }

  String _roleDescription(String role) {
    if (role == 'Donor') return 'Share your surplus food';
    if (role == 'NGO') return 'Find food for your community';
    return 'View FoodLink activity';
  }
}
