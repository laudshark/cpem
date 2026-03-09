import 'package:flutter/material.dart';

import '../../core/models/contract.dart';
import '../../core/models/expense.dart';
import '../../core/models/financial_summary.dart';
import '../../core/state/app_state.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/section_card.dart';
import 'services/report_export_service.dart';
import 'services/report_export_types.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({
    required this.appState,
    this.exportService,
    super.key,
  });

  final AppState appState;
  final ReportExportService? exportService;

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late final ReportExportService _exportService;
  bool _isExportingPdf = false;
  bool _isExportingCsv = false;

  @override
  void initState() {
    super.initState();
    _exportService = widget.exportService ?? createReportExportService();
  }

  @override
  Widget build(BuildContext context) {
    final appState = widget.appState;
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
    final contractRows = appState.contracts
        .map((contract) =>
            _ContractReportRow.fromAppState(contract: contract, appState: appState))
        .toList()
      ..sort((a, b) => b.summary.profit.compareTo(a.summary.profit));
    final overdueExpenses = [...appState.overdueSupplierExpenses]
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    return PageScaffold(
      title: 'Reports & analytics',
      subtitle:
          'Review profitability trends, spending patterns, operational follow-up items, and export bundles for formal reporting.',
      eyebrow: 'Reporting center',
      headerIcon: Icons.analytics_rounded,
      accentColor: const Color(0xFF1D4ED8),
      statusLabel:
          appState.syncStatus.isOnline ? 'Export ready' : 'Offline ready',
      statusColor: const Color(0xFFBFDBFE),
      highlights: [
        PageHeaderHighlight(
          label: 'Months tracked',
          value: '${monthlyEntries.length}',
        ),
        PageHeaderHighlight(
          label: 'Completed contracts',
          value: '$completedContracts',
        ),
        PageHeaderHighlight(
          label: 'Export bundles',
          value: '7 sections',
        ),
      ],
      actions: [
        FilledButton.icon(
          onPressed: _isExportingPdf || _isExportingCsv
              ? null
              : () => _exportPdf(appState),
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: Text(_isExportingPdf ? 'Exporting...' : 'Export PDF'),
        ),
        OutlinedButton.icon(
          onPressed: _isExportingPdf || _isExportingCsv
              ? null
              : () => _exportCsv(appState),
          icon: const Icon(Icons.table_chart_outlined),
          label: Text(_isExportingCsv ? 'Exporting...' : 'Export CSV'),
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
                _ReportChip(
                  label: 'General business expenses',
                  value: formatMoney(appState.generalExpenseTotal),
                ),
                _ReportChip(
                  label: 'Outstanding supplier payments',
                  value: overdueExpenses.isEmpty
                      ? 'None'
                      : '${overdueExpenses.length} items',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 980;
              final width =
                  wide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth;

              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  SizedBox(
                    width: width,
                    child: SectionCard(
                      title: 'Monthly trend',
                      child: Column(
                        children: [
                          for (var index = 0;
                              index < monthlyEntries.length;
                              index++) ...[
                            _MonthlyRow(
                              label: formatMonthKey(monthlyEntries[index].key),
                              summary: monthlyEntries[index].value,
                            ),
                            if (index != monthlyEntries.length - 1)
                              const SizedBox(height: 18),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: SectionCard(
                      title: 'Category spending',
                      child: categoryEntries.isEmpty
                          ? const Text('No category data available yet.')
                          : Column(
                              children: [
                                for (var index = 0;
                                    index < categoryEntries.length;
                                    index++) ...[
                                  _CategorySpendRow(
                                    category: categoryEntries[index].key,
                                    amount: categoryEntries[index].value,
                                    total: appState.businessSummary.expenses,
                                  ),
                                  if (index != categoryEntries.length - 1)
                                    const SizedBox(height: 16),
                                ],
                              ],
                            ),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: SectionCard(
                      title: 'Contract performance',
                      child: Column(
                        children: [
                          for (var index = 0;
                              index < contractRows.length;
                              index++) ...[
                            _ContractPerformanceRow(
                              row: contractRows[index],
                            ),
                            if (index != contractRows.length - 1)
                              const Divider(height: 24),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: SectionCard(
                      title: 'Payment follow-up',
                      child: overdueExpenses.isEmpty
                          ? const Text(
                              'No overdue supplier payments need follow-up right now.',
                            )
                          : Column(
                              children: [
                                for (var index = 0;
                                    index < overdueExpenses.length;
                                    index++) ...[
                                  _OverdueExpenseRow(
                                    expense: overdueExpenses[index],
                                    contractTitle: appState.contractTitle(
                                      overdueExpenses[index].contractId,
                                    ),
                                  ),
                                  if (index != overdueExpenses.length - 1)
                                    const Divider(height: 24),
                                ],
                              ],
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          SectionCard(
            title: 'Export categories',
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: const [
                _ExportCategoryCard(
                  title: 'Executive summary',
                  description:
                      'Revenue, expenses, profit, margin, and active contract count.',
                ),
                _ExportCategoryCard(
                  title: 'Monthly trend',
                  description: 'Revenue and expense performance by month.',
                ),
                _ExportCategoryCard(
                  title: 'Category spending',
                  description:
                      'Expense totals and category share of overall spending.',
                ),
                _ExportCategoryCard(
                  title: 'Contract performance',
                  description:
                      'Budget, revenue, expenses, and profit per contract.',
                ),
                _ExportCategoryCard(
                  title: 'Payments received',
                  description:
                      'Income records grouped by payer, type, and contract.',
                ),
                _ExportCategoryCard(
                  title: 'Expenses recorded',
                  description:
                      'Expense records grouped by vendor, category, and contract.',
                ),
                _ExportCategoryCard(
                  title: 'Payment follow-up',
                  description: 'Outstanding supplier payments and due dates.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportPdf(AppState appState) async {
    setState(() {
      _isExportingPdf = true;
    });

    try {
      final result = await _exportService.exportPdf(appState);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF exported to ${result.destinationLabel}.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF export failed: ${_errorLabel(error)}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExportingPdf = false;
        });
      }
    }
  }

  Future<void> _exportCsv(AppState appState) async {
    setState(() {
      _isExportingCsv = true;
    });

    try {
      final result = await _exportService.exportCsv(appState);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV exported to ${result.destinationLabel}.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV export failed: ${_errorLabel(error)}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExportingCsv = false;
        });
      }
    }
  }

  String _errorLabel(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }
    return message;
  }
}

class _ContractReportRow {
  const _ContractReportRow({
    required this.contract,
    required this.summary,
    required this.budgetUtilization,
  });

  factory _ContractReportRow.fromAppState({
    required ContractRecord contract,
    required AppState appState,
  }) {
    return _ContractReportRow(
      contract: contract,
      summary: appState.summaryForContract(contract.id),
      budgetUtilization: appState.budgetUtilizationForContract(contract.id),
    );
  }

  final ContractRecord contract;
  final FinancialSummary summary;
  final double budgetUtilization;
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

class _CategorySpendRow extends StatelessWidget {
  const _CategorySpendRow({
    required this.category,
    required this.amount,
    required this.total,
  });

  final ExpenseCategory category;
  final double amount;
  final double total;

  @override
  Widget build(BuildContext context) {
    final share = total == 0 ? 0.0 : (amount / total) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                category.label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(formatMoney(amount)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '${share.toStringAsFixed(1)}% of total expenses',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: share / 100,
            minHeight: 10,
            backgroundColor: const Color(0xFFE6EEF7),
            color: const Color(0xFF1D4ED8),
          ),
        ),
      ],
    );
  }
}

class _ContractPerformanceRow extends StatelessWidget {
  const _ContractPerformanceRow({
    required this.row,
  });

  final _ContractReportRow row;

  @override
  Widget build(BuildContext context) {
    final profitColor = row.summary.profit >= 0
        ? const Color(0xFF166534)
        : const Color(0xFFB91C1C);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.contract.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                      '${row.contract.clientName} | ${row.contract.status.label}'),
                ],
              ),
            ),
            Text(
              formatMoney(row.summary.profit),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: profitColor),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 16,
          runSpacing: 10,
          children: [
            Text('Revenue: ${formatMoney(row.summary.revenue)}'),
            Text('Expenses: ${formatMoney(row.summary.expenses)}'),
            Text('Margin: ${formatPercent(row.summary.profitMargin)}'),
            Text(
              'Budget used: ${row.budgetUtilization.toStringAsFixed(1)}%',
            ),
          ],
        ),
      ],
    );
  }
}

class _OverdueExpenseRow extends StatelessWidget {
  const _OverdueExpenseRow({
    required this.expense,
    required this.contractTitle,
  });

  final ExpenseRecord expense;
  final String contractTitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.schedule_rounded,
            color: Color(0xFFB91C1C),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                expense.vendor,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '${expense.category.label} | $contractTitle | Due ${formatDate(expense.dueDate!)}',
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          formatMoney(expense.amount),
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: const Color(0xFFB91C1C)),
        ),
      ],
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

class _ExportCategoryCard extends StatelessWidget {
  const _ExportCategoryCard({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F3EB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(description),
        ],
      ),
    );
  }
}
