import 'package:flutter/material.dart';

import '../data/repositories/local_donation_repository.dart';
import '../models/user_role.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key, required this.repository});

  final FoodLinkRepository repository;

  static const Color green = Color(0xFF16845B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        title: const Text('FoodLink - Admin'),
        backgroundColor: green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: () {
              repository.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (_) => false,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Administrator Dashboard',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: green,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Monitor FoodLink activity from one place.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),

            const Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Users',
                    value: '12',
                    icon: Icons.people_outline,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: 'Donations',
                    value: '8',
                    icon: Icons.restaurant_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Pending',
                    value: '3',
                    icon: Icons.pending_actions,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: 'Collected',
                    value: '5',
                    icon: Icons.check_circle_outline,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            const Text(
              'Administration',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _AdminOption(
              icon: Icons.person_add_alt_1_outlined,
              title: 'Create Admin Account',
              subtitle: 'Add an administrator for this app session',
              onTap: () => _showCreateAdminDialog(context),
            ),

            _AdminOption(
              icon: Icons.people_outline,
              title: 'Manage Users',
              subtitle: 'View donor and NGO accounts',
              onTap: () => _showMessage(context, 'Manage Users'),
            ),

            _AdminOption(
              icon: Icons.inventory_2_outlined,
              title: 'Manage Donations',
              subtitle: 'Review food donation activity',
              onTap: () => _showMessage(context, 'Manage Donations'),
            ),

            _AdminOption(
              icon: Icons.bar_chart_outlined,
              title: 'Reports',
              subtitle: 'View platform activity summary',
              onTap: () => _showMessage(context, 'Reports'),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature will be available soon.')));
  }

  Future<void> _showCreateAdminDialog(BuildContext context) async {
    if (repository.currentDonor?.role != UserRole.admin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only an administrator can create accounts.'),
        ),
      );
      return;
    }

    final account = await showDialog<_AdminAccountDetails>(
      context: context,
      builder: (_) => const _CreateAdminDialog(),
    );
    if (account == null || !context.mounted) return;

    try {
      repository.createAdminAccount(
        fullName: account.fullName,
        email: account.email,
        phone: account.phone,
        password: account.password,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Admin account created.')));
    } on StateError catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}

class _AdminAccountDetails {
  const _AdminAccountDetails({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
  });

  final String fullName;
  final String email;
  final String phone;
  final String password;
}

class _CreateAdminDialog extends StatefulWidget {
  const _CreateAdminDialog();

  @override
  State<_CreateAdminDialog> createState() => _CreateAdminDialogState();
}

class _CreateAdminDialogState extends State<_CreateAdminDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required.' : null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Admin Account'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: _required,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: _required,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: _required,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: _required,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              _AdminAccountDetails(
                fullName: _nameController.text,
                email: _emailController.text,
                phone: _phoneController.text,
                password: _passwordController.text,
              ),
            );
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF16845B), size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminOption({
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
        leading: Icon(icon, color: const Color(0xFF16845B), size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
