import 'package:flutter_test/flutter_test.dart';

import 'package:cpem/app/app.dart';
import 'package:cpem/core/repositories/in_memory_finance_repository.dart';

void main() {
  testWidgets('app shell renders dashboard content',
      (WidgetTester tester) async {
    await tester.pumpWidget(CpemApp(repository: InMemoryFinanceRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Contract Profit & Expense Manager'), findsOneWidget);
    expect(find.text('Today\'s expenses'), findsOneWidget);
    expect(find.text('Offline mode'), findsOneWidget);
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Contracts'), findsOneWidget);
  });
}
