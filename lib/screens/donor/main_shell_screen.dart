import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/repositories/local_donation_repository.dart';
import '../../models/pickup_request.dart';
import 'donor_dashboard_screen.dart';
import 'donor_profile_screen.dart';
import 'my_donations_screen.dart';
import 'pickup_requests_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({
    super.key,
    required this.repository,
    required this.initialIndex,
  });

  final FoodLinkRepository repository;
  final int initialIndex;

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  Widget _navIcon({required IconData icon, required int count}) {
    if (count <= 0) return Icon(icon);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        Positioned(
          right: -8,
          top: -4,
          child: Badge(
            label: Text('$count'),
            backgroundColor: AppColors.errorRed,
            textColor: AppColors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repository,
      builder: (context, _) {
        final pendingCount = widget.repository.donorPickupRequests
            .where((request) => request.status == PickupRequestStatus.pending)
            .length;

        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              DonorDashboardScreen(repository: widget.repository),
              MyDonationsScreen(repository: widget.repository),
              PickupRequestsScreen(repository: widget.repository),
              DonorProfileScreen(repository: widget.repository),
            ],
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.dashboard_outlined),
                  selectedIcon: const Icon(Icons.dashboard_rounded),
                  label: 'Dashboard',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon: Icon(Icons.inventory_2_rounded),
                  label: 'My Donations',
                ),
                NavigationDestination(
                  icon: _navIcon(
                    icon: Icons.request_page_outlined,
                    count: pendingCount,
                  ),
                  selectedIcon: _navIcon(
                    icon: Icons.request_page_rounded,
                    count: pendingCount,
                  ),
                  label: 'Pickup Requests',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
