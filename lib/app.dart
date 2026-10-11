import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/local_donation_repository.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/donor/create_donation_screen.dart';
import 'screens/donor/donation_details_screen.dart';
import 'screens/donor/main_shell_screen.dart';
import 'screens/splash/splash_screen.dart';

class FoodLinkApp extends StatelessWidget {
  const FoodLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = FoodLinkRepository();

    return MaterialApp(
      title: 'FoodLink',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        final name = settings.name ?? '/splash';
        final protectedRoutes = <String>{
          '/dashboard',
          '/my-donations',
          '/pickup-requests',
          '/profile',
          '/create-donation',
          '/donation-details',
        };

        if (protectedRoutes.contains(name) && repository.currentDonor == null) {
          return MaterialPageRoute(
            builder: (_) => LoginScreen(repository: repository),
          );
        }

        switch (name) {
          case '/splash':
            return MaterialPageRoute(
              builder: (_) => SplashScreen(repository: repository),
            );
          case '/login':
            return MaterialPageRoute(
              builder: (_) => LoginScreen(repository: repository),
            );
          case '/signup':
            return MaterialPageRoute(
              builder: (_) => SignUpScreen(repository: repository),
            );
          case '/dashboard':
            return MaterialPageRoute(
              builder: (_) =>
                  MainShellScreen(repository: repository, initialIndex: 0),
            );
          case '/my-donations':
            return MaterialPageRoute(
              builder: (_) =>
                  MainShellScreen(repository: repository, initialIndex: 1),
            );
          case '/pickup-requests':
            return MaterialPageRoute(
              builder: (_) =>
                  MainShellScreen(repository: repository, initialIndex: 2),
            );
          case '/profile':
            return MaterialPageRoute(
              builder: (_) =>
                  MainShellScreen(repository: repository, initialIndex: 3),
            );
          case '/create-donation':
            final args =
                settings.arguments as Map<String, dynamic>? ?? const {};
            return MaterialPageRoute(
              builder: (_) => CreateDonationScreen(
                repository: repository,
                donationId: args['donationId'] as String?,
              ),
            );
          case '/donation-details':
            final donationId = settings.arguments as String? ?? '';
            return MaterialPageRoute(
              builder: (_) => DonationDetailsScreen(
                repository: repository,
                donationId: donationId,
              ),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => SplashScreen(repository: repository),
            );
        }
      },
    );
  }
}
