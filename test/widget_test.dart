import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sakani_mobile/app/app.dart';

void main() {
  testWidgets('Sakani app loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SakaniApp(),
      ),
    );

    await tester.pump();

    expect(find.byType(SakaniApp), findsOneWidget);
  });
}