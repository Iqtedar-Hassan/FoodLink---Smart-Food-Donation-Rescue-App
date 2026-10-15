import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_time_utils.dart';
import '../../core/utils/validators.dart';
import '../../data/repositories/local_donation_repository.dart';
import '../../models/food_donation.dart';
import '../../widgets/common/app_text_field.dart';

// Brand palette (consistent with all other screens)
const Color _green = AppColors.primaryGreen;
const Color _background = AppColors.warmBackground;
const Color _textPrimary = Color(0xFF19352A);
const Color _textSecondary = Color(0xFF738178);
const Color _border = Color(0xFFE8EDE8);

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
      builder: (_) => const _ConfirmDialog(
        title: 'Discard this donation?',
        body: 'The information you entered will not be saved.',
        confirmLabel: 'Discard',
        confirmColor: Color(0xFFCB4A4A),
        icon: Icons.delete_outline_rounded,
        iconColor: Color(0xFFCB4A4A),
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
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final existing = _isEditing
        ? widget.repository.donationById(widget.donationId!)
        : null;

    if (_isEditing && existing == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Donation could not be found.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
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
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
      return;
    }

    if (_isEditing) {
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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final margin = AppTheme.horizontalMargin(screenWidth);

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 64,
        titleSpacing: 20,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: _green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                _isEditing ? 'Edit Donation' : 'Add Food Donation',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: _textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppTheme.contentMaxWidth(screenWidth),
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(margin, 12, margin, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header copy
                    Text(
                      _isEditing
                          ? 'Update your donation'
                          : 'Share your surplus food',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Add the food item, safe-use deadline, and pickup window '
                      'so NGOs know when to collect it.',
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Section 1: Food information
                    _SectionHeader(number: '1', title: 'Food information'),
                    const SizedBox(height: 12),
                    _SectionCard(
                      children: [
                        AppTextField(
                          controller: _foodNameController,
                          label: 'Food name',
                          hint: 'e.g. Chicken Rice Bowl',
                          prefixIcon: const Icon(
                            Icons.restaurant_menu_outlined,
                          ),
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Food name is required.'
                              : null,
                        ),
                        const SizedBox(height: AppTheme.spaceLg),
                        _DropdownField(
                          initialValue: _selectedCategory,
                          labelText: 'Food category',
                          prefixIcon: Icons.category_outlined,
                          items: AppConstants.foodCategories,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please choose a category.'
                              : null,
                          onChanged: (value) =>
                              setState(() => _selectedCategory = value),
                        ),
                        const SizedBox(height: AppTheme.spaceLg),
                        _TwoColumn(
                          first: AppTextField(
                            controller: _quantityController,
                            label: 'Quantity',
                            hint: 'e.g. 12',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.next,
                            validator: Validators.validatePositiveFiniteNumber,
                          ),
                          second: _DropdownField(
                            initialValue: _selectedUnit,
                            labelText: 'Unit',
                            items: AppConstants.quantityUnits,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Select a unit.'
                                : null,
                            onChanged: (value) =>
                                setState(() => _selectedUnit = value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Section 2: Deadline and pickup
                    _SectionHeader(
                      number: '2',
                      title: 'Deadline and pickup',
                      subtitle: 'Nearby deadlines are highlighted so NGOs can act fast.',
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      children: [
                        AppTextField(
                          controller: _deadlineController,
                          label: 'Safe-use deadline',
                          hint: 'Select date and time',
                          prefixIcon: const Icon(
                            Icons.event_available_outlined,
                          ),
                          helperText: 'Until when is this food safe to use?',
                          readOnly: true,
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
                              return 'Deadline must be in the future.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppTheme.spaceLg),
                        _TwoColumn(
                          first: AppTextField(
                            controller: _pickupStartController,
                            label: 'Pickup start',
                            hint: 'Select',
                            readOnly: true,
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
                            validator: (value) => _pickupStart == null
                                ? 'Pickup start is required.'
                                : !_pickupStart!.isAfter(DateTime.now())
                                ? 'Pickup start must be in the future.'
                                : null,
                          ),
                          second: AppTextField(
                            controller: _pickupEndController,
                            label: 'Pickup end',
                            hint: 'Select',
                            readOnly: true,
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
                                return 'End must be after start.';
                              }
                              if (_safeDeadline != null &&
                                  _pickupEnd!.isAfter(_safeDeadline!)) {
                                return 'Pickup must end before the deadline.';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Section 3: Pickup location
                    _SectionHeader(number: '3', title: 'Pickup location'),
                    const SizedBox(height: 12),
                    _SectionCard(
                      children: [
                        AppTextField(
                          controller: _pickupAreaController,
                          label: 'General pickup area',
                          hint: 'e.g. G-11 Markaz',
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Pickup area is required.'
                              : null,
                        ),
                        const SizedBox(height: AppTheme.spaceLg),
                        AppTextField(
                          controller: _pickupAddressController,
                          label: 'Pickup address',
                          hint: 'Street, building, or landmark details',
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          maxLines: 2,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Pickup address is required.'
                              : null,
                        ),
                        const SizedBox(height: AppTheme.spaceLg),
                        AppTextField(
                          controller: _notesController,
                          label: 'Additional notes (optional)',
                          hint: 'Packing, storage, or handling details',
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: 3,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Safety reminder
                    const _SafetyReminder(),
                    const SizedBox(height: 20),

                    // Submit button (gradient)
                    _SubmitButton(
                      label: _isEditing ? 'Save Changes' : 'Publish Donation',
                      icon: _isEditing ? Icons.save_outlined : Icons.publish,
                      onTap: _submit,
                    ),
                    const SizedBox(height: 10),
                    _CancelButton(onTap: _confirmCancel),
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

// ============================================================
// SECTION HEADER (with numbered green badge)
// ============================================================
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.number,
    required this.title,
    this.subtitle,
  });

  final String number;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 28,
          width: 28,
          decoration: BoxDecoration(
            color: _green,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// SECTION CARD (kept simple, just shadows added)
// ============================================================
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

// ============================================================
// DROPDOWN FIELD (consistent with AppTextField style)
// ============================================================
class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.initialValue,
    required this.labelText,
    required this.items,
    required this.validator,
    required this.onChanged,
    this.prefixIcon,
  });

  final String? initialValue;
  final String labelText;
  final List<String> items;
  final String? Function(String?) validator;
  final void Function(String?) onChanged;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border, width: 1.2),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: initialValue,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        items: items
            .map(
              (option) => DropdownMenuItem(
                value: option,
                child: Text(option, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }
}

// ============================================================
// TWO-COLUMN (responsive)
// ============================================================
class _TwoColumn extends StatelessWidget {
  const _TwoColumn({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < AppTheme.compactPhoneMax) {
      return Column(
        children: [
          first,
          const SizedBox(height: AppTheme.spaceLg),
          second,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        const SizedBox(width: AppTheme.spaceMd),
        Expanded(child: second),
      ],
    );
  }
}

// ============================================================
// SAFETY REMINDER (kept similar, slight restyle)
// ============================================================
class _SafetyReminder extends StatelessWidget {
  const _SafetyReminder();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF4E6C7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFD58A19).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.health_and_safety_outlined,
              size: 18,
              color: Color(0xFFD58A19),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Food safety reminder',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF594719),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Only share food you know is safe to eat and give accurate '
                  'deadline information. FoodLink does not verify food safety.',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF806E48),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SUBMIT BUTTON (gradient green, with shadow)
// ============================================================
class _SubmitButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SubmitButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: _green,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _green.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CANCEL BUTTON (outline gray)
// ============================================================
class _CancelButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CancelButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border, width: 1.2),
            ),
            child: const Center(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CONFIRM DIALOG (cancel discard)
// ============================================================
class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;
  final Color iconColor;
  final String confirmLabel;
  final Color confirmColor;

  const _ConfirmDialog({
    required this.title,
    required this.body,
    required this.icon,
    required this.iconColor,
    required this.confirmLabel,
    required this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: TextStyle(
                fontSize: 13,
                color: _textPrimary.withValues(alpha: 0.7),
                height: 1.55,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      foregroundColor: _textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: _border),
                      ),
                    ),
                    child: const Text(
                      'Keep editing',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Material(
                    color: confirmColor,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => Navigator.pop(context, true),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: confirmColor.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Text(
                          confirmLabel,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
