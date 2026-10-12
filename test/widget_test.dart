import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodlink/app.dart';
import 'package:foodlink/data/repositories/local_donation_repository.dart';
import 'package:foodlink/screens/donor/donor_dashboard_screen.dart';
import 'package:foodlink/widgets/donations/summary_card.dart';

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

  testWidgets('donor quick actions adapt across screen widths', (tester) async {
    tester.view.physicalSize = const Size(1200, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FoodLinkRepository()
      ..login('donor@foodlink.demo', 'Pass1234');
    await tester.pumpWidget(
      MaterialApp(home: DonorDashboardScreen(repository: repository)),
    );

    final actionBuilder = tester
        .widget<LayoutBuilder>(
          find
              .ancestor(
                of: find.text('Create Donation'),
                matching: find.byType(LayoutBuilder),
              )
              .first,
        )
        .builder;
    final dashboardContext = tester.element(find.byType(DonorDashboardScreen));

    for (final screenWidth in [320.0, 375.0, 390.0, 430.0, 768.0]) {
      final contentWidth = screenWidth - 40;
      final actionLayout = actionBuilder(
        dashboardContext,
        BoxConstraints(maxWidth: contentWidth),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(width: contentWidth, child: actionLayout),
            ),
          ),
        ),
      );

      final createTile = find
          .ancestor(
            of: find.text('Create Donation'),
            matching: find.byType(SizedBox),
          )
          .first;
      final donationsTile = find
          .ancestor(
            of: find.text('My Donations'),
            matching: find.byType(SizedBox),
          )
          .first;
      final requestsTile = find
          .ancestor(
            of: find.text('Pickup Requests'),
            matching: find.byType(SizedBox),
          )
          .first;
      final createCenter = tester.getCenter(createTile);
      final donationsCenter = tester.getCenter(donationsTile);
      final requestsCenter = tester.getCenter(requestsTile);
      final actionContainer = find.byType(screenWidth < 600 ? Wrap : Row).first;

      if (screenWidth < 600) {
        expect(createCenter.dy, closeTo(donationsCenter.dy, 1));
        expect(requestsCenter.dy, greaterThan(createCenter.dy));
        expect(
          requestsCenter.dx,
          closeTo(tester.getCenter(actionContainer).dx, 1),
        );
      } else {
        expect(createCenter.dy, closeTo(donationsCenter.dy, 1));
        expect(createCenter.dy, closeTo(requestsCenter.dy, 1));
      }
      expect(tester.takeException(), isNull, reason: 'Width: $screenWidth px');
    }
  });
}
