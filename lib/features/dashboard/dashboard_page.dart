import 'package:flutter/material.dart';

import '../../core/models/app_notification.dart';
import '../../core/models/financial_summary.dart';
import '../../core/state/app_state.dart';
import '../../core/utils/formatters.dart';
import '../../shared/forms/expense_form_sheet.dart';
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
          onPressed: () => showExpenseFormSheet(context, appState),
          icon: const Icon(Icons.add),
          label: const Text('New expense'),
        ),
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
          _OverviewHero(
            summary: summary,
            activeContractsCount: appState.activeContractsCount,
            weeklySpending: appState.weeklySpending,
            monthlySpending: appState.monthlySpending,
            syncStatusLabel: syncStatus.isOnline ? 'Online' : 'Offline',
            syncStatusColor: syncStatus.isOnline
                ? const Color(0xFF86EFAC)
                : const Color(0xFFFCD34D),
            pendingSyncEntries: syncStatus.pendingChanges,
          ),
          const SizedBox(height: 28),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: amountColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child:
              Icon(Icons.receipt_long_outlined, color: amountColor, size: 20),
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

class _OverviewHero extends StatelessWidget {
  const _OverviewHero({
    required this.summary,
    required this.activeContractsCount,
    required this.weeklySpending,
    required this.monthlySpending,
    required this.syncStatusLabel,
    required this.syncStatusColor,
    required this.pendingSyncEntries,
  });

  final FinancialSummary summary;
  final int activeContractsCount;
  final double weeklySpending;
  final double monthlySpending;
  final String syncStatusLabel;
  final Color syncStatusColor;
  final int pendingSyncEntries;

  @override
  Widget build(BuildContext context) {
    final positive = summary.profit >= 0;
    final balanceColor =
        positive ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0E5D58),
            Color(0xFF17344B),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -36,
            right: -18,
            child: _HeroGlow(
              size: 150,
              color: const Color(0x33F59E0B),
            ),
          ),
          Positioned(
            bottom: -70,
            left: -34,
            child: _HeroGlow(
              size: 190,
              color: const Color(0x2206B6D4),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 760;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _HeroBadge(
                        label: 'Operating snapshot',
                        backgroundColor: Colors.white.withValues(alpha: 0.14),
                        textColor: Colors.white,
                      ),
                      _HeroBadge(
                        label: syncStatusLabel,
                        backgroundColor:
                            syncStatusColor.withValues(alpha: 0.18),
                        textColor: syncStatusColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _HeroSummary(
                            profit: summary.profit,
                            profitMargin: summary.profitMargin,
                            revenue: summary.revenue,
                            expenses: summary.expenses,
                            activeContractsCount: activeContractsCount,
                            balanceColor: balanceColor,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 2,
                          child: _HeroStatsPanel(
                            weeklySpending: weeklySpending,
                            monthlySpending: monthlySpending,
                            pendingSyncEntries: pendingSyncEntries,
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _HeroSummary(
                      profit: summary.profit,
                      profitMargin: summary.profitMargin,
                      revenue: summary.revenue,
                      expenses: summary.expenses,
                      activeContractsCount: activeContractsCount,
                      balanceColor: balanceColor,
                    ),
                    const SizedBox(height: 20),
                    _HeroStatsPanel(
                      weeklySpending: weeklySpending,
                      monthlySpending: monthlySpending,
                      pendingSyncEntries: pendingSyncEntries,
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
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
    final share = progress * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
                child: Text(label,
                    style: Theme.of(context).textTheme.titleMedium)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(formatMoney(amount)),
                const SizedBox(height: 2),
                Text(
                  '${share.toStringAsFixed(0)}% of top spend',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
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
              Row(
                children: [
                  Expanded(
                    child: Text(notification.title,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  _SeverityPill(
                    label: switch (notification.severity) {
                      AppNotificationSeverity.info => 'Info',
                      AppNotificationSeverity.warning => 'Warning',
                      AppNotificationSeverity.critical => 'Critical',
                    },
                    color: accent,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(notification.message),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroSummary extends StatelessWidget {
  const _HeroSummary({
    required this.profit,
    required this.profitMargin,
    required this.revenue,
    required this.expenses,
    required this.activeContractsCount,
    required this.balanceColor,
  });

  final double profit;
  final double profitMargin;
  final double revenue;
  final double expenses;
  final int activeContractsCount;
  final Color balanceColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Net operating position',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.88),
              ),
        ),
        const SizedBox(height: 12),
        Text(
          formatMoney(profit),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontSize: 40,
                height: 1,
              ),
        ),
        const SizedBox(height: 12),
        _HeroBadge(
          label: 'Margin ${formatPercent(profitMargin)}',
          backgroundColor: balanceColor.withValues(alpha: 0.16),
          textColor: balanceColor,
        ),
        const SizedBox(height: 16),
        Text(
          'Revenue ${formatMoney(revenue)} against expenses ${formatMoney(expenses)} across $activeContractsCount active contracts.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.82),
              ),
        ),
      ],
    );
  }
}

class _HeroStatsPanel extends StatelessWidget {
  const _HeroStatsPanel({
    required this.weeklySpending,
    required this.monthlySpending,
    required this.pendingSyncEntries,
  });

  final double weeklySpending;
  final double monthlySpending;
  final int pendingSyncEntries;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        children: [
          _HeroStatTile(
            label: 'This week',
            value: formatMoney(weeklySpending),
          ),
          const SizedBox(height: 14),
          _HeroStatTile(
            label: 'This month',
            value: formatMoney(monthlySpending),
          ),
          const SizedBox(height: 14),
          _HeroStatTile(
            label: 'Pending sync',
            value:
                pendingSyncEntries == 0 ? 'All clear' : '$pendingSyncEntries',
          ),
        ],
      ),
    );
  }
}

class _HeroStatTile extends StatelessWidget {
  const _HeroStatTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.74),
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: textColor,
            ),
      ),
    );
  }
}

class _HeroGlow extends StatelessWidget {
  const _HeroGlow({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

class _SeverityPill extends StatelessWidget {
  const _SeverityPill({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
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
