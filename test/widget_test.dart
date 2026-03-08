import 'package:flutter_test/flutter_test.dart';

import 'package:cpem/app/app.dart';

void main() {
  testWidgets('app shell renders dashboard content',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CpemApp());
    await tester.pumpAndSettle();

    expect(find.text('Contract Profit & Expense Manager'), findsOneWidget);
    expect(find.text('Today\'s expenses'), findsOneWidget);
    expect(find.text('Offline mode'), findsOneWidget);
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Contracts'), findsOneWidget);
  });
}
