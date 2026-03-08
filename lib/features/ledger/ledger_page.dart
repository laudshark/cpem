import 'package:flutter/material.dart';

import '../../core/models/expense.dart';
import '../../core/models/income.dart';
import '../../core/state/app_state.dart';
import '../../core/utils/formatters.dart';
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

    final entries = [
      ...appState.expenses.map(_LedgerEntry.fromExpense),
      ...appState.income.map(_LedgerEntry.fromIncome),
    ]..sort((a, b) => b.date.compareTo(a.date));

    return PageScaffold(
      title: 'Ledger',
      subtitle: 'A combined view of outgoing expenses and incoming payments across all business activity.',
      actions: [
        FilledButton.icon(
          onPressed: null,
          icon: const Icon(Icons.add_card),
          label: const Text('Add income'),
        ),
        OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.tune),
          label: const Text('Filter'),
        ),
      ],
      child: SectionCard(
        title: 'Transactions',
        child: Column(
          children: [
            for (var index = 0; index < entries.length; index++) ...[
              _TransactionRow(entry: entries[index], contractTitle: appState.contractTitle(entries[index].contractId)),
              if (index != entries.length - 1) const Divider(height: 24),
            ],
          ],
        ),
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

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.entry,
    required this.contractTitle,
  });

  final _LedgerEntry entry;
  final String contractTitle;

  @override
  Widget build(BuildContext context) {
    final color = entry.isIncome ? const Color(0xFF166534) : const Color(0xFFB45309);
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(formatDate(entry.date)),
          ],
        ),
      ],
    );
  }
}
