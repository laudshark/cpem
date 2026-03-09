import 'package:flutter/material.dart';

import '../../core/models/contract.dart';
import '../../core/models/financial_summary.dart';
import '../../core/state/app_state.dart';
import '../../core/utils/formatters.dart';
import 'services/report_export_service.dart';
import 'services/report_export_types.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/section_card.dart';

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

    return PageScaffold(
      title: 'Reports & analytics',
      subtitle:
          'Review profitability trends, spending patterns, and export targets for formal reporting.',
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
          label: 'Top category',
          value: topCategory == null ? 'No spend yet' : topCategory.key.label,
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
