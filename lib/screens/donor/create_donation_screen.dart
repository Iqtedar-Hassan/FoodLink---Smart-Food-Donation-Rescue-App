import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_time_utils.dart';
import '../../data/repositories/local_donation_repository.dart';
import '../../models/food_donation.dart';

class CreateDonationScreen extends StatefulWidget {
  const CreateDonationScreen({
    super.key,
    required this.repository,
    this.donationId,
  });

  final FoodLinkRepository repository;
  final String? donationId;

  @override
  State<CreateDonationScreen> createState() => _CreateDonationScreenState();
}

class _CreateDonationScreenState extends State<CreateDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _foodNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _pickupAreaController = TextEditingController();
  final _pickupAddressController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedCategory;
  String? _selectedUnit;
  DateTime? _safeDeadline;
  DateTime? _pickupStart;
  DateTime? _pickupEnd;

  @override
  void initState() {
    super.initState();
    final donation = widget.donationId == null
        ? null
        : widget.repository.donationById(widget.donationId!);

    if (donation != null) {
      _foodNameController.text = donation.foodName;
      _quantityController.text = donation.quantity.toString();
      _pickupAreaController.text = donation.pickupArea;
      _pickupAddressController.text = donation.pickupAddress;
      _notesController.text = donation.notes;
      _selectedCategory = donation.category;
      _selectedUnit = donation.quantityUnit;
      _safeDeadline = donation.safeUseDeadline;
      _pickupStart = donation.pickupStart;
      _pickupEnd = donation.pickupEnd;
    }
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _quantityController.dispose();
    _pickupAreaController.dispose();
    _pickupAddressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({
    required void Function(DateTime selected) onDateSelected,
    required DateTime? initialValue,
  }) async {
    if (!mounted) return;

    final date = await showDatePicker(
      context: context,
      initialDate: initialValue ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (!mounted || date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialValue ?? date),
    );
    if (!mounted || time == null) return;

    onDateSelected(
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (widget.donationId != null) {
      final existing = widget.repository.donationById(widget.donationId!);
      if (existing == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Donation could not be found.')),
        );
        return;
      }
      if (existing.status != DonationStatus.available &&
          existing.status != DonationStatus.reserved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This donation cannot be edited in its current status.',
            ),
          ),
        );
        return;
      }
    }

    final donationId =
        widget.donationId ?? widget.repository.generateDonationId();
    final donation = FoodDonation(
      id: donationId,
      donorId: widget.repository.currentDonor?.id ?? 'guest',
      foodName: _foodNameController.text.trim(),
      category: _selectedCategory ?? '',
      quantity: num.parse(_quantityController.text),
      quantityUnit: _selectedUnit ?? '',
      safeUseDeadline: _safeDeadline ?? DateTime.now(),
      pickupStart: _pickupStart ?? DateTime.now(),
      pickupEnd: _pickupEnd ?? DateTime.now(),
      pickupArea: _pickupAreaController.text.trim(),
      pickupAddress: _pickupAddressController.text.trim(),
      notes: _notesController.text.trim(),
      createdAt: widget.donationId == null
          ? DateTime.now()
          : (widget.repository.donationById(widget.donationId!)?.createdAt ??
                DateTime.now()),
      status: widget.donationId == null
          ? DonationStatus.available
          : (widget.repository.donationById(widget.donationId!)?.status ??
                DonationStatus.available),
    );

    if (widget.donationId == null) {
      widget.repository.createDonation(donation);
    } else {
      widget.repository.updateDonation(donation);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.donationId == null
              ? 'Donation published successfully.'
              : 'Donation updated successfully.',
        ),
      ),
    );
    Navigator.pushNamedAndRemoveUntil(context, '/my-donations', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.donationId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Donation' : 'Create Donation'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing
                          ? 'Update your donation'
                          : 'Share your surplus food',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add the food item, pickup schedule, and delivery details.',
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: AppColors.secondaryText),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Food Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _foodNameController,
                      decoration: const InputDecoration(labelText: 'Food name'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Food name is required.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Food category',
                      ),
                      items:
                          const [
                            'Cooked Meals',
                            'Bakery Items',
                            'Fruits',
                            'Vegetables',
                            'Dairy Products',
                            'Packaged Food',
                            'Other',
                          ].map((option) {
                            return DropdownMenuItem(
                              value: option,
                              child: Text(option),
                            );
                          }).toList(),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please choose a category.'
                          : null,
                      onChanged: (value) =>
                          setState(() => _selectedCategory = value),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Quantity is required.';
                              }
                              final parsed = num.tryParse(value);
                              if (parsed == null || parsed <= 0) {
                                return 'Quantity must be greater than zero.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedUnit,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                            ),
                            items:
                                const [
                                  'Portions',
                                  'Kilograms',
                                  'Grams',
                                  'Boxes',
                                  'Packs',
                                  'Litres',
                                  'Items',
                                ].map((option) {
                                  return DropdownMenuItem(
                                    value: option,
                                    child: Text(option),
                                  );
                                }).toList(),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Select a unit.'
                                : null,
                            onChanged: (value) =>
                                setState(() => _selectedUnit = value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Deadline and Pickup',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      readOnly: true,
                      controller: TextEditingController(
                        text: _safeDeadline == null
                            ? ''
                            : DateTimeUtils.formatForDisplay(_safeDeadline!),
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Safe-use deadline',
                      ),
                      onTap: () => _pickDateTime(
                        initialValue: _safeDeadline,
                        onDateSelected: (picked) {
                          setState(() => _safeDeadline = picked);
                        },
                      ),
                      validator: (value) {
                        if (_safeDeadline == null) {
                          return 'Safe-use deadline is required.';
                        }
                        if (_safeDeadline!.isBefore(DateTime.now()) ||
                            _safeDeadline!.isAtSameMomentAs(DateTime.now())) {
                          return 'Safe-use deadline must be in the future.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            readOnly: true,
                            controller: TextEditingController(
                              text: _pickupStart == null
                                  ? ''
                                  : DateTimeUtils.formatForDisplay(
                                      _pickupStart!,
                                    ),
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Pickup start',
                            ),
                            onTap: () => _pickDateTime(
                              initialValue: _pickupStart,
                              onDateSelected: (picked) {
                                setState(() => _pickupStart = picked);
                              },
                            ),
                            validator: (value) {
                              if (_pickupStart == null) {
                                return 'Pickup start is required.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            readOnly: true,
                            controller: TextEditingController(
                              text: _pickupEnd == null
                                  ? ''
                                  : DateTimeUtils.formatForDisplay(_pickupEnd!),
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Pickup end',
                            ),
                            onTap: () => _pickDateTime(
                              initialValue: _pickupEnd,
                              onDateSelected: (picked) {
                                setState(() => _pickupEnd = picked);
                              },
                            ),
                            validator: (value) {
                              if (_pickupEnd == null) {
                                return 'Pickup end is required.';
                              }
                              if (_pickupStart != null &&
                                  _pickupEnd!.isBefore(_pickupStart!)) {
                                return 'Pickup end must be after pickup start.';
                              }
                              if (_safeDeadline != null &&
                                  _pickupEnd!.isAfter(_safeDeadline!)) {
                                return 'Pickup availability must end before the safe-use deadline.';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pickupAreaController,
                      decoration: const InputDecoration(
                        labelText: 'General pickup area',
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Pickup area is required.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pickupAddressController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Pickup address',
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Pickup address is required.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Additional notes (optional)',
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: Text(
                          isEditing ? 'Save Changes' : 'Publish Donation',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
