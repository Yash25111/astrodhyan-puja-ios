import 'package:flutter_test/flutter_test.dart';
import 'package:puja_experts/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Puja app builds', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const PujaApp());
    await tester.pump(const Duration(milliseconds: 1700));
    await tester.pumpAndSettle();

    expect(find.text('Welcome'), findsOneWidget);
  });
}
