import 'package:flutter_test/flutter_test.dart';
import 'package:foodlink/main.dart';

void main() {
  testWidgets('FoodLink app launches', (WidgetTester tester) async {
    await tester.pumpWidget(const FoodLinkApp());

    expect(find.text('FoodLink'), findsWidgets);
  });
}
