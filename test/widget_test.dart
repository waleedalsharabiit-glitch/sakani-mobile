import 'package:flutter_test/flutter_test.dart';

import 'package:sakani_mobile/app/app.dart';

void main() {
  testWidgets('Sakani app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const SakaniApp());

    expect(find.text('سَكَني'), findsOneWidget);
  });
}