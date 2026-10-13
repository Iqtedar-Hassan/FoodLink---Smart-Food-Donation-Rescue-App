import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/local_donation_repository.dart';
import '../../widgets/common/brand_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.repository});

  final FoodLinkRepository repository;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

/// Plays one short fade-and-slide entrance when the screen appears.
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    final curved = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(curved);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(curved);
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final formMaxWidth = AppTheme.authFormMaxWidth(screenWidth);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: formMaxWidth),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceXl,
                    vertical: AppTheme.space2xl,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Center(child: BrandLogo(size: 108)),
                            const SizedBox(height: AppTheme.space2xl),
                            Text(
                              AppConstants.appTitle,
                              textAlign: TextAlign.center,
                              style: textTheme.headlineLarge,
                            ),
                            const SizedBox(height: AppTheme.spaceSm),
                            Text(
                              'Good food. Better futures.',
                              textAlign: TextAlign.center,
                              style: textTheme.titleMedium?.copyWith(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spaceLg),
                            Text(
                              'FoodLink connects surplus food from donors with '
                              'communities that need it. Share more, waste less.',
                              textAlign: TextAlign.center,
                              style: textTheme.bodyLarge?.copyWith(
                                color: AppColors.secondaryText,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: AppTheme.space3xl),
                            ElevatedButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/signup'),
                              child: const Text('Get Started'),
                            ),
                            const SizedBox(height: AppTheme.spaceMd),
                            OutlinedButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/login'),
                              child: const Text('Log In'),
                            ),
                            const SizedBox(height: AppTheme.spaceLg),
                            Text(
                              'Local demo mode - no backend required',
                              textAlign: TextAlign.center,
                              style: textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
