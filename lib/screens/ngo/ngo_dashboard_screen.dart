import 'package:flutter/material.dart';

import '../../data/repositories/local_donation_repository.dart';
import '../../models/donor.dart';
import '../../models/food_donation.dart';
import '../../models/pickup_request.dart';

class NgoDashboardScreen extends StatelessWidget {
  const NgoDashboardScreen({super.key, required this.repository});

  final FoodLinkRepository repository;

  static const green = Color(0xFF16845B);
  static const background = Color(0xFFF5F8F6);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final user = repository.currentDonor;

        final donations = repository.ngoAvailableDonations;
        final requests = repository.currentNgoPickupRequests;

        final pending = requests
            .where((r) => r.status == PickupRequestStatus.pending)
            .length;

        final approved = requests
            .where((r) => r.status == PickupRequestStatus.approved)
            .length;
        final activeDonationIds = requests
            .where(
              (request) =>
                  request.status == PickupRequestStatus.pending ||
                  request.status == PickupRequestStatus.approved,
            )
            .map((request) => request.donationId)
            .toSet();

        return Scaffold(
          backgroundColor: background,
          appBar: AppBar(
            backgroundColor: green,
            foregroundColor: Colors.white,
            title: const Text(
              'FoodLink NGO',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Welcome, ${user?.fullName ?? 'NGO'}!',
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Find available food and help your community.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 22),
                  if (user != null) ...[
                    _NgoProfileEditor(
                      key: ValueKey(user.id),
                      repository: repository,
                      user: user,
                    ),
                    const SizedBox(height: 16),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Available Food',
                          value: '${donations.length}',
                          icon: Icons.restaurant,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Pending',
                          value: '$pending',
                          icon: Icons.hourglass_top,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Approved',
                          value: '$approved',
                          icon: Icons.check_circle_outline,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),
                  const Text(
                    'Available Donations',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  if (donations.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No available donations at the moment.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ...donations.map(
                      (donation) => _DonationCard(
                        donation: donation,
                        alreadyRequested: activeDonationIds.contains(
                          donation.id,
                        ),
                        onRequest: () {
                          try {
                            repository.requestPickup(donation.id);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Pickup request submitted successfully.',
                                ),
                              ),
                            );
                          } on StateError catch (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  error.toString().replaceFirst(
                                    'Bad state: ',
                                    '',
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),

                  const SizedBox(height: 28),
                  const Text(
                    'My Pickup Requests',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  if (requests.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'You have not requested any donations yet.',
                        ),
                      ),
                    )
                  else
                    ...requests.map((request) {
                      final donation = repository.donationById(
                        request.donationId,
                      );

                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE4F4EB),
                            child: Icon(
                              Icons.local_shipping_outlined,
                              color: green,
                            ),
                          ),
                          title: Text(
                            donation?.foodName ?? 'Food donation',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${request.requestedQuantity} '
                            '${request.requestedUnit}',
                          ),
                          trailing: _StatusChip(status: request.status.label),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NgoProfileEditor extends StatefulWidget {
  const _NgoProfileEditor({
    super.key,
    required this.repository,
    required this.user,
  });

  final FoodLinkRepository repository;
  final Donor user;

  @override
  State<_NgoProfileEditor> createState() => _NgoProfileEditorState();
}

class _NgoProfileEditorState extends State<_NgoProfileEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _areaController;
  late final TextEditingController _communitiesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _descriptionController = TextEditingController(
      text: widget.user.ngoDescription,
    );
    _areaController = TextEditingController(text: widget.user.workingArea);
    _communitiesController = TextEditingController(
      text: widget.user.communitiesServed,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _areaController.dispose();
    _communitiesController.dispose();
    super.dispose();
  }

  String? _requiredField(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required.';
    }
    return null;
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;
    try {
      widget.repository.updateNgoProfile(
        fullName: _nameController.text,
        description: _descriptionController.text,
        workingArea: _areaController.text,
        communitiesServed: _communitiesController.text,
      );
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('NGO profile saved.')));
    } on StateError catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: ExpansionTile(
        leading: Icon(Icons.business_outlined, color: NgoDashboardScreen.green),
        title: const Text(
          'Edit NGO Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'NGO name'),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) => _requiredField(value, 'NGO name'),
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Organization description',
                    alignLabelWithHint: true,
                  ),
                  minLines: 2,
                  maxLines: 4,
                  maxLength: 300,
                ),
                TextFormField(
                  controller: _areaController,
                  decoration: const InputDecoration(
                    labelText: 'Working area / city',
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) =>
                      _requiredField(value, 'Working area or city'),
                ),
                TextFormField(
                  controller: _communitiesController,
                  decoration: const InputDecoration(
                    labelText: 'Communities or people served (optional)',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saveProfile,
                    child: const Text('Save Profile'),
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
        child: Column(
          children: [
            Icon(icon, color: NgoDashboardScreen.green, size: 25),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonationCard extends StatelessWidget {
  const _DonationCard({
    required this.donation,
    required this.alreadyRequested,
    required this.onRequest,
  });

  final FoodDonation donation;
  final bool alreadyRequested;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              donation.foodName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Category: ${donation.category}'),
            Text('Quantity: ${donation.quantity} ${donation.quantityUnit}'),
            Text('Location: ${donation.pickupArea}'),
            Text(
              'Safe-use deadline: '
              '${donation.safeUseDeadline.day}/'
              '${donation.safeUseDeadline.month}/'
              '${donation.safeUseDeadline.year}',
            ),
            if (donation.notes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                donation.notes,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: NgoDashboardScreen.green,
                ),
                onPressed: alreadyRequested ? null : onRequest,
                icon: const Icon(Icons.volunteer_activism),
                label: Text(
                  alreadyRequested ? 'Request Submitted' : 'Request Pickup',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final approved = status == 'Approved';

    return Chip(
      label: Text(status),
      backgroundColor: approved
          ? const Color(0xFFE0F3E7)
          : const Color(0xFFFFF0D8),
      labelStyle: TextStyle(
        color: approved ? const Color(0xFF167344) : Colors.brown,
        fontWeight: FontWeight.w600,
        fontSize: 11,
      ),
      side: BorderSide.none,
    );
  }
}
