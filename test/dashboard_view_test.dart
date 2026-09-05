import 'package:flutter_test/flutter_test.dart';

import 'support/pump_app.dart';

void main() {
  testWidgets('shows the home scene', (tester) async {
    await pumpApp(tester, isAuthenticated: true);

    expect(find.text('Tap me when you need me'), findsOneWidget);
    expect(find.text('Meditate'), findsWidgets);
  });

  testWidgets('shows the day-one empty state until history exists',
      (tester) async {
    await pumpApp(tester, isAuthenticated: true);

    expect(find.text('Breathe for two minutes'), findsOneWidget);
    expect(find.text('Name one good thing'), findsOneWidget);
  });
}
