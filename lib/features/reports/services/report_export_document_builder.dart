import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/models/contract.dart';
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
  final categoryEntries = _sortedCategoryEntries(appState);
  final contractRows = _buildContractRows(appState);
  final incomeRows = _buildIncomeRows(appState);
  final expenseRows = _buildExpenseRows(appState);
  final overdueRows = _buildOverdueExpenses(appState);

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
    ['General business expenses', _formatNumber(appState.generalExpenseTotal)],
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
    ['Category spending'],
    ['Category', 'Amount', 'Share of expenses %'],
    ...categoryEntries.map((entry) {
      final share = appState.businessSummary.expenses == 0
          ? 0.0
          : (entry.value / appState.businessSummary.expenses) * 100;
      return [
        entry.key.label,
        _formatNumber(entry.value),
        _formatNumber(share),
      ];
    }),
    const [],
    ['Contract performance'],
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
    ...contractRows.map((row) {
      return [
        row.contract.title,
        row.contract.clientName,
        row.contract.status.label,
        _formatNumber(row.contract.contractValue),
        _formatNumber(row.contract.budgetAmount),
        _formatNumber(row.revenue),
        _formatNumber(row.expenses),
        _formatNumber(row.profit),
        _formatNumber(row.margin),
        _formatNumber(row.budgetUtilization),
      ];
    }),
    const [],
    ['Payments received'],
    ['Date', 'Type', 'Payer', 'Contract', 'Amount'],
    ...incomeRows.map((entry) {
      return [
        _formatIsoDate(entry.date),
        entry.secondaryLabel,
        entry.counterparty,
        appState.contractTitle(entry.contractId),
        _formatNumber(entry.amount),
      ];
    }),
    const [],
    ['Expenses recorded'],
    ['Date', 'Category', 'Vendor', 'Contract', 'Amount'],
    ...expenseRows.map((entry) {
      return [
        _formatIsoDate(entry.date),
        entry.secondaryLabel,
        entry.counterparty,
        appState.contractTitle(entry.contractId),
        _formatNumber(entry.amount),
      ];
    }),
    const [],
    ['Payment follow-up'],
    ['Vendor', 'Contract', 'Category', 'Due date', 'Amount'],
    ...overdueRows.map((expense) {
      return [
        expense.vendor,
        appState.contractTitle(expense.contractId),
        expense.category.label,
        expense.dueDate == null ? '' : _formatIsoDate(expense.dueDate!),
        _formatNumber(expense.amount),
      ];
    }),
    const [],
    ['Export categories'],
    ['Category'],
    ['Executive summary'],
    ['Monthly trend'],
    ['Category spending'],
    ['Contract performance'],
    ['Payments received'],
    ['Expenses recorded'],
    ['Payment follow-up'],
  ];

  return rows.map(_csvRow).join('\n');
}

Future<Uint8List> buildReportPdf(
    AppState appState, DateTime generatedAt) async {
  final document = pw.Document();
  final summary = appState.businessSummary;
  final contractRows = _buildContractRows(appState);
  final incomeRows = _buildIncomeRows(appState);
  final expenseRows = _buildExpenseRows(appState);
  final overdueRows = _buildOverdueExpenses(appState);

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
                [
                  'General business expenses',
                  formatMoney(appState.generalExpenseTotal),
                ],
              ],
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
            title: 'Category spending',
            child: pw.TableHelper.fromTextArray(
              headers: const ['Category', 'Amount', 'Share %'],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.blueGrey800),
              cellPadding: const pw.EdgeInsets.all(6),
              data: _sortedCategoryEntries(appState).map((entry) {
                final share = summary.expenses == 0
                    ? 0.0
                    : (entry.value / summary.expenses) * 100;
                return [
                  entry.key.label,
                  formatMoney(entry.value),
                  formatPercent(share),
                ];
              }).toList(),
            ),
          ),
          _pdfSection(
            title: 'Contract performance',
            child: pw.TableHelper.fromTextArray(
              headers: const [
                'Contract',
                'Status',
                'Revenue',
                'Expenses',
                'Profit',
                'Budget used'
              ],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.blueGrey800),
              cellPadding: const pw.EdgeInsets.all(6),
              data: contractRows.map((row) {
                return [
                  row.contract.title,
                  row.contract.status.label,
                  formatMoney(row.revenue),
                  formatMoney(row.expenses),
                  formatMoney(row.profit),
                  formatPercent(row.budgetUtilization),
                ];
              }).toList(),
            ),
          ),
          _pdfSection(
            title: 'Payments received',
            child: pw.TableHelper.fromTextArray(
              headers: const ['Date', 'Type', 'Payer', 'Contract', 'Amount'],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.blueGrey800),
              cellPadding: const pw.EdgeInsets.all(6),
              data: incomeRows.map((entry) {
                return [
                  _formatIsoDate(entry.date),
                  entry.secondaryLabel,
                  entry.counterparty,
                  appState.contractTitle(entry.contractId),
                  formatMoney(entry.amount),
                ];
              }).toList(),
            ),
          ),
          _pdfSection(
            title: 'Expenses recorded',
            child: pw.TableHelper.fromTextArray(
              headers: const [
                'Date',
                'Category',
                'Vendor',
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
              data: expenseRows.map((entry) {
                return [
                  _formatIsoDate(entry.date),
                  entry.secondaryLabel,
                  entry.counterparty,
                  appState.contractTitle(entry.contractId),
                  formatMoney(entry.amount),
                ];
              }).toList(),
            ),
          ),
          _pdfSection(
            title: 'Payment follow-up',
            child: overdueRows.isEmpty
                ? pw.Text('No overdue supplier payments.')
                : pw.TableHelper.fromTextArray(
                    headers: const [
                      'Vendor',
                      'Contract',
                      'Category',
                      'Due date',
                      'Amount'
                    ],
                    headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                    headerDecoration:
                        const pw.BoxDecoration(color: PdfColors.blueGrey800),
                    cellPadding: const pw.EdgeInsets.all(6),
                    data: overdueRows.map((expense) {
                      return [
                        expense.vendor,
                        appState.contractTitle(expense.contractId),
                        expense.category.label,
                        expense.dueDate == null
                            ? ''
                            : _formatIsoDate(expense.dueDate!),
                        formatMoney(expense.amount),
                      ];
                    }).toList(),
                  ),
          ),
          _pdfSection(
            title: 'Export categories',
            child: pw.TableHelper.fromTextArray(
              headers: const ['Included bundle'],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.blueGrey800),
              cellPadding: const pw.EdgeInsets.all(6),
              data: const [
                ['Executive summary'],
                ['Monthly trend'],
                ['Category spending'],
                ['Contract performance'],
                ['Payments received'],
                ['Expenses recorded'],
                ['Payment follow-up'],
              ],
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

List<_ContractExportRow> _buildContractRows(AppState appState) {
  final rows = appState.contracts.map((contract) {
    final summary = appState.summaryForContract(contract.id);
    return _ContractExportRow(
      contract: contract,
      revenue: summary.revenue,
      expenses: summary.expenses,
      profit: summary.profit,
      margin: summary.profitMargin,
      budgetUtilization: appState.budgetUtilizationForContract(contract.id),
    );
  }).toList();
  rows.sort((a, b) => b.profit.compareTo(a.profit));
  return rows;
}

List<_ReportTransaction> _buildIncomeRows(AppState appState) {
  final items = appState.income.map(_ReportTransaction.fromIncome).toList();
  items.sort((a, b) => b.date.compareTo(a.date));
  return items;
}

List<_ReportTransaction> _buildExpenseRows(AppState appState) {
  final items = appState.expenses.map(_ReportTransaction.fromExpense).toList();
  items.sort((a, b) => b.date.compareTo(a.date));
  return items;
}

List<ExpenseRecord> _buildOverdueExpenses(AppState appState) {
  final items = [...appState.overdueSupplierExpenses];
  items.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
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

class _ContractExportRow {
  const _ContractExportRow({
    required this.contract,
    required this.revenue,
    required this.expenses,
    required this.profit,
    required this.margin,
    required this.budgetUtilization,
  });

  final ContractRecord contract;
  final double revenue;
  final double expenses;
  final double profit;
  final double margin;
  final double budgetUtilization;
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
