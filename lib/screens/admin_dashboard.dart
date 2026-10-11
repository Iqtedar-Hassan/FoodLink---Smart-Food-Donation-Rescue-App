import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  static const Color green = Color(0xFF16845B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        title: const Text('FoodLink - Admin'),
        backgroundColor: green,
        foregroundColor: Colors.white,
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
