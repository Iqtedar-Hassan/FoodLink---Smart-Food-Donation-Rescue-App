import 'package:flutter_test/flutter_test.dart';
import 'package:foodlink/app.dart';

void main() {
  testWidgets('FoodLink welcome flow shows the app branding', (tester) async {
    await tester.pumpWidget(const FoodLinkApp());

    expect(find.text('FoodLink'), findsWidgets);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });
}
