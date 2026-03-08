import 'package:flutter/material.dart';

import '../../core/models/app_notification.dart';
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
    final syncStatus = appState.syncStatus;
    final categories = appState.expenseCategoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = categories.take(5).toList();
    final recentExpenses = appState.recentExpenses;
    final notifications = appState.notifications;

    return PageScaffold(
      title: 'Contract Profit & Expense Manager',
      subtitle:
          'Track contracts, daily spending, offline capture, incoming payments, and profitability from one operational view.',
      actions: [
        FilledButton.icon(
          onPressed: () {
            appState.setConnectivity(!appState.isOnline);
          },
          icon: Icon(appState.isOnline
              ? Icons.wifi_off_rounded
              : Icons.cloud_sync_rounded),
          label: Text(appState.isOnline ? 'Go offline' : 'Reconnect & sync'),
        ),
        OutlinedButton.icon(
          onPressed: syncStatus.isOnline && syncStatus.hasPendingChanges
              ? appState.syncPendingChanges
              : null,
          icon: const Icon(Icons.sync_outlined),
          label: Text(syncStatus.isSyncing ? 'Syncing...' : 'Sync now'),
        ),
      ],
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final width = _metricWidth(constraints.maxWidth);

              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  SizedBox(
                    width: width,
                    child: MetricCard(
                      label: 'Today\'s expenses',
                      value: formatMoney(appState.todaysExpenses),
                      caption: 'Current day spend captured across all records',
                      icon: Icons.today_outlined,
                      color: const Color(0xFFB45309),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: MetricCard(
                      label: 'Weekly spending',
                      value: formatMoney(appState.weeklySpending),
                      caption: 'Rolling view for this operating week',
                      icon: Icons.date_range_outlined,
                      color: const Color(0xFFD97706),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: MetricCard(
                      label: 'Monthly spending',
                      value: formatMoney(appState.monthlySpending),
                      caption: 'Month-to-date expense movement',
                      icon: Icons.calendar_month_outlined,
                      color: const Color(0xFF92400E),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: MetricCard(
                      label: 'Active contracts',
                      value: '${appState.activeContractsCount}',
                      caption:
                          'General overhead ${formatMoney(appState.generalExpenseTotal)}',
                      icon: Icons.assignment_turned_in_outlined,
                      color: const Color(0xFF1D4ED8),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: MetricCard(
                      label: 'Total revenue',
                      value: formatMoney(summary.revenue),
                      caption:
                          '${appState.income.length} recorded income entries',
                      icon: Icons.arrow_downward_rounded,
                      color: const Color(0xFF0F766E),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: MetricCard(
                      label: 'Total expenses',
                      value: formatMoney(summary.expenses),
                      caption:
                          '${appState.expenses.length} recorded expense entries',
                      icon: Icons.arrow_upward_rounded,
                      color: const Color(0xFFD97706),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: MetricCard(
                      label: 'Profit / loss overview',
                      value: formatMoney(summary.profit),
                      caption: 'Margin ${formatPercent(summary.profitMargin)}',
                      icon: summary.profit >= 0
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: summary.profit >= 0
                          ? const Color(0xFF166534)
                          : const Color(0xFFB91C1C),
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
              final width =
                  wide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth;

              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  SizedBox(
                    width: width,
                    child: SectionCard(
                      title: 'Offline mode',
                      trailing: _StatusPill(
                        label: syncStatus.isOnline ? 'Online' : 'Offline',
                        color: syncStatus.isOnline
                            ? const Color(0xFF166534)
                            : const Color(0xFFB45309),
                      ),
                      child: Column(
                        children: [
                          _StatusRow(
                            icon: Icons.storage_rounded,
                            title: 'Local data storage',
                            subtitle:
                                'Financial records remain available on this device without internet access.',
                            value: syncStatus.localStorageEnabled
                                ? 'Active'
                                : 'Disabled',
                          ),
                          const Divider(height: 24),
                          _StatusRow(
                            icon: Icons.edit_note_rounded,
                            title: 'Offline data entry',
                            subtitle: syncStatus.hasPendingChanges
                                ? '${syncStatus.pendingChanges} locally captured updates are waiting to sync.'
                                : 'Offline entry is ready and no local updates are waiting.',
                            value: syncStatus.hasPendingChanges
                                ? '${syncStatus.pendingChanges} pending'
                                : 'Ready',
                          ),
                          const Divider(height: 24),
                          _StatusRow(
                            icon: Icons.cloud_done_outlined,
                            title: 'Automatic synchronization',
                            subtitle: syncStatus.lastSyncedAt == null
                                ? 'Sync has not completed yet.'
                                : 'Last synchronized on ${formatDate(syncStatus.lastSyncedAt!)}.',
                            value: syncStatus.isSyncing
                                ? 'Syncing'
                                : syncStatus.autoSyncEnabled
                                    ? 'Enabled'
                                    : 'Disabled',
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: SectionCard(
                      title: 'Notifications',
                      trailing: _StatusPill(
                        label: '${notifications.length} active',
                        color: const Color(0xFF1D4ED8),
                      ),
                      child: Column(
                        children: [
                          for (var index = 0;
                              index < notifications.length;
                              index++) ...[
                            _NotificationRow(
                                notification: notifications[index]),
                            if (index != notifications.length - 1)
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
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 920;
              final width =
                  wide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth;

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
                          for (var index = 0;
                              index < recentExpenses.length;
                              index++) ...[
                            _LedgerRow(
                              title: recentExpenses[index].description,
                              subtitle:
                                  '${recentExpenses[index].category.label} | ${appState.contractTitle(recentExpenses[index].contractId)}',
                              amount: formatMoney(recentExpenses[index].amount),
                              date: formatDate(recentExpenses[index].date),
                              amountColor: const Color(0xFFB45309),
                            ),
                            if (index != recentExpenses.length - 1)
                              const Divider(height: 24),
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
                          for (var index = 0;
                              index < topCategories.length;
                              index++) ...[
                            _CategoryRow(
                              label: topCategories[index].key.label,
                              amount: topCategories[index].value,
                              maxAmount: categories.isEmpty
                                  ? 0
                                  : categories.first.value,
                            ),
                            if (index != topCategories.length - 1)
                              const SizedBox(height: 16),
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

double _metricWidth(double maxWidth) {
  if (maxWidth > 1180) {
    return (maxWidth - 48) / 3;
  }

  if (maxWidth > 720) {
    return (maxWidth - 24) / 2;
  }

  return maxWidth;
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
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: amountColor),
            ),
            const SizedBox(height: 4),
            Text(date),
          ],
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F3EB),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFF0F766E)),
        ),
        const SizedBox(width: 14),
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
        const SizedBox(width: 12),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
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
            Expanded(
                child: Text(label,
                    style: Theme.of(context).textTheme.titleMedium)),
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

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final accent = switch (notification.severity) {
      AppNotificationSeverity.info => const Color(0xFF1D4ED8),
      AppNotificationSeverity.warning => const Color(0xFFD97706),
      AppNotificationSeverity.critical => const Color(0xFFB91C1C),
    };
    final icon = switch (notification.type) {
      AppNotificationType.budgetExceeded => Icons.warning_amber_rounded,
      AppNotificationType.weeklySummary => Icons.insights_outlined,
      AppNotificationType.overdueSupplierPayment => Icons.schedule_rounded,
      AppNotificationType.contractNearingLoss => Icons.trending_down_rounded,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: accent),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification.title,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(notification.message),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
      ),
    );
  }
}
