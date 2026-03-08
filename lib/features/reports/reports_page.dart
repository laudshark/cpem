import 'package:flutter/material.dart';

import '../../core/models/contract.dart';
import '../../core/models/financial_summary.dart';
import '../../core/state/app_state.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/section_card.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({required this.appState, super.key});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    if (appState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final monthlyEntries = appState.monthlySummaries.entries.toList();
    final categoryEntries = appState.expenseCategoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategory = categoryEntries.isEmpty ? null : categoryEntries.first;
    final completedContracts = appState.contracts
        .where((item) => item.status == ContractStatus.completed)
        .length;

    return PageScaffold(
      title: 'Reports & analytics',
      subtitle:
          'Review profitability trends, spending patterns, and export targets for formal reporting.',
      actions: [
        FilledButton.icon(
          onPressed: null,
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: const Text('Export PDF'),
        ),
        OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.table_chart_outlined),
          label: const Text('Export CSV'),
        ),
      ],
      child: Column(
        children: [
          SectionCard(
            title: 'Financial summary',
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _ReportChip(
                  label: 'Top category',
                  value: topCategory == null
                      ? 'No spending recorded'
                      : '${topCategory.key.label} | ${formatMoney(topCategory.value)}',
                ),
                _ReportChip(
                  label: 'Completed contracts',
                  value: '$completedContracts',
                ),
                const _ReportChip(
                  label: 'Export formats',
                  value: 'PDF, Excel, CSV',
                ),
                _ReportChip(
                  label: 'Offline mode',
                  value: appState.syncStatus.isOnline
                      ? 'Online | local storage active'
                      : '${appState.syncStatus.pendingChanges} pending sync changes',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SectionCard(
            title: 'Monthly trend',
            child: Column(
              children: [
                for (var index = 0; index < monthlyEntries.length; index++) ...[
                  _MonthlyRow(
                      label: formatMonthKey(monthlyEntries[index].key),
                      summary: monthlyEntries[index].value),
                  if (index != monthlyEntries.length - 1)
                    const SizedBox(height: 18),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyRow extends StatelessWidget {
  const _MonthlyRow({
    required this.label,
    required this.summary,
  });

  final String label;
  final FinancialSummary summary;

  @override
  Widget build(BuildContext context) {
    final balanceColor =
        summary.profit >= 0 ? const Color(0xFF166534) : const Color(0xFFB91C1C);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F3EB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              Text('Revenue: ${formatMoney(summary.revenue)}'),
              Text('Expenses: ${formatMoney(summary.expenses)}'),
              Text(
                'Profit: ${formatMoney(summary.profit)}',
                style:
                    TextStyle(color: balanceColor, fontWeight: FontWeight.w700),
              ),
              Text('Margin: ${formatPercent(summary.profitMargin)}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportChip extends StatelessWidget {
  const _ReportChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F3EB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
