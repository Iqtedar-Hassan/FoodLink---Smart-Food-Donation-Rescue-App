import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../data/repositories/local_donation_repository.dart';
import '../models/user_role.dart';
import '../widgets/common/app_card.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key, required this.repository});

  final FoodLinkRepository repository;

  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color darkGreen = AppColors.darkGreen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmBackground,
      appBar: AppBar(
        backgroundColor: AppColors.warmBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Choose Your Role',
          style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                    ),
                    child: const Icon(
                      Icons.volunteer_activism,
                      size: 54,
                      color: primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'How would you like to help?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Choose your role to continue with FoodLink '
                    'and help reduce food waste in your community.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _RoleCard(
                    icon: Icons.storefront_outlined,
                    title: 'Food Donor',
                    description:
                        'Donate surplus food from your home, '
                        'restaurant, bakery or shop.',
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/signup',
                      arguments: UserRole.donor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _RoleCard(
                    icon: Icons.volunteer_activism_outlined,
                    title: 'NGO / Welfare Organization',
                    description:
                        'Discover available food donations and '
                        'request pickups for people in need.',
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/signup',
                      arguments: UserRole.ngo,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _RoleCard(
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Administrator',
                    description:
                        'Sign in to review accounts, donations and '
                        'platform activity.',
                    onTap: () => Navigator.pushNamed(context, '/login'),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Together, we can rescue food and reduce waste.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: primaryGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color darkGreen = AppColors.darkGreen;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final iconTile = Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(AppTheme.compactRadius),
            ),
            child: Icon(icon, size: 30, color: primaryGreen),
          );
          final roleDescription = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Colors.black54,
                ),
              ),
            ],
          );

          if (constraints.maxWidth < 200) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [iconTile, const SizedBox(height: 12), roleDescription],
            );
          }

          return Row(
            children: [
              iconTile,
              const SizedBox(width: 16),
              Expanded(child: roleDescription),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                size: 17,
                color: primaryGreen,
              ),
            ],
          );
        },
      ),
    );
  }
}
