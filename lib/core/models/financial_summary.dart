class FinancialSummary {
  const FinancialSummary({
    required this.revenue,
    required this.expenses,
  });

  final double revenue;
  final double expenses;

  double get profit => revenue - expenses;

  double get profitMargin => revenue == 0 ? 0 : (profit / revenue) * 100;
}
