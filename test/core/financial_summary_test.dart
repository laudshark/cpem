import 'package:cpem/core/models/financial_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('profit and margin are calculated correctly', () {
    const summary = FinancialSummary(revenue: 1000, expenses: 650);

    expect(summary.profit, 350);
    expect(summary.profitMargin, 35);
  });

  test('margin is zero when revenue is zero', () {
    const summary = FinancialSummary(revenue: 0, expenses: 200);

    expect(summary.profit, -200);
    expect(summary.profitMargin, 0);
  });
}
