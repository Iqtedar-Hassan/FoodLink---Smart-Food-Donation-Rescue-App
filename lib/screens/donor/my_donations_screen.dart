import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/repositories/local_donation_repository.dart';
import '../../models/food_donation.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/donations/donation_card.dart';

class MyDonationsScreen extends StatefulWidget {
  const MyDonationsScreen({super.key, required this.repository});

  final FoodLinkRepository repository;

  @override
  State<MyDonationsScreen> createState() => _MyDonationsScreenState();
}

class _MyDonationsScreenState extends State<MyDonationsScreen> {
  String _statusFilter = 'All';
  String _searchQuery = '';

  static const List<String> _statusFilters = [
    'All',
    'Available',
    'Reserved',
    'Collected',
    'Delivered',
    'Cancelled',
  ];

  List<FoodDonation> _filteredDonations() {
    final donations = widget.repository.donorDonations;
    return donations.where((donation) {
      final matchesStatus =
          _statusFilter == 'All' || donation.status.label == _statusFilter;
      final matchesSearch =
          _searchQuery.trim().isEmpty ||
          donation.foodName.toLowerCase().contains(
            _searchQuery.trim().toLowerCase(),
          );
      return matchesStatus && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repository,
      builder: (context, _) {
        final donations = widget.repository.donorDonations;
        final filtered = _filteredDonations();
        final isFiltering =
            _statusFilter != 'All' || _searchQuery.trim().isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Donations'),
            actions: [
              IconButton(
                tooltip: 'Create Donation',
                onPressed: () =>
                    Navigator.pushNamed(context, '/create-donation'),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          body: SafeArea(
            child: donations.isEmpty
                ? EmptyState(
                    message: 'You have not published any donations yet. Share your first surplus food item.',
                    actionLabel: 'Create Donation',
                    onAction: () =>
                        Navigator.pushNamed(context, '/create-donation'),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: TextField(
                          onChanged: (value) =>
                              setState(() => _searchQuery = value),
                          decoration: InputDecoration(
                            hintText: 'Search by food name',
                            prefixIcon: const Icon(Icons.search_outlined),
                            suffixIcon: _searchQuery.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Clear search',
                                    icon: const Icon(
                                      Icons.clear_rounded,
                                      size: 20,
                                    ),
                                    onPressed: () =>
                                        setState(() => _searchQuery = ''),
                                  ),
                            isDense: true,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 52,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          scrollDirection: Axis.horizontal,
                          itemCount: _statusFilters.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final filter = _statusFilters[index];
                            final selected = _statusFilter == filter;
                            return ChoiceChip(
                              label: Text(filter),
                              selected: selected,
                              selectedColor: AppColors.lightGreen,
                              checkmarkColor: AppColors.primaryGreen,
                              labelStyle: TextStyle(
                                color: selected
                                    ? AppColors.darkGreen
                                    : AppColors.secondaryText,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                              side: BorderSide(
                                color: selected
                                    ? AppColors.primaryGreen
                                    : AppColors.border,
                              ),
                              showCheckmark: false,
                              onSelected: (_) =>
                                  setState(() => _statusFilter = filter),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${filtered.length} of ${donations.length} donations',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.secondaryText),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        // AnimatedSwitcher fades the list briefly whenever the
                        // status filter changes, so results feel responsive.
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: KeyedSubtree(
                            key: ValueKey(_statusFilter),
                            child: filtered.isEmpty
                                ? EmptyState(
                                    icon: Icons.search_off_rounded,
                                    message: isFiltering
                                        ? 'No donations match your current filters. Try a different status or search term.'
                                        : 'No donations to show yet.',
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      8,
                                      16,
                                      16,
                                    ),
                                    itemCount: filtered.length,
                                    itemBuilder: (context, index) {
                                      final donation = filtered[index];
                                      return DonationCard(
                                        donation: donation,
                                        onTap: () => Navigator.pushNamed(
                                          context,
                                          '/donation-details',
                                          arguments: donation.id,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
