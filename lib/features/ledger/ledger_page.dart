import 'package:flutter/material.dart';

import '../../core/models/expense.dart';
import '../../core/models/income.dart';
import '../../core/state/app_state.dart';
import '../../core/utils/formatters.dart';
import '../../shared/forms/income_form_sheet.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/section_card.dart';

class LedgerPage extends StatelessWidget {
  const LedgerPage({required this.appState, super.key});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    if (appState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final receivedEntries = appState.income
        .map(_LedgerEntry.fromIncome)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final expenseEntries = appState.expenses
        .map(_LedgerEntry.fromExpense)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final allEntries = [
      ...receivedEntries,
      ...expenseEntries,
    ]..sort((a, b) => b.date.compareTo(a.date));
    final latestActivity = allEntries.isEmpty
        ? 'No activity yet'
        : formatDate(allEntries.first.date);

    return PageScaffold(
      title: 'Ledger',
      subtitle:
          'Review payments received and expenses recorded in separate sections for quicker financial tracking.',
      eyebrow: 'Cash movement',
      headerIcon: Icons.receipt_long_rounded,
      accentColor: const Color(0xFF9A3412),
      statusLabel: latestActivity,
      statusColor: const Color(0xFFFDE68A),
      highlights: [
        PageHeaderHighlight(
          label: 'Transactions',
          value: '${allEntries.length}',
        ),
        PageHeaderHighlight(
          label: 'Received',
          value: formatMoney(appState.businessSummary.revenue),
        ),
        PageHeaderHighlight(
          label: 'Spent',
          value: formatMoney(appState.businessSummary.expenses),
        ),
      ],
      actions: [
        FilledButton.icon(
          onPressed: () => showIncomeFormSheet(context, appState),
          icon: const Icon(Icons.add_card),
          label: const Text('Add income'),
        ),
        OutlinedButton.icon(
          onPressed: () => _showFilterNotice(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white.withValues(alpha: 0.92),
            backgroundColor: Colors.white.withValues(alpha: 0.06),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.24),
            ),
          ),
          icon: const Icon(Icons.tune),
          label: const Text('Filter'),
        ),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 980;
          final sectionWidth =
              wide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth;

          return Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              SizedBox(
                width: sectionWidth,
                child: _LedgerSection(
                  title: 'Payments received',
                  totalLabel: formatMoney(appState.businessSummary.revenue),
                  emptyState: 'No payments have been recorded yet.',
                  entries: receivedEntries,
                  appState: appState,
                ),
              ),
              SizedBox(
                width: sectionWidth,
                child: _LedgerSection(
                  title: 'Expenses recorded',
                  totalLabel: formatMoney(appState.businessSummary.expenses),
                  emptyState: 'No expenses have been recorded yet.',
                  entries: expenseEntries,
                  appState: appState,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showFilterNotice(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaction filters will be added next.'),
      ),
    );
  }
}

class _LedgerSection extends StatelessWidget {
  const _LedgerSection({
    required this.title,
    required this.totalLabel,
    required this.emptyState,
    required this.entries,
    required this.appState,
  });

  final String title;
  final String totalLabel;
  final String emptyState;
  final List<_LedgerEntry> entries;
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: title,
      trailing: _SectionTotalPill(
        count: entries.length,
        totalLabel: totalLabel,
      ),
      child: entries.isEmpty
          ? Text(emptyState)
          : Column(
              children: [
                for (var index = 0; index < entries.length; index++) ...[
                  _TransactionRow(
                    entry: entries[index],
                    contractTitle:
                        appState.contractTitle(entries[index].contractId),
                  ),
                  if (index != entries.length - 1) const Divider(height: 24),
                ],
              ],
            ),
    );
  }
}

class _LedgerEntry {
  const _LedgerEntry({
    required this.id,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.contractId,
    required this.isIncome,
  });

  factory _LedgerEntry.fromExpense(ExpenseRecord record) {
    return _LedgerEntry(
      id: record.id,
      date: record.date,
      title: record.description,
      subtitle: '${record.category.label} | ${record.paymentMethod.label}',
      amount: record.amount,
      contractId: record.contractId,
      isIncome: false,
    );
  }

  factory _LedgerEntry.fromIncome(IncomeRecord record) {
    return _LedgerEntry(
      id: record.id,
      date: record.date,
      title: record.description,
      subtitle: '${record.type.label} | ${record.payer}',
      amount: record.amount,
      contractId: record.contractId,
      isIncome: true,
    );
  }

  final String id;
  final DateTime date;
  final String title;
  final String subtitle;
  final double amount;
  final String? contractId;
  final bool isIncome;
}

class _SectionTotalPill extends StatelessWidget {
  const _SectionTotalPill({
    required this.count,
    required this.totalLabel,
  });

  final int count;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F3EB),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count items | $totalLabel',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.entry,
    required this.contractTitle,
  });

  final _LedgerEntry entry;
  final String contractTitle;

  @override
  Widget build(BuildContext context) {
    final color =
        entry.isIncome ? const Color(0xFF166534) : const Color(0xFFB45309);
    final prefix = entry.isIncome ? '+' : '-';

    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            entry.isIncome ? Icons.south_west : Icons.north_east,
            color: color,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('${entry.subtitle} | $contractTitle'),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$prefix${formatMoney(entry.amount)}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(formatDate(entry.date)),
          ],
        ),
      ],
    );
  }
}
