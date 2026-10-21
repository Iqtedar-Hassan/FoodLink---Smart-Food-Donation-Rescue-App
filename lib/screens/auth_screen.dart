import 'package:flutter/material.dart';

import 'dashboard_screen.dart';

// This form only previews navigation. It does not create or check accounts.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.role = 'Donor', this.isSignup = false});

  final String role;
  final bool isSignup;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late String selectedRole;

  @override
  void initState() {
    super.initState();
    selectedRole = widget.role;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isSignup ? 'Sign Up' : 'Log In')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SizedBox(
            width: 440,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFFE7F4ED),
                  foregroundColor: Color(0xFF16845B),
                  child: Icon(Icons.volunteer_activism),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.isSignup ? 'Create your account' : 'Welcome back',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.isSignup
                      ? 'Join FoodLink as a ${widget.role}.'
                      : 'Sign in to preview your FoodLink dashboard.',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),
                if (widget.isSignup)
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.badge_outlined,
                        color: Color(0xFF16845B),
                      ),
                      title: const Text('Account type'),
                      subtitle: Text(widget.role),
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: [
                      for (final role in ['Donor', 'NGO', 'Admin'])
                        DropdownMenuItem(value: role, child: Text(role)),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => selectedRole = value);
                    },
                  ),
                const SizedBox(height: 16),
                if (widget.isSignup) ...[
                  const TextField(
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Full name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                const TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DashboardScreen(role: selectedRole),
                    ),
                    (route) => route.isFirst,
                  ),
                  child: const Text('View Demo'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Demo only. No account is checked or created.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
