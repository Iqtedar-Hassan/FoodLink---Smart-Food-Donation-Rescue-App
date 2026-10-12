import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
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
  final _deadlineController = TextEditingController();
  final _pickupStartController = TextEditingController();
  final _pickupEndController = TextEditingController();

  String? _selectedCategory;
  String? _selectedUnit;
  DateTime? _safeDeadline;
  DateTime? _pickupStart;
  DateTime? _pickupEnd;

  bool get _isEditing => widget.donationId != null;

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
      _deadlineController.text = DateTimeUtils.formatForDisplay(
        donation.safeUseDeadline,
      );
      _pickupStartController.text = DateTimeUtils.formatForDisplay(
        donation.pickupStart,
      );
      _pickupEndController.text = DateTimeUtils.formatForDisplay(
        donation.pickupEnd,
      );
    }
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _quantityController.dispose();
    _pickupAreaController.dispose();
    _pickupAddressController.dispose();
    _notesController.dispose();
    _deadlineController.dispose();
    _pickupStartController.dispose();
    _pickupEndController.dispose();
    super.dispose();
  }

  bool get _formHasContent {
    return _foodNameController.text.trim().isNotEmpty ||
        _quantityController.text.trim().isNotEmpty ||
        _pickupAreaController.text.trim().isNotEmpty ||
        _pickupAddressController.text.trim().isNotEmpty ||
        _notesController.text.trim().isNotEmpty ||
        _selectedCategory != null ||
        _selectedUnit != null;
  }

  Future<void> _confirmCancel() async {
    if (_isEditing || !_formHasContent) {
      Navigator.of(context).pop();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard this donation?'),
        content: const Text('The information you entered will not be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickDateTime({
    required void Function(DateTime selected) onSelected,
    required DateTime? initialValue,
  }) async {
    if (!mounted) return;

    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initialValue ?? now.add(const Duration(hours: 2)),
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (!mounted || date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialValue ?? now),
    );
    if (!mounted || time == null) return;

    onSelected(
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final existing = _isEditing
        ? widget.repository.donationById(widget.donationId!)
        : null;

    if (_isEditing && existing == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donation could not be found.')),
      );
      return;
    }

    if (_isEditing &&
        existing!.status != DonationStatus.available &&
        existing.status != DonationStatus.reserved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'A ${existing.status.label.toLowerCase()} donation can no longer be edited.',
          ),
        ),
      );
      return;
    }

    if (_isEditing) {
      // copyWith preserves id, donorId, createdAt and current status.
      widget.repository.updateDonation(
        existing!.copyWith(
          foodName: _foodNameController.text.trim(),
          category: _selectedCategory ?? existing.category,
          quantity: num.parse(_quantityController.text.trim()),
          quantityUnit: _selectedUnit ?? existing.quantityUnit,
          safeUseDeadline: _safeDeadline ?? existing.safeUseDeadline,
          pickupStart: _pickupStart ?? existing.pickupStart,
          pickupEnd: _pickupEnd ?? existing.pickupEnd,
          pickupArea: _pickupAreaController.text.trim(),
          pickupAddress: _pickupAddressController.text.trim(),
          notes: _notesController.text.trim(),
        ),
      );
    } else {
      widget.repository.createDonation(
        FoodDonation(
          id: widget.repository.generateDonationId(),
          donorId: widget.repository.currentDonor?.id ?? 'guest',
          foodName: _foodNameController.text.trim(),
          category: _selectedCategory ?? '',
          quantity: num.parse(_quantityController.text.trim()),
          quantityUnit: _selectedUnit ?? '',
          safeUseDeadline: _safeDeadline ?? DateTime.now(),
          pickupStart: _pickupStart ?? DateTime.now(),
          pickupEnd: _pickupEnd ?? DateTime.now(),
          pickupArea: _pickupAreaController.text.trim(),
          pickupAddress: _pickupAddressController.text.trim(),
          notes: _notesController.text.trim(),
          createdAt: DateTime.now(),
          status: DonationStatus.available,
        ),
      );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditing
              ? 'Donation updated successfully.'
              : 'Donation published successfully.',
        ),
      ),
    );

    if (_isEditing) {
      Navigator.of(context).pop();
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/my-donations', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Donation' : 'Create Donation'),
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
                      _isEditing
                          ? 'Update your donation'
                          : 'Share your surplus food',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add the food item, safe-use deadline, and pickup window so NGOs know when to collect.',
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
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Food name',
                        hintText: 'e.g. Chicken Rice Bowl',
                        prefixIcon: Icon(Icons.restaurant_menu_outlined),
                      ),
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
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: AppConstants.foodCategories.map((option) {
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                              hintText: 'e.g. 12',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Quantity is required.';
                              }
                              final parsed = num.tryParse(value.trim());
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
                            items: AppConstants.quantityUnits.map((option) {
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
                    const SizedBox(height: 6),
                    Text(
                      'Earlier safe-use deadlines are highlighted so NGOs can prioritise collections.',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: AppColors.secondaryText),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      readOnly: true,
                      controller: _deadlineController,
                      decoration: const InputDecoration(
                        labelText: 'Safe-use deadline',
                        helperText: 'Until when is this food safe to use?',
                        helperStyle: TextStyle(color: AppColors.secondaryText),
                        prefixIcon: Icon(Icons.event_available_outlined),
                        errorMaxLines: 2,
                      ),
                      onTap: () => _pickDateTime(
                        initialValue: _safeDeadline,
                        onSelected: (picked) {
                          setState(() {
                            _safeDeadline = picked;
                            _deadlineController.text =
                                DateTimeUtils.formatForDisplay(picked);
                          });
                        },
                      ),
                      validator: (value) {
                        if (_safeDeadline == null) {
                          return 'Safe-use deadline is required.';
                        }
                        if (DateTimeUtils.isPastDeadline(_safeDeadline!)) {
                          return 'Safe-use deadline must be in the future.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            readOnly: true,
                            controller: _pickupStartController,
                            decoration: const InputDecoration(
                              labelText: 'Pickup start',
                              errorMaxLines: 2,
                            ),
                            onTap: () => _pickDateTime(
                              initialValue: _pickupStart,
                              onSelected: (picked) {
                                setState(() {
                                  _pickupStart = picked;
                                  _pickupStartController.text =
                                      DateTimeUtils.formatForDisplay(picked);
                                });
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
                            controller: _pickupEndController,
                            decoration: const InputDecoration(
                              labelText: 'Pickup end',
                              errorMaxLines: 2,
                            ),
                            onTap: () => _pickDateTime(
                              initialValue: _pickupEnd,
                              onSelected: (picked) {
                                setState(() {
                                  _pickupEnd = picked;
                                  _pickupEndController.text =
                                      DateTimeUtils.formatForDisplay(picked);
                                });
                              },
                            ),
                            validator: (value) {
                              if (_pickupEnd == null) {
                                return 'Pickup end is required.';
                              }
                              if (_pickupStart != null &&
                                  !_pickupEnd!.isAfter(_pickupStart!)) {
                                return 'Pickup end must be after pickup start.';
                              }
                              if (_safeDeadline != null &&
                                  _pickupEnd!.isAfter(_safeDeadline!)) {
                                return 'Pickup must end before the safe-use deadline.';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Pickup Location',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _pickupAreaController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'General pickup area',
                        hintText: 'e.g. G-11 Markaz',
                        prefixIcon: Icon(Icons.location_on_outlined),
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
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Pickup address',
                        hintText: 'Street, building, or landmark details',
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
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Additional notes (optional)',
                        hintText: 'Packing, storage, or handling details',
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Brief responsibility reminder required by the project
                    // document. FoodLink never certifies food safety.
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.lightAmber,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.warningAmber.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.health_and_safety_outlined,
                            size: 18,
                            color: AppColors.warningAmber,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Food safety reminder: only share food you know '
                              'is safe to eat and provide accurate deadline '
                              'information. FoodLink does not verify food safety.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.primaryText,
                                    height: 1.4,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: Icon(
                          _isEditing ? Icons.save_outlined : Icons.publish,
                        ),
                        label: Text(
                          _isEditing ? 'Save Changes' : 'Publish Donation',
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _confirmCancel,
                        child: const Text('Cancel'),
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
