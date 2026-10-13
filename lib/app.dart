import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/local_donation_repository.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/donor/create_donation_screen.dart';
import 'screens/donor/donation_details_screen.dart';
import 'screens/donor/main_shell_screen.dart';
import 'screens/splash/splash_screen.dart';

class FoodLinkApp extends StatefulWidget {
  const FoodLinkApp({super.key});

  @override
  State<FoodLinkApp> createState() => _FoodLinkAppState();
}

class _FoodLinkAppState extends State<FoodLinkApp> {
  // A single repository instance for the app lifetime so login state and mock
  // data survive any rebuilds of the MaterialApp.
  final FoodLinkRepository _repository = FoodLinkRepository();

  @override
  Widget build(BuildContext context) {
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

        if (protectedRoutes.contains(name) && !_repository.isAuthenticated) {
          return MaterialPageRoute(
            builder: (_) => LoginScreen(repository: _repository),
          );
        }

        switch (name) {
          case '/splash':
            return MaterialPageRoute(
              builder: (_) => SplashScreen(repository: _repository),
            );
          case '/login':
            return MaterialPageRoute(
              builder: (_) => LoginScreen(repository: _repository),
            );
          case '/signup':
            return MaterialPageRoute(
              builder: (_) => SignUpScreen(repository: _repository),
            );
          case '/dashboard':
            return MaterialPageRoute(
              builder: (_) =>
                  MainShellScreen(repository: _repository, initialIndex: 0),
            );
          case '/my-donations':
            return MaterialPageRoute(
              builder: (_) =>
                  MainShellScreen(repository: _repository, initialIndex: 1),
            );
          case '/pickup-requests':
            return MaterialPageRoute(
              builder: (_) =>
                  MainShellScreen(repository: _repository, initialIndex: 2),
            );
          case '/profile':
            return MaterialPageRoute(
              builder: (_) =>
                  MainShellScreen(repository: _repository, initialIndex: 3),
            );
          case '/create-donation':
            final args =
                settings.arguments as Map<String, dynamic>? ?? const {};
            return MaterialPageRoute(
              builder: (_) => CreateDonationScreen(
                repository: _repository,
                donationId: args['donationId'] as String?,
              ),
            );
          case '/donation-details':
            final donationId = settings.arguments as String? ?? '';
            return MaterialPageRoute(
              builder: (_) => DonationDetailsScreen(
                repository: _repository,
                donationId: donationId,
              ),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => SplashScreen(repository: _repository),
            );
        }
      },
    );
  }
}
