import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/local_donation_repository.dart';
import 'models/user_role.dart';
import 'screens/auth/login_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/donor/create_donation_screen.dart';
import 'screens/donor/donation_details_screen.dart';
import 'screens/donor/main_shell_screen.dart';
import 'screens/splash/splash_screen.dart';

class FoodLinkApp extends StatefulWidget {
  const FoodLinkApp({super.key, this.repository});

  final FoodLinkRepository? repository;

  @override
  State<FoodLinkApp> createState() => _FoodLinkAppState();
}

class _FoodLinkAppState extends State<FoodLinkApp> {
  // A single repository instance for the app lifetime so login state and mock
  // data survive any rebuilds of the MaterialApp.
  late final FoodLinkRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? FoodLinkRepository();
  }

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

        if (protectedRoutes.contains(name)) {
          if (!_repository.isAuthenticated) {
            return MaterialPageRoute(
              builder: (_) => LoginScreen(repository: _repository),
            );
          }

          final role = _repository.currentDonor?.role;
          if (role != UserRole.donor) {
            return MaterialPageRoute(
              builder: (_) =>
                  _RoleAccessDeniedScreen(repository: _repository, role: role),
            );
          }
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
          case '/role-selection':
            return MaterialPageRoute(
              builder: (_) => RoleSelectionScreen(repository: _repository),
            );
          case '/signup':
            final role = settings.arguments;
            if (role is! UserRole || role == UserRole.admin) {
              return MaterialPageRoute(
                builder: (_) => RoleSelectionScreen(repository: _repository),
              );
            }
            return MaterialPageRoute(
              builder: (_) => SignUpScreen(repository: _repository, role: role),
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

class _RoleAccessDeniedScreen extends StatelessWidget {
  const _RoleAccessDeniedScreen({required this.repository, required this.role});

  final FoodLinkRepository repository;
  final UserRole? role;

  @override
  Widget build(BuildContext context) {
    final roleName = role?.label ?? 'Unknown';
    return Scaffold(
      appBar: AppBar(title: const Text('Workspace unavailable')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline_rounded, size: 44),
              const SizedBox(height: 16),
              Text(
                'The $roleName workspace is not available in this build.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  repository.logout();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/splash',
                    (_) => false,
                  );
                },
                child: const Text('Log out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
