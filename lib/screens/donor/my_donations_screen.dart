import 'package:flutter/material.dart';

import '../../core/utils/date_time_utils.dart';
import '../../data/repositories/local_donation_repository.dart';
import '../../models/food_donation.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/donations/donation_card.dart';

// ============================================================
// Design tokens — EXACTLY the same palette as the Dashboard
// so both screens look consistent. All values chosen for
// HIGH CONTRAST on mobile.
// ============================================================
const Color _primaryGreen = Color(0xFF117A50);
const Color _darkGreen = Color(0xFF0B6842);
const Color _background = Color(0xFFF3F6F4);
const Color _textPrimary = Color(0xFF14251C);
const Color _textSecondary = Color(0xFF3D4E44);
const Color _border = Color(0xFFC4D3C9);

// Subtle shadow used on every white card (same as dashboard).
const List<BoxShadow> _cardShadow = [
  BoxShadow(color: Color(0x14323223), blurRadius: 10, offset: Offset(0, 4)),
];

// Status colors — darker shades so the WHITE text on selected
// chips is always easy to read.
const Map<String, Color> _statusColors = {
  'All': _primaryGreen,
  'Available': _primaryGreen,
  'Reserved': Color(0xFF35619F), // dark blue
  'Collected': Color(0xFFA96208), // dark amber
  'Delivered': _darkGreen,
  'Cancelled': Color(0xFFB23A3A), // dark red
};

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
    final query = _searchQuery.trim().toLowerCase();
    return widget.repository.donorDonations.where((donation) {
      final matchesStatus =
          _statusFilter == 'All' ||
          (donation.status.label == _statusFilter &&
              (_statusFilter != 'Available' ||
                  !DateTimeUtils.isPastDeadline(donation.safeUseDeadline)));
      final matchesSearch =
          query.isEmpty || donation.foodName.toLowerCase().contains(query);
      return matchesStatus && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repository,
      builder: (context, _) {
        final allDonations = widget.repository.donorDonations;
        final filtered = _filteredDonations();
        final isFiltering =
            _statusFilter != 'All' || _searchQuery.trim().isNotEmpty;

        return Scaffold(
          backgroundColor: _background,
          appBar: _buildAppBar(),
          body: SafeArea(
            child: allDonations.isEmpty
                ? _buildInitialEmptyState()
                : _buildContent(
                    filtered: filtered,
                    totalCount: allDonations.length,
                    isFiltering: isFiltering,
                  ),
          ),
        );
      },
    );
  }

  // ============================================================
  // MAIN CONTENT — one simple ListView (no slivers, easy to read)
  // ============================================================
  Widget _buildContent({
    required List<FoodDonation> filtered,
    required int totalCount,
    required bool isFiltering,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final hPadding = width >= 1100
            ? 48.0
            : width >= 700
            ? 32.0
            : 16.0;
        final maxContentWidth = width >= 1200 ? 1100.0 : 900.0;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(hPadding, 16, hPadding, 32),
              children: [
                // ---- Summary card
                _buildSummaryCard(
                  totalDonations: totalCount,
                  showing: filtered.length,
                ),
                const SizedBox(height: 14),

                // ---- Search field
                _buildSearchField(),
                const SizedBox(height: 12),

                // ---- Filter chips
                _buildFilterChips(),
                const SizedBox(height: 10),

                // ---- Donation list (or empty state)
                if (filtered.isEmpty)
                  EmptyState(
                    icon: Icons.search_off_rounded,
                    message: isFiltering
                        ? 'No donations match your filters. Try a different '
                              'status or search term.'
                        : 'No donations to show yet.',
                  )
                else
                  ...filtered.map(
                    (donation) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DonationCard(
                        donation: donation,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/donation-details',
                          arguments: donation.id,
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

  // ============================================================
  // APP BAR — same style as the Dashboard
  // ============================================================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _background,
      foregroundColor: _textPrimary,
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
              color: _primaryGreen,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: _textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'TRACK YOUR CONTRIBUTIONS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: _textSecondary,
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
              backgroundColor: _primaryGreen,
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
  // SUMMARY CARD — clean and simple (same design as the Pickup
  // Requests card):
  // title → big number → thin divider → inline stats (no boxes)
  // ============================================================
  Widget _buildSummaryCard({
    required int totalDonations,
    required int showing,
  }) {
    int countByStatus(String label) => widget.repository.donorDonations
        .where((d) => d.status.label == label)
        .length;

    final availableCount = widget.repository.availableDonations;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primaryGreen, _darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _darkGreen.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Total Donations',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),

          // Big number + label + showing count
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$totalDonations',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    totalDonations == 1 ? 'item total' : 'items total',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '$showing total',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Thin divider
          Divider(
            color: Colors.white.withValues(alpha: 0.25),
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: 12),

          // Simple inline stats — no boxes
          Row(
            children: [
              Expanded(child: _summaryStat('Available', availableCount)),
              Expanded(
                child: _summaryStat('Reserved', countByStatus('Reserved')),
              ),
              Expanded(
                child: _summaryStat('Delivered', countByStatus('Delivered')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryStat(String label, int value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$value',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SEARCH FIELD — white card, strong border, dark readable text
  // ============================================================
  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 1.2),
        boxShadow: _cardShadow,
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          color: _textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: 'Search by food name',
          hintStyle: const TextStyle(
            color: _textSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _primaryGreen,
            size: 24,
          ),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.clear_rounded, size: 20),
                  color: _textSecondary,
                  onPressed: () => setState(() => _searchQuery = ''),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FILTER CHIPS — one horizontal scrollable row (same as you had)
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
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _statusFilters[index];
          return _FilterChip(
            label: filter,
            selected: _statusFilter == filter,
            color: _statusColors[filter] ?? _primaryGreen,
            onTap: () => setState(() => _statusFilter = filter),
          );
        },
      ),
    );
  }

  // ============================================================
  // INITIAL EMPTY STATE (no donations at all)
  // ============================================================
  Widget _buildInitialEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24),
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
// FILTER CHIP — simple and high contrast:
//  - unselected: white background + dark text + visible border
//  - selected: solid dark status color + white bold text + check
// ============================================================
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color : Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: selected ? color : _border, width: 1.4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : _textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 6),
                const Icon(Icons.check_rounded, color: Colors.white, size: 15),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
