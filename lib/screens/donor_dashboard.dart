import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../widgets/common/app_card.dart';

class DonorDashboard extends StatefulWidget {
  const DonorDashboard({super.key});

  @override
  State<DonorDashboard> createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  static const Color green = AppColors.primaryGreen;
  static const Color background = AppColors.warmBackground;
  static const Color darkGreen = Color(0xFF106B49);
  static const Color lightGreen = Color(0xFFE8F5EC);
  static const Color textPrimary = Color(0xFF19352A);
  static const Color textSecondary = Color(0xFF738178);

  // Horizontal action carousel config
  static const double _actionCardWidth = 284;
  static const double _actionCardSpacing = 14;
  static const double _actionCarouselHeight = 142;

  final _actionsScrollController = ScrollController();
  int _currentActionIndex = 0;

  @override
  void initState() {
    super.initState();
    _actionsScrollController.addListener(_onActionsScroll);
  }

  @override
  void dispose() {
    _actionsScrollController.removeListener(_onActionsScroll);
    _actionsScrollController.dispose();
    super.dispose();
  }

  void _onActionsScroll() {
    if (!_actionsScrollController.hasClients) return;
    final offset = _actionsScrollController.offset;
    final itemExtent = _actionCardWidth + _actionCardSpacing;
    final newIndex = ((offset + itemExtent / 2) / itemExtent).floor();
    final clamped = newIndex.clamp(0, 2);
    if (clamped != _currentActionIndex) {
      setState(() => _currentActionIndex = clamped);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    24,
                    horizontalPadding,
                    36,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeSection(context, width),
                      const SizedBox(height: 26),
                      _buildHeroCard(context, width),
                      const SizedBox(height: 28),
                      _buildStatisticsSection(width),
                      const SizedBox(height: 30),
                      _buildSectionHeading(
                        title: 'Quick actions',
                        subtitle: width >= 700
                            ? 'Everything you need, in one place.'
                            : 'Swipe to explore all options.',
                      ),
                      const SizedBox(height: 16),
                      _buildActions(context, width),
                      const SizedBox(height: 26),
                      _buildImpactCard(),
                      const SizedBox(height: 24),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

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
              Icons.volunteer_activism_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          const Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'FoodLink',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'DONOR DASHBOARD',
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
            tooltip: 'Notifications',
            onPressed: () {
              _showMessage(context, 'Notifications');
            },
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: textPrimary,
              fixedSize: const Size(46, 46),
            ),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(BuildContext context, double width) {
    final compact = width < 360;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: lightGreen,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.waving_hand_rounded, size: 15, color: darkGreen),
              SizedBox(width: 7),
              Text(
                'WELCOME BACK',
                style: TextStyle(
                  color: darkGreen,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Hello, Donor!',
          style: TextStyle(
            color: textPrimary,
            fontSize: compact
                ? 28
                : width >= 700
                ? 38
                : 32,
            height: 1.15,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 9),
        const Text(
          'Your extra food can make someone’s day better.',
          style: TextStyle(color: textSecondary, fontSize: 14, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context, double width) {
    final isWide = width >= 600;

    final message = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: const Text(
            'MAKE A DIFFERENCE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Good food.\nGreater purpose.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            height: 1.2,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.7,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Turn your surplus food into a meaningful meal for someone in need.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 13,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: () {
            _showMessage(context, 'Add Food Donation');
          },
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: darkGreen,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text(
            'Donate food',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
        ),
      ],
    );

    final illustration = Container(
      width: isWide ? 180 : 112,
      height: isWide ? 180 : 112,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Icon(
        Icons.volunteer_activism_rounded,
        size: isWide ? 94 : 62,
        color: Colors.white.withValues(alpha: 0.95),
      ),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWide ? 32 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF19845A), Color(0xFF106B49)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: isWide
          ? Row(
              children: [
                Expanded(child: message),
                const SizedBox(width: 24),
                illustration,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(alignment: Alignment.centerRight, child: illustration),
                const SizedBox(height: 4),
                message,
              ],
            ),
    );
  }

  Widget _buildStatisticsSection(double width) {
    final columns = width >= 700 ? 3 : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeading(
          title: 'Your impact',
          subtitle: 'Every contribution counts.',
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 12.0;
            final itemWidth =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;

            final items = [
              _StatData(
                icon: Icons.volunteer_activism_rounded,
                title: 'Total donations',
                value: '0',
                color: const Color(0xFF19845A),
                background: const Color(0xFFE8F5EC),
              ),
              _StatData(
                icon: Icons.pending_actions_rounded,
                title: 'Pending requests',
                value: '0',
                color: const Color(0xFFD58A19),
                background: const Color(0xFFFFF3DB),
              ),
              _StatData(
                icon: Icons.check_circle_outline_rounded,
                title: 'Completed',
                value: '0',
                color: const Color(0xFF4778C7),
                background: const Color(0xFFEAF1FF),
              ),
            ];

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: items.map((item) {
                return SizedBox(
                  width: itemWidth,
                  child: _StatCard(data: item),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeading({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: textPrimary,
            fontSize: 21,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: textSecondary,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ACTIONS — horizontally scrollable on mobile, grid on tablet
  // ============================================================
  Widget _buildActions(BuildContext context, double width) {
    final isTablet = width >= 700;

    final actions = [
      _ActionData(
        icon: Icons.add_circle_outline_rounded,
        title: 'Add Food Donation',
        subtitle: 'Share available food with NGOs.',
        color: const Color(0xFF19845A),
        background: const Color(0xFFE8F5EC),
        tag: 'CREATE',
        onTap: (context) {
          _showMessage(context, 'Add Food Donation');
        },
      ),
      _ActionData(
        icon: Icons.inventory_2_outlined,
        title: 'My Donations',
        subtitle: 'Track your donated food and status.',
        color: const Color(0xFF4778C7),
        background: const Color(0xFFEAF1FF),
        tag: 'MANAGE',
        onTap: (context) {
          _showMessage(context, 'My Donations');
        },
      ),
      _ActionData(
        icon: Icons.notifications_active_outlined,
        title: 'Pickup Requests',
        subtitle: 'Review requests from NGOs.',
        color: const Color(0xFFD58A19),
        background: const Color(0xFFFFF3DB),
        tag: 'REQUESTS',
        onTap: (context) {
          _showMessage(context, 'Pickup Requests');
        },
      ),
    ];

    // ---------- Tablet: 2-column grid ----------
    if (isTablet) {
      const columns = 2;
      const spacing = 14.0;
      return LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth =
              (constraints.maxWidth - spacing * (columns - 1)) / columns;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: actions
                .map(
                  (action) => SizedBox(
                    width: itemWidth,
                    child: _ActionCard(data: action),
                  ),
                )
                .toList(),
          );
        },
      );
    }

    // ---------- Mobile: horizontal scroll carousel ----------
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: _actionCarouselHeight,
          child: ListView.separated(
            controller: _actionsScrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 2),
            itemCount: actions.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: _actionCardSpacing),
            itemBuilder: (context, index) {
              return SizedBox(
                width: _actionCardWidth,
                child: _ActionCard(data: actions[index]),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        // Animated dot indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            actions.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentActionIndex == i ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentActionIndex == i
                    ? green
                    : const Color(0xFFD4DCD6),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.swipe_rounded,
                size: 14,
                color: textSecondary.withOpacity(0.6),
              ),
              const SizedBox(width: 6),
              Text(
                'Swipe to see more',
                style: TextStyle(
                  color: textSecondary.withOpacity(0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImpactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF4E6C7)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.eco_rounded, size: 30, color: Color(0xFF94701C)),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Small actions, big impact',
                  style: TextStyle(
                    color: Color(0xFF594719),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Donate safe, fresh food and include clear quantities and pickup details to help NGOs collect it efficiently.',
                  style: TextStyle(
                    color: Color(0xFF806E48),
                    fontSize: 12,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Icon(Icons.favorite_rounded, color: Color(0xFF19845A), size: 20),
            SizedBox(height: 8),
            Text(
              'Together, we can reduce food waste.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String title) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$title will be available soon.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }
}

// ============================================================
// # DATA MODELS & WIDGETS
// ============================================================

class _StatData {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final Color background;

  const _StatData({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.background,
  });
}

class _StatCard extends StatelessWidget {
  final _StatData data;

  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8EDE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: data.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(data.icon, color: data.color, size: 22),
          ),
          const SizedBox(height: 18),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              data.value,
              style: const TextStyle(
                color: Color(0xFF19352A),
                fontSize: 29,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            data.title,
            style: const TextStyle(
              color: Color(0xFF738178),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color background;
  final String tag;
  final void Function(BuildContext context) onTap;

  const _ActionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.background,
    required this.tag,
    required this.onTap,
  });
}

class _ActionCard extends StatelessWidget {
  final _ActionData data;

  const _ActionCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: () => data.onTap(context),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          constraints: const BoxConstraints(minHeight: 112),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE8EDE8)),
          ),
          child: Row(
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: data.background,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(data.icon, color: data.color, size: 27),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: const TextStyle(
                        color: Color(0xFF19352A),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      data.subtitle,
                      style: const TextStyle(
                        color: Color(0xFF738178),
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.tag,
                      style: TextStyle(
                        color: data.color,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: data.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
