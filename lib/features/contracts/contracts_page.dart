import 'package:flutter/material.dart';

import '../../core/models/contract.dart';
import '../../core/state/app_state.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/section_card.dart';

class ContractsPage extends StatelessWidget {
  const ContractsPage({required this.appState, super.key});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    if (appState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return PageScaffold(
      title: 'Contracts',
      subtitle: 'Review contract value, progress windows, and live profitability for each project.',
      actions: [
        FilledButton.icon(
          onPressed: null,
          icon: const Icon(Icons.assignment_add),
          label: const Text('New contract'),
        ),
      ],
      child: Column(
        children: [
          for (var index = 0; index < appState.contracts.length; index++) ...[
            _ContractCard(
              contract: appState.contracts[index],
              appState: appState,
            ),
            if (index != appState.contracts.length - 1) const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}

class _ContractCard extends StatelessWidget {
  const _ContractCard({
    required this.contract,
    required this.appState,
  });

  final ContractRecord contract;
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final summary = appState.summaryForContract(contract.id);

    return SectionCard(
      title: contract.title,
      trailing: _StatusBadge(status: contract.status),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 10,
            children: [
              _InfoPill(label: 'Client', value: contract.clientName),
              _InfoPill(label: 'Value', value: formatMoney(contract.contractValue)),
              _InfoPill(label: 'Start', value: formatDate(contract.startDate)),
              _InfoPill(
                label: 'End',
                value: contract.endDate == null ? 'Open' : formatDate(contract.endDate!),
              ),
            ],
          ),
          if (contract.description != null) ...[
            const SizedBox(height: 18),
            Text(contract.description!),
          ],
          const SizedBox(height: 18),
          _ContractFinancialBlock(
            revenue: summary.revenue,
            expenses: summary.expenses,
            profit: summary.profit,
            margin: summary.profitMargin,
            budget: contract.contractValue,
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ContractStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ContractStatus.draft => const Color(0xFF64748B),
      ContractStatus.active => const Color(0xFF0F766E),
      ContractStatus.onHold => const Color(0xFFD97706),
      ContractStatus.completed => const Color(0xFF166534),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F3EB),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text('$label: $value'),
    );
  }
}

class _ContractFinancialBlock extends StatelessWidget {
  const _ContractFinancialBlock({
    required this.revenue,
    required this.expenses,
    required this.profit,
    required this.margin,
    required this.budget,
  });

  final double revenue;
  final double expenses;
  final double profit;
  final double margin;
  final double budget;

  @override
  Widget build(BuildContext context) {
    final spendRatio = budget == 0 ? 0.0 : expenses / budget;
    final clampedRatio = spendRatio.clamp(0.0, 1.0);
    final profitColor = profit >= 0 ? const Color(0xFF166534) : const Color(0xFFB91C1C);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _FinancialChip(label: 'Income', value: formatMoney(revenue)),
            _FinancialChip(label: 'Expenses', value: formatMoney(expenses)),
            _FinancialChip(
              label: 'Profit / loss',
              value: formatMoney(profit),
              valueColor: profitColor,
            ),
            _FinancialChip(label: 'Margin', value: formatPercent(margin)),
          ],
        ),
        const SizedBox(height: 16),
        Text('Budget utilization', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: clampedRatio,
            minHeight: 12,
            backgroundColor: const Color(0xFFE8E2D6),
            color: spendRatio > 1 ? const Color(0xFFB91C1C) : const Color(0xFF0F766E),
          ),
        ),
        const SizedBox(height: 8),
        Text('${formatMoney(expenses)} spent against ${formatMoney(budget)} contract value'),
      ],
    );
  }
}

class _FinancialChip extends StatelessWidget {
  const _FinancialChip({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F3EB),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}
