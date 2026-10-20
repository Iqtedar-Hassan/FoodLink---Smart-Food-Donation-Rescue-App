import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodlink/app.dart';
import 'package:foodlink/core/constants/app_constants.dart';
import 'package:foodlink/data/repositories/local_donation_repository.dart';
import 'package:foodlink/screens/auth/login_screen.dart';
import 'package:foodlink/screens/auth/signup_screen.dart';
import 'package:foodlink/screens/donor/create_donation_screen.dart';
import 'package:foodlink/screens/donor/donation_details_screen.dart';
import 'package:foodlink/screens/donor/donor_dashboard_screen.dart';
import 'package:foodlink/screens/donor/donor_profile_screen.dart';
import 'package:foodlink/screens/donor/my_donations_screen.dart';
import 'package:foodlink/screens/donor/pickup_requests_screen.dart';
import 'package:foodlink/screens/role_selection_screen.dart';
import 'package:foodlink/models/user_role.dart';
import 'package:foodlink/widgets/donations/summary_card.dart';

/// Widths that represent the required test ranges: very narrow Android phones,
/// standard phones, large phones, and tablets in portrait and landscape.
const _phoneWidths = [320.0, 360.0, 375.0, 390.0, 430.0];
const _tabletWidths = [600.0, 768.0, 834.0, 1024.0];

FoodLinkRepository _loggedInRepo() =>
    FoodLinkRepository()
      ..login(AppConstants.demoEmail, AppConstants.demoPassword);

/// Pumps [child] at a logical [width]x[height] and asserts that the layout does
/// not overflow or clip (Flutter throws on RenderFlex overflow, which surfaces
/// through `tester.takeException()`).
Future<void> pumpAtSize(
  WidgetTester tester,
  Widget child, {
  required double width,
  required double height,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final previousErrorHandler = FlutterError.onError;
  FlutterErrorDetails? capturedError;
  FlutterError.onError = (details) {
    capturedError ??= details;
    previousErrorHandler?.call(details);
  };
  try {
    await tester.pumpWidget(MaterialApp(home: child));
    await tester.pump();
  } finally {
    FlutterError.onError = previousErrorHandler;
  }
  final exception = tester.takeException();
  final exceptionDetails = capturedError?.toString() ?? exception?.toString();
  expect(
    exception,
    isNull,
    reason: 'Layout overflow/clipping at ${width}x$height\n$exceptionDetails',
  );
}

Future<void> _completeSignup(
  WidgetTester tester, {
  required UserRole role,
  required String email,
}) async {
  final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
  navigator.pushNamed('/signup', arguments: role);
  await tester.pumpAndSettle();

  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), 'Test Organization');
  await tester.enterText(fields.at(1), email);
  await tester.enterText(fields.at(2), '+923001112223');
  await tester.enterText(fields.at(3), 'Pass1234');
  await tester.enterText(fields.at(4), 'Pass1234');
  await tester.ensureVisible(find.byType(Checkbox));
  await tester.tap(find.byType(Checkbox));
  await tester.ensureVisible(find.text('Create Account'));
  await tester.tap(find.text('Create Account'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 800));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('FoodLink welcome flow shows the app branding', (tester) async {
    await tester.pumpWidget(FoodLinkApp(repository: FoodLinkRepository()));

    expect(find.text('FoodLink'), findsWidgets);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('Choose Your Role'), findsOneWidget);
  });

  testWidgets('role selection fits narrow phone width', (tester) async {
    await pumpAtSize(
      tester,
      RoleSelectionScreen(repository: FoodLinkRepository()),
      width: 320,
      height: 780,
    );

    expect(find.text('Food Donor'), findsOneWidget);
    expect(find.text('NGO / Welfare Organization'), findsOneWidget);
    expect(find.text('Administrator'), findsOneWidget);
  });

  testWidgets('Donor and NGO selection preserve registration roles', (
    tester,
  ) async {
    final repository = FoodLinkRepository();
    await tester.pumpWidget(FoodLinkApp(repository: repository));
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Food Donor'));
    await tester.pumpAndSettle();
    expect(find.text('Registering as Donor'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.text('NGO / Welfare Organization'));
    await tester.pumpAndSettle();
    expect(find.text('Registering as NGO'), findsOneWidget);
  });

  testWidgets('Donor signup authenticates and opens donor dashboard', (
    tester,
  ) async {
    final repository = FoodLinkRepository();
    await tester.pumpWidget(FoodLinkApp(repository: repository));
    await tester.pumpAndSettle();

    await _completeSignup(
      tester,
      role: UserRole.donor,
      email: 'new-donor@foodlink.demo',
    );

    expect(repository.currentDonor?.role, UserRole.donor);
    expect(find.text('DONATION OVERVIEW'), findsOneWidget);
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushNamed('/admin-dashboard');
    await tester.pumpAndSettle();
    expect(
      find.text('The Donor workspace is not available in this build.'),
      findsOneWidget,
    );
    expect(find.text('Administrator Dashboard'), findsNothing);
  });

  testWidgets('NGO signup opens NGO dashboard and supports pickup requests', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FoodLinkRepository();
    await tester.pumpWidget(FoodLinkApp(repository: repository));
    await tester.pumpAndSettle();

    await _completeSignup(
      tester,
      role: UserRole.ngo,
      email: 'new-ngo@foodlink.demo',
    );

    expect(repository.currentDonor?.role, UserRole.ngo);
    expect(find.text('FoodLink NGO'), findsOneWidget);
    expect(find.text('new-ngo@foodlink.demo'), findsOneWidget);
    expect(find.text('Available Donations'), findsOneWidget);

    await tester.tap(find.text('Edit NGO Profile'));
    await tester.pumpAndSettle();
    final profileFields = find.byType(TextFormField);
    await tester.enterText(
      profileFields.at(1),
      'Rescuing meals for local families.',
    );
    await tester.enterText(profileFields.at(2), 'Islamabad');
    await tester.enterText(
      profileFields.at(3),
      'Low-income families and community kitchens',
    );
    await tester.tap(find.text('Save Profile'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Request Pickup').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Request Pickup').first);
    await tester.pumpAndSettle();
    expect(find.text('Request Submitted'), findsOneWidget);
    expect(repository.currentNgoPickupRequests, hasLength(1));

    await tester.tap(find.byTooltip('Log out'));
    await tester.pumpAndSettle();
    expect(repository.isAuthenticated, isFalse);
    expect(find.text('Welcome back'), findsOneWidget);

    repository.login(AppConstants.demoEmail, AppConstants.demoPassword);
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushNamed('/pickup-requests');
    await tester.pumpAndSettle();
    expect(find.text('Rescuing meals for local families.'), findsOneWidget);
    expect(find.text('Working area: Islamabad'), findsOneWidget);
    expect(
      find.text('Serves: Low-income families and community kitchens'),
      findsOneWidget,
    );
    expect(find.text('Approve'), findsWidgets);
    expect(find.text('Reject'), findsWidgets);
  });

  testWidgets('Admin selection opens shared login, not registration', (
    tester,
  ) async {
    await tester.pumpWidget(FoodLinkApp(repository: FoodLinkRepository()));
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Administrator'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Administrator'));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Registering as Admin'), findsNothing);
  });

  testWidgets('Donor login reaches donor dashboard', (tester) async {
    final repository = FoodLinkRepository();
    await tester.pumpWidget(FoodLinkApp(repository: repository));
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      AppConstants.demoEmail,
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      AppConstants.demoPassword,
    );
    await tester.tap(find.text('Log In'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    expect(repository.currentDonor?.role, UserRole.donor);
    expect(find.text('DONATION OVERVIEW'), findsOneWidget);
  });

  testWidgets('Admin login opens the protected admin dashboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FoodLinkRepository();
    await tester.pumpWidget(FoodLinkApp(repository: repository));
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'admin@gmail.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'Admin@12345');
    await tester.tap(find.text('Log In'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    expect(repository.currentDonor?.role, UserRole.admin);
    expect(find.text('Administrator Dashboard'), findsOneWidget);
    expect(find.text('Create Admin Account'), findsOneWidget);

    await tester.ensureVisible(find.text('Create Admin Account'));
    await tester.tap(find.text('Create Admin Account'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Session Administrator');
    await tester.enterText(fields.at(1), 'session.admin@gmail.com');
    await tester.enterText(fields.at(2), '+923001112223');
    await tester.enterText(fields.at(3), 'Admin@12345');
    await tester.tap(find.text('Create').last);
    await tester.pumpAndSettle();
    expect(repository.donors, hasLength(6));

    await tester.tap(find.byTooltip('Log out'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'session.admin@gmail.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Admin@12345');
    await tester.tap(find.text('Log In'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
    expect(repository.currentDonor?.role, UserRole.admin);
    expect(find.text('Administrator Dashboard'), findsOneWidget);
  });

  testWidgets('NGO login opens the NGO dashboard', (tester) async {
    final repository = FoodLinkRepository();
    repository.signup(
      fullName: 'Community NGO',
      email: 'ngo@foodlink.demo',
      phone: '+923001112223',
      password: 'Pass1234',
      role: UserRole.ngo,
    );
    await tester.pumpWidget(FoodLinkApp(repository: repository));
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'ngo@foodlink.demo',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Pass1234');
    await tester.tap(find.text('Log In'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    expect(repository.currentDonor?.role, UserRole.ngo);
    expect(find.text('FoodLink NGO'), findsOneWidget);
    expect(find.text('Welcome, Community NGO!'), findsOneWidget);
    expect(find.text('DONATION OVERVIEW'), findsNothing);
  });

  testWidgets('unauthenticated donor routes return to shared login', (
    tester,
  ) async {
    await tester.pumpWidget(FoodLinkApp(repository: FoodLinkRepository()));
    await tester.pumpAndSettle();

    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushNamed('/dashboard');
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('authenticated NGO cannot enter donor routes', (tester) async {
    final repository = FoodLinkRepository();
    repository.signup(
      fullName: 'Community NGO',
      email: 'ngo@foodlink.demo',
      phone: '+923001112223',
      password: 'Pass1234',
      role: UserRole.ngo,
    );
    repository.login('ngo@foodlink.demo', 'Pass1234');
    await tester.pumpWidget(FoodLinkApp(repository: repository));
    await tester.pumpAndSettle();

    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushNamed('/dashboard');
    await tester.pumpAndSettle();

    expect(
      find.text('The NGO workspace is not available in this build.'),
      findsOneWidget,
    );
    expect(find.text('DONATION OVERVIEW'), findsNothing);

    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushNamed('/admin-dashboard');
    await tester.pumpAndSettle();
    expect(
      find.text('The NGO workspace is not available in this build.'),
      findsOneWidget,
    );
    expect(find.text('Administrator Dashboard'), findsNothing);
  });

  testWidgets('signup route without a role safely returns to role selection', (
    tester,
  ) async {
    await tester.pumpWidget(FoodLinkApp(repository: FoodLinkRepository()));
    await tester.pumpAndSettle();

    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushNamed('/signup');
    await tester.pumpAndSettle();

    expect(find.text('Choose Your Role'), findsOneWidget);
    expect(find.text('Registering as Donor'), findsNothing);
  });

  testWidgets('summary card fits a very narrow constraint', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 50,
            height: 125,
            child: SummaryCard(
              label: 'Total Donations',
              value: '999999',
              icon: Icons.inventory_2_outlined,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('login does not authenticate after the screen is dismissed', (
    tester,
  ) async {
    final repository = FoodLinkRepository();
    await tester.pumpWidget(
      MaterialApp(home: LoginScreen(repository: repository)),
    );
    await tester.enterText(
      find.byType(TextFormField).at(0),
      AppConstants.demoEmail,
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      AppConstants.demoPassword,
    );
    await tester.tap(find.text('Log In'));
    await tester.pump();

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pump(const Duration(milliseconds: 800));

    expect(repository.isAuthenticated, isFalse);
  });

  group('Login and Sign-up stay readable across all widths', () {
    for (final width in [..._phoneWidths, ..._tabletWidths]) {
      testWidgets('login at ${width}px', (tester) async {
        await pumpAtSize(
          tester,
          LoginScreen(repository: FoodLinkRepository()),
          width: width,
          height: 780,
        );
        expect(find.text('Log In'), findsOneWidget);
      });

      testWidgets('sign-up at ${width}px', (tester) async {
        await pumpAtSize(
          tester,
          SignUpScreen(repository: FoodLinkRepository(), role: UserRole.donor),
          width: width,
          height: 780,
        );
        expect(find.text('Create Account'), findsOneWidget);
      });
    }
  });

  group('Dashboard adapts across phones and tablets', () {
    for (final width in [..._phoneWidths, ..._tabletWidths]) {
      testWidgets('dashboard portrait at ${width}px', (tester) async {
        await pumpAtSize(
          tester,
          DonorDashboardScreen(repository: _loggedInRepo()),
          width: width,
          height: 780,
        );
        // Grounded statistics labels are present.
        expect(find.text('Total Donations'), findsOneWidget);
        expect(find.text('Available').first, findsOneWidget);
        expect(find.text('Completed'), findsOneWidget);
        expect(find.text('Add Donation'), findsOneWidget);
      });

      testWidgets('dashboard landscape at ${width}px', (tester) async {
        await pumpAtSize(
          tester,
          DonorDashboardScreen(repository: _loggedInRepo()),
          width: width,
          height: 360,
        );
        expect(find.text('DONATION OVERVIEW'), findsOneWidget);
      });
    }
  });

  group('Donor workflow screens never overflow', () {
    testWidgets('my donations summary uses total wording', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: MyDonationsScreen(repository: _loggedInRepo())),
      );

      expect(find.text('5 total'), findsOneWidget);
      expect(find.text('5 showing'), findsNothing);
    });

    for (final width in [..._phoneWidths, ..._tabletWidths]) {
      testWidgets('my donations at ${width}px', (tester) async {
        await pumpAtSize(
          tester,
          MyDonationsScreen(repository: _loggedInRepo()),
          width: width,
          height: 780,
        );
      });

      testWidgets('pickup requests at ${width}px', (tester) async {
        await pumpAtSize(
          tester,
          PickupRequestsScreen(repository: _loggedInRepo()),
          width: width,
          height: 780,
        );
      });

      testWidgets('profile at ${width}px', (tester) async {
        await pumpAtSize(
          tester,
          DonorProfileScreen(repository: _loggedInRepo()),
          width: width,
          height: 780,
        );
      });

      testWidgets('create donation at ${width}px', (tester) async {
        await pumpAtSize(
          tester,
          CreateDonationScreen(repository: _loggedInRepo()),
          width: width,
          height: 780,
        );
      });

      testWidgets('donation details at ${width}px', (tester) async {
        await pumpAtSize(
          tester,
          DonationDetailsScreen(
            repository: _loggedInRepo(),
            donationId: 'don_101',
          ),
          width: width,
          height: 780,
        );
      });
    }
  });
}
