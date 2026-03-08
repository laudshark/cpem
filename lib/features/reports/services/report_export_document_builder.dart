import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/models/expense.dart';
import '../../../core/models/income.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/formatters.dart';

String buildReportFileName(String extension, DateTime generatedAt) {
  final month = generatedAt.month.toString().padLeft(2, '0');
  final day = generatedAt.day.toString().padLeft(2, '0');
  final hour = generatedAt.hour.toString().padLeft(2, '0');
  final minute = generatedAt.minute.toString().padLeft(2, '0');
  final second = generatedAt.second.toString().padLeft(2, '0');

  return 'cpem-report-${generatedAt.year}$month${day}T$hour$minute$second.$extension';
}

String buildReportCsv(AppState appState, DateTime generatedAt) {
  final rows = <List<String>>[
    ['CPEM Financial Report'],
    ['Generated at', _formatIsoTimestamp(generatedAt)],
    [
      'Sync status',
      appState.syncStatus.isOnline
          ? 'Online'
          : 'Offline (${appState.syncStatus.pendingChanges} pending changes)',
    ],
    const [],
    ['Business summary'],
    ['Metric', 'Value'],
    ['Total revenue', _formatNumber(appState.businessSummary.revenue)],
    ['Total expenses', _formatNumber(appState.businessSummary.expenses)],
    ['Net profit / loss', _formatNumber(appState.businessSummary.profit)],
    ['Profit margin %', _formatNumber(appState.businessSummary.profitMargin)],
    ['Active contracts', '${appState.activeContractsCount}'],
    const [],
    ['Monthly trend'],
    ['Month', 'Revenue', 'Expenses', 'Profit', 'Margin %'],
    ...appState.monthlySummaries.entries.map((entry) {
      return [
        entry.key,
        _formatNumber(entry.value.revenue),
        _formatNumber(entry.value.expenses),
        _formatNumber(entry.value.profit),
        _formatNumber(entry.value.profitMargin),
      ];
    }),
    const [],
    ['Expense categories'],
    ['Category', 'Amount'],
    ..._sortedCategoryEntries(appState).map((entry) {
      return [entry.key.label, _formatNumber(entry.value)];
    }),
    const [],
    ['Contract profitability'],
    [
      'Contract',
      'Client',
      'Status',
      'Contract value',
      'Budget',
      'Revenue',
      'Expenses',
      'Profit',
      'Margin %',
      'Budget utilization %',
    ],
    ...appState.contracts.map((contract) {
      final summary = appState.summaryForContract(contract.id);
      return [
        contract.title,
        contract.clientName,
        contract.status.label,
        _formatNumber(contract.contractValue),
        _formatNumber(contract.budgetAmount),
        _formatNumber(summary.revenue),
        _formatNumber(summary.expenses),
        _formatNumber(summary.profit),
        _formatNumber(summary.profitMargin),
        _formatNumber(appState.budgetUtilizationForContract(contract.id)),
      ];
    }),
    const [],
    ['Ledger'],
    ['Date', 'Direction', 'Type', 'Counterparty', 'Contract', 'Amount'],
    ..._buildTransactions(appState).map((entry) {
      return [
        _formatIsoDate(entry.date),
        entry.isIncome ? 'Income' : 'Expense',
        entry.secondaryLabel,
        entry.counterparty,
        appState.contractTitle(entry.contractId),
        _formatNumber(entry.amount),
      ];
    }),
  ];

  return rows.map(_csvRow).join('\n');
}

Future<Uint8List> buildReportPdf(
    AppState appState, DateTime generatedAt) async {
  final document = pw.Document();
  final summary = appState.businessSummary;

  document.addPage(
    pw.MultiPage(
      margin: const pw.EdgeInsets.all(28),
      build: (context) {
        return [
          pw.Text(
            'Contract Profit & Expense Manager',
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Financial report generated ${formatDate(generatedAt)} at ${_formatTime(generatedAt)}',
            style:
                const pw.TextStyle(fontSize: 11, color: PdfColors.blueGrey700),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            appState.syncStatus.isOnline
                ? 'Sync status: online and local storage active.'
                : 'Sync status: offline with ${appState.syncStatus.pendingChanges} pending local changes.',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.SizedBox(height: 18),
          _pdfSection(
            title: 'Business summary',
            child: pw.TableHelper.fromTextArray(
              headers: const ['Metric', 'Value'],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.blueGrey800),
              cellPadding: const pw.EdgeInsets.all(8),
              data: [
                ['Total revenue', formatMoney(summary.revenue)],
                ['Total expenses', formatMoney(summary.expenses)],
                ['Net profit / loss', formatMoney(summary.profit)],
                ['Profit margin', formatPercent(summary.profitMargin)],
                ['Active contracts', '${appState.activeContractsCount}'],
              ],
            ),
          ),
          _pdfSection(
            title: 'Contract profitability',
            child: pw.TableHelper.fromTextArray(
              headers: const [
                'Contract',
                'Status',
                'Revenue',
                'Expenses',
                'Performance'
              ],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.blueGrey800),
              cellPadding: const pw.EdgeInsets.all(6),
              data: appState.contracts.map((contract) {
                final contractSummary =
                    appState.summaryForContract(contract.id);
                return [
                  contract.title,
                  contract.status.label,
                  formatMoney(contractSummary.revenue),
                  formatMoney(contractSummary.expenses),
                  '${formatMoney(contractSummary.profit)} / ${formatPercent(contractSummary.profitMargin)}',
                ];
              }).toList(),
            ),
          ),
          _pdfSection(
            title: 'Monthly trend',
            child: pw.TableHelper.fromTextArray(
              headers: const ['Month', 'Revenue', 'Expenses', 'Profit'],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.blueGrey800),
              cellPadding: const pw.EdgeInsets.all(6),
              data: appState.monthlySummaries.entries.map((entry) {
                return [
                  formatMonthKey(entry.key),
                  formatMoney(entry.value.revenue),
                  formatMoney(entry.value.expenses),
                  formatMoney(entry.value.profit),
                ];
              }).toList(),
            ),
          ),
          _pdfSection(
            title: 'Expense categories',
            child: pw.TableHelper.fromTextArray(
              headers: const ['Category', 'Amount'],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.blueGrey800),
              cellPadding: const pw.EdgeInsets.all(6),
              data: _sortedCategoryEntries(appState).map((entry) {
                return [
                  entry.key.label,
                  formatMoney(entry.value),
                ];
              }).toList(),
            ),
          ),
          _pdfSection(
            title: 'Recent ledger',
            child: pw.TableHelper.fromTextArray(
              headers: const [
                'Date',
                'Direction',
                'Type',
                'Contract',
                'Amount'
              ],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.blueGrey800),
              cellPadding: const pw.EdgeInsets.all(6),
              data: _buildTransactions(appState).take(12).map((entry) {
                return [
                  _formatIsoDate(entry.date),
                  entry.isIncome ? 'Income' : 'Expense',
                  entry.secondaryLabel,
                  appState.contractTitle(entry.contractId),
                  entry.isIncome
                      ? '+${formatMoney(entry.amount)}'
                      : '-${formatMoney(entry.amount)}',
                ];
              }).toList(),
            ),
          ),
        ];
      },
    ),
  );

  return document.save();
}

pw.Widget _pdfSection({
  required String title,
  required pw.Widget child,
}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 16),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blueGrey900,
          ),
        ),
        pw.SizedBox(height: 8),
        child,
      ],
    ),
  );
}

List<MapEntry<ExpenseCategory, double>> _sortedCategoryEntries(
    AppState appState) {
  final items = appState.expenseCategoryTotals.entries.toList();
  items.sort((a, b) => b.value.compareTo(a.value));
  return items;
}

List<_ReportTransaction> _buildTransactions(AppState appState) {
  final expenseItems = appState.expenses.map(_ReportTransaction.fromExpense);
  final incomeItems = appState.income.map(_ReportTransaction.fromIncome);
  final items = [...expenseItems, ...incomeItems];
  items.sort((a, b) => b.date.compareTo(a.date));
  return items;
}

String _csvRow(List<String> values) {
  return values.map(_escapeCsvValue).join(',');
}

String _escapeCsvValue(String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n')) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }
  return value;
}

String _formatNumber(double value) => value.toStringAsFixed(2);

String _formatIsoDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String _formatIsoTimestamp(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  final second = date.second.toString().padLeft(2, '0');
  return '${_formatIsoDate(date)} $hour:$minute:$second';
}

String _formatTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

class _ReportTransaction {
  const _ReportTransaction({
    required this.date,
    required this.amount,
    required this.contractId,
    required this.secondaryLabel,
    required this.counterparty,
    required this.isIncome,
  });

  factory _ReportTransaction.fromExpense(ExpenseRecord record) {
    return _ReportTransaction(
      date: record.date,
      amount: record.amount,
      contractId: record.contractId,
      secondaryLabel: record.category.label,
      counterparty: record.vendor,
      isIncome: false,
    );
  }

  factory _ReportTransaction.fromIncome(IncomeRecord record) {
    return _ReportTransaction(
      date: record.date,
      amount: record.amount,
      contractId: record.contractId,
      secondaryLabel: record.type.label,
      counterparty: record.payer,
      isIncome: true,
    );
  }

  final DateTime date;
  final double amount;
  final String? contractId;
  final String secondaryLabel;
  final String counterparty;
  final bool isIncome;
}
