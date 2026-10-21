import 'package:flutter/material.dart';

class AddDonationScreen extends StatelessWidget {
  const AddDonationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Donation')),
      body: Center(
        child: SizedBox(
          width: 440,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Share your surplus food',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Form preview only. Donations are not saved.'),
              const SizedBox(height: 24),
              const TextField(
                decoration: InputDecoration(labelText: 'Food name'),
              ),
              const SizedBox(height: 16),
              const TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Quantity (portions)'),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(labelText: 'Pickup address'),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Safe-use date',
                  hintText: 'For example: 25 October, 6 PM',
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                maxLines: 3,
                decoration: InputDecoration(labelText: 'Notes'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('UI preview complete. Nothing was saved.'),
                  ),
                ),
                child: const Text('Preview Donation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
