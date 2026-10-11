import 'package:flutter/material.dart';

import '../models/donation_model.dart';
import '../services/donation_service.dart';

class AddDonationScreen extends StatefulWidget {
  const AddDonationScreen({super.key});

  @override
  State<AddDonationScreen> createState() => _AddDonationScreenState();
}

class _AddDonationScreenState extends State<AddDonationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _foodNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _locationController = TextEditingController();

  String _foodType = 'Cooked Food';
  DateTime? _expiryDate;

  @override
  void dispose() {
    _foodNameController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate() async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );

    if (selectedDate != null && mounted) {
      setState(() {
        _expiryDate = selectedDate;
      });
    }
  }

  void _submitDonation() {
    if (!_formKey.currentState!.validate()) return;

    if (_expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a safe-use date.')),
      );
      return;
    }

    final donation = Donation(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      foodName: _foodNameController.text.trim(),
      foodType: _foodType,
      quantity: int.parse(_quantityController.text.trim()),
      location: _locationController.text.trim(),
      safeUseDate: _expiryDate!,
    );

    DonationService.addDonation(donation);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Food donation added successfully!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF16845B);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        title: const Text('Add Food Donation'),
        backgroundColor: green,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Share Surplus Food',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter the details of food you want to donate.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _foodNameController,
                    decoration: const InputDecoration(
                      labelText: 'Food Name',
                      hintText: 'e.g. Rice, Bread, Vegetables',
                      prefixIcon: Icon(Icons.restaurant),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the food name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  DropdownButtonFormField<String>(
                    value: _foodType,
                    decoration: const InputDecoration(
                      labelText: 'Food Type',
                      prefixIcon: Icon(Icons.category_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Cooked Food',
                        child: Text('Cooked Food'),
                      ),
                      DropdownMenuItem(value: 'Bakery', child: Text('Bakery')),
                      DropdownMenuItem(
                        value: 'Fruits and Vegetables',
                        child: Text('Fruits and Vegetables'),
                      ),
                      DropdownMenuItem(
                        value: 'Packaged Food',
                        child: Text('Packaged Food'),
                      ),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _foodType = value;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 18),

                  TextFormField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity (servings)',
                      hintText: 'e.g. 10',
                      prefixIcon: Icon(Icons.scale_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final quantity = int.tryParse(value ?? '');

                      if (quantity == null || quantity <= 0) {
                        return 'Enter a quantity greater than zero';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Pickup Location',
                      hintText: 'Enter area or address',
                      prefixIcon: Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the pickup location';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  OutlinedButton.icon(
                    onPressed: _selectExpiryDate,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(
                      _expiryDate == null
                          ? 'Select Safe-Use Date'
                          : 'Selected: ${_expiryDate!.day}/'
                                '${_expiryDate!.month}/'
                                '${_expiryDate!.year}',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: green,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _submitDonation,
                      icon: const Icon(Icons.volunteer_activism),
                      label: const Text(
                        'Submit Donation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: Colors.white,
                      ),
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
}
