import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodlink/app.dart';
import 'package:foodlink/data/repositories/local_donation_repository.dart';
import 'package:foodlink/screens/auth/login_screen.dart';
import 'package:foodlink/screens/auth/signup_screen.dart';
import 'package:foodlink/screens/donor/create_donation_screen.dart';
import 'package:foodlink/screens/donor/donation_details_screen.dart';
import 'package:foodlink/screens/donor/donor_dashboard_screen.dart';
import 'package:foodlink/screens/donor/donor_profile_screen.dart';
import 'package:foodlink/screens/donor/my_donations_screen.dart';
import 'package:foodlink/screens/donor/pickup_requests_screen.dart';
import 'package:foodlink/widgets/donations/summary_card.dart';

/// Widths that represent the required test ranges: very narrow Android phones,
/// standard phones, large phones, and tablets in portrait and landscape.
const _phoneWidths = [320.0, 360.0, 375.0, 390.0, 430.0];
const _tabletWidths = [600.0, 768.0, 834.0, 1024.0];

FoodLinkRepository _loggedInRepo() =>
    FoodLinkRepository()..login('donor@foodlink.demo', 'Pass1234');

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

  await tester.pumpWidget(MaterialApp(home: child));
  await tester.pump();
  expect(
    tester.takeException(),
    isNull,
    reason: 'Layout overflow/clipping at ${width}x$height',
  );
}

void main() {
  testWidgets('FoodLink welcome flow shows the app branding', (tester) async {
    await tester.pumpWidget(const FoodLinkApp());

    expect(find.text('FoodLink'), findsWidgets);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
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
          SignUpScreen(repository: FoodLinkRepository()),
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
        expect(find.text('Available'), findsOneWidget);
        expect(find.text('Completed'), findsOneWidget);
        expect(find.text('Add Food Donation'), findsOneWidget);
      });

      testWidgets('dashboard landscape at ${width}px', (tester) async {
        await pumpAtSize(
          tester,
          DonorDashboardScreen(repository: _loggedInRepo()),
          width: width,
          height: 360,
        );
        expect(find.text('Overview'), findsOneWidget);
      });
    }
  });

  group('Donor workflow screens never overflow', () {
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
