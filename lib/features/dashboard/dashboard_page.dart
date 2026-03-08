import 'package:flutter/material.dart';

import '../../core/state/app_state.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/metric_card.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/section_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({required this.appState, super.key});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    if (appState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final summary = appState.businessSummary;
    final categories = appState.expenseCategoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = categories.take(5).toList();
    final recentExpenses = appState.recentExpenses;

    return PageScaffold(
      title: 'Contract Profit & Expense Manager',
      subtitle:
          'Track contracts, daily spending, incoming payments, and profitability from one operational view.',
      actions: [
        FilledButton.icon(
          onPressed: null,
          icon: const Icon(Icons.add),
          label: const Text('New expense'),
        ),
        OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.file_download_outlined),
          label: const Text('Export report'),
        ),
      ],
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 720;
              final width = wide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth;

              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  SizedBox(
                    width: width,
                    child: MetricCard(
                      label: 'Total revenue',
                      value: formatMoney(summary.revenue),
                      caption: '${appState.income.length} recorded income entries',
                      icon: Icons.arrow_downward_rounded,
                      color: const Color(0xFF0F766E),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: MetricCard(
                      label: 'Total expenses',
                      value: formatMoney(summary.expenses),
                      caption: '${appState.expenses.length} recorded expense entries',
                      icon: Icons.arrow_upward_rounded,
                      color: const Color(0xFFD97706),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: MetricCard(
                      label: 'Net result',
                      value: formatMoney(summary.profit),
                      caption: 'Margin ${formatPercent(summary.profitMargin)}',
                      icon: summary.profit >= 0 ? Icons.trending_up : Icons.trending_down,
                      color: summary.profit >= 0 ? const Color(0xFF166534) : const Color(0xFFB91C1C),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: MetricCard(
                      label: 'Active contracts',
                      value: '${appState.activeContractsCount}',
                      caption: 'General overhead ${formatMoney(appState.generalExpenseTotal)}',
                      icon: Icons.assignment_turned_in_outlined,
                      color: const Color(0xFF1D4ED8),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 920;
              final width = wide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth;

              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  SizedBox(
                    width: width,
                    child: SectionCard(
                      title: 'Recent expenses',
                      child: Column(
                        children: [
                          for (var index = 0; index < recentExpenses.length; index++) ...[
                            _LedgerRow(
                              title: recentExpenses[index].description,
                              subtitle:
                                  '${recentExpenses[index].category.label} | ${appState.contractTitle(recentExpenses[index].contractId)}',
                              amount: formatMoney(recentExpenses[index].amount),
                              date: formatDate(recentExpenses[index].date),
                              amountColor: const Color(0xFFB45309),
                            ),
                            if (index != recentExpenses.length - 1) const Divider(height: 24),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: SectionCard(
                      title: 'Top spend categories',
                      child: Column(
                        children: [
                          for (var index = 0; index < topCategories.length; index++) ...[
                            _CategoryRow(
                              label: topCategories[index].key.label,
                              amount: topCategories[index].value,
                              maxAmount: categories.isEmpty ? 0 : categories.first.value,
                            ),
                            if (index != topCategories.length - 1) const SizedBox(height: 16),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.amountColor,
  });

  final String title;
  final String subtitle;
  final String amount;
  final String date;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(subtitle),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: amountColor),
            ),
            const SizedBox(height: 4),
            Text(date),
          ],
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.label,
    required this.amount,
    required this.maxAmount,
  });

  final String label;
  final double amount;
  final double maxAmount;

  @override
  Widget build(BuildContext context) {
    final progress = maxAmount == 0 ? 0.0 : amount / maxAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium)),
            Text(formatMoney(amount)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: const Color(0xFFE8E2D6),
            color: const Color(0xFF0F766E),
          ),
        ),
      ],
    );
  }
}
