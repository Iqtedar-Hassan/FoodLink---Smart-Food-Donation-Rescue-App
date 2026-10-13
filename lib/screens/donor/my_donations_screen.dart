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

  // Same brand palette as Login / Signup / Dashboard
  static const Color green = AppColors.primaryGreen;
  static const Color background = AppColors.warmBackground;
  static const Color darkGreen = Color(0xFF106B49);
  static const Color textPrimary = Color(0xFF19352A);
  static const Color textSecondary = Color(0xFF738178);
  static const Color border = Color(0xFFE8EDE8);

  static const List<String> _statusFilters = [
    'All',
    'Available',
    'Reserved',
    'Collected',
    'Delivered',
    'Cancelled',
  ];

  static const Map<String, Color> _statusColors = {
    'All': green,
    'Available': Color(0xFF19845A),
    'Reserved': Color(0xFF4778C7),
    'Collected': Color(0xFFD58A19),
    'Delivered': Color(0xFF0E6B47),
    'Cancelled': Color(0xFFCB4A4A),
  };

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
          backgroundColor: background,
          appBar: _buildAppBar(context),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final horizontalPadding = width >= 1100
                    ? 48.0
                    : width >= 700
                    ? 32.0
                    : 20.0;
                final contentWidth = width >= 1200 ? 1100.0 : 900.0;

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentWidth),
                    child: donations.isEmpty
                        ? _buildInitialEmptyState(horizontalPadding)
                        : CustomScrollView(
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            slivers: [
                              // ---- Summary gradient card
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  horizontalPadding,
                                  16,
                                  horizontalPadding,
                                  14,
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: _buildSummaryCard(
                                    donations,
                                    filtered.length,
                                  ),
                                ),
                              ),
                              // ---- Search field
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  horizontalPadding,
                                  0,
                                  horizontalPadding,
                                  14,
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: _buildSearchField(),
                                ),
                              ),
                              // ---- Filter chips
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  horizontalPadding,
                                  0,
                                  horizontalPadding,
                                  10,
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: _buildFilterChips(),
                                ),
                              ),
                              // ---- Count text
                              SliverPadding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                  vertical: 4,
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: _buildCountRow(
                                    filtered.length,
                                    donations.length,
                                  ),
                                ),
                              ),
                              // ---- Donation list (or empty state)
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  horizontalPadding,
                                  8,
                                  horizontalPadding,
                                  36,
                                ),
                                sliver: filtered.isEmpty
                                    ? SliverToBoxAdapter(
                                        child: EmptyState(
                                          icon: Icons.search_off_rounded,
                                          message: isFiltering
                                              ? 'No donations match your current '
                                                    'filters. Try a different status '
                                                    'or search term.'
                                              : 'No donations to show yet.',
                                        ),
                                      )
                                    : SliverList(
                                        delegate: SliverChildBuilderDelegate((
                                          context,
                                          index,
                                        ) {
                                          final donation = filtered[index];
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 12,
                                            ),
                                            child: DonationCard(
                                              donation: donation,
                                              onTap: () => Navigator.pushNamed(
                                                context,
                                                '/donation-details',
                                                arguments: donation.id,
                                              ),
                                            ),
                                          );
                                        }, childCount: filtered.length),
                                      ),
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // APP BAR — matches DonorDashboard style
  // ============================================================
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: background,
      foregroundColor: textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      toolbarHeight: 72,
      titleSpacing: 20,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: green,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'My Donations',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'TRACK YOUR CONTRIBUTIONS',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: IconButton(
            tooltip: 'Add Food Donation',
            onPressed: () => Navigator.pushNamed(context, '/create-donation'),
            style: IconButton.styleFrom(
              backgroundColor: green,
              foregroundColor: Colors.white,
              fixedSize: const Size(46, 46),
            ),
            icon: const Icon(Icons.add_rounded),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY CARD — gradient with status breakdown pills
  // ============================================================
  Widget _buildSummaryCard(List<FoodDonation> donations, int showingCount) {
    int countByStatus(String label) {
      if (label == 'All') return donations.length;
      return donations.where((d) => d.status.label == label).length;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF19845A), Color(0xFF106B49)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR DONATIONS',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${donations.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            donations.length == 1 ? 'item' : 'items total',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Text(
                      'SHOWING',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$showingCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Status breakdown pills
          Row(
            children: [
              _miniStat('Available', countByStatus('Available')),
              const SizedBox(width: 8),
              _miniStat('Reserved', countByStatus('Reserved')),
              const SizedBox(width: 8),
              _miniStat('Delivered', countByStatus('Delivered')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, int count) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SEARCH FIELD — white card with subtle shadow
  // ============================================================
  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search by food name',
          hintStyle: TextStyle(
            color: textSecondary.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: textSecondary,
            size: 22,
          ),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.clear_rounded, size: 20),
                  color: textSecondary,
                  onPressed: () => setState(() => _searchQuery = ''),
                ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FILTER CHIPS — status-colored, custom design
  // ============================================================
  Widget _buildFilterChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: _statusFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _statusFilters[index];
          final selected = _statusFilter == filter;
          final color = _statusColors[filter] ?? green;
          return _FilterChip(
            label: filter,
            selected: selected,
            color: color,
            borderColor: border,
            textColor: textSecondary,
            onTap: () => setState(() => _statusFilter = filter),
          );
        },
      ),
    );
  }

  // ============================================================
  // COUNT TEXT
  // ============================================================
  Widget _buildCountRow(int filteredCount, int totalCount) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Showing $filteredCount of $totalCount donations',
        style: const TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ============================================================
  // INITIAL EMPTY STATE (no donations yet)
  // ============================================================
  Widget _buildInitialEmptyState(double horizontalPadding) {
    return Padding(
      padding: EdgeInsets.all(horizontalPadding),
      child: EmptyState(
        message:
            'You have not added any donations yet. Share your first surplus '
            'food item.',
        actionLabel: 'Add Food Donation',
        onAction: () => Navigator.pushNamed(context, '/create-donation'),
      ),
    );
  }
}

// ============================================================
// CUSTOM FILTER CHIP
// ============================================================
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.borderColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color : Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? color : borderColor,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 6),
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
