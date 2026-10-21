import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodlink/app.dart';
import 'package:foodlink/screens/auth_screen.dart';
import 'package:foodlink/screens/dashboard_screen.dart';
import 'package:foodlink/screens/add_donation_screen.dart';
import 'package:foodlink/screens/role_selection_screen.dart';
import 'package:foodlink/screens/welcome_screen.dart';

void main() {
  testWidgets('welcome opens role selection', (tester) async {
    await tester.pumpWidget(const FoodLinkApp());
    expect(find.text('FoodLink'), findsOneWidget);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('Choose Your Role'), findsOneWidget);
  });

  testWidgets('welcome login opens the preview form', (tester) async {
    await tester.pumpWidget(const FoodLinkApp());
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('View Demo'), findsOneWidget);
  });

  for (final role in ['Donor', 'NGO', 'Admin']) {
    testWidgets('$role selection opens its dashboard and returns home', (
      tester,
    ) async {
      await tester.pumpWidget(const FoodLinkApp());
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(role));
      await tester.pumpAndSettle();
      expect(find.text(role == 'Admin' ? 'Log In' : 'Sign Up'), findsOneWidget);
      await tester.ensureVisible(find.text('View Demo'));
      await tester.tap(find.text('View Demo'));
      await tester.pumpAndSettle();
      expect(find.text('$role Dashboard'), findsOneWidget);
      await tester.tap(find.byTooltip('Back to welcome'));
      await tester.pumpAndSettle();
      expect(find.text('Get Started'), findsOneWidget);
    });
  }

  testWidgets('donor form shows its preview result', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: DashboardScreen(role: 'Donor')),
    );
    await tester.tap(find.text('Add Donation'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Rice');
    await tester.scrollUntilVisible(
      find.text('Preview Donation'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Preview Donation'));
    await tester.pumpAndSettle();
    expect(
      find.text('UI preview complete. Nothing was saved.'),
      findsOneWidget,
    );
  });

  testWidgets('NGO pickup button explains preview behavior', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: DashboardScreen(role: 'NGO')),
    );
    await tester.tap(find.text('Request Pickup').first);
    await tester.pumpAndSettle();
    expect(
      find.text('Pickup preview only. No request was sent.'),
      findsOneWidget,
    );
  });

  for (final width in [320.0, 800.0]) {
    testWidgets('simple screens fit at ${width}px', (tester) async {
      tester.view.physicalSize = Size(width, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final screen in [
        const WelcomeScreen(),
        const RoleSelectionScreen(),
        const AuthScreen(),
        const AuthScreen(role: 'NGO', isSignup: true),
        const DashboardScreen(role: 'Donor'),
        const DashboardScreen(role: 'NGO'),
        const DashboardScreen(role: 'Admin'),
        const AddDonationScreen(),
      ]) {
        await tester.pumpWidget(MaterialApp(home: screen));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  }
}
