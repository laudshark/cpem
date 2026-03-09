import 'package:cpem/core/models/app_notification.dart';
import 'package:cpem/core/models/expense.dart';
import 'package:cpem/core/models/income.dart';
import 'package:cpem/core/repositories/in_memory_finance_repository.dart';
import 'package:cpem/core/state/app_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppState appState;

  setUp(() async {
    appState = AppState(
      repository: InMemoryFinanceRepository(),
      now: () => DateTime(2026, 3, 8, 10, 30),
    );
    await appState.load();
  });

  test('dashboard metrics and alerts are derived from current records', () {
    expect(appState.todaysExpenses, 11650);
    expect(appState.weeklySpending, 51250);
    expect(appState.monthlySpending, 55450);
    expect(appState.activeContractsCount, 2);

    expect(appState.budgetExceededContracts.map((item) => item.id),
        contains('ct-001'));
    expect(appState.contractsNearingLoss.map((item) => item.id),
        contains('ct-002'));
    expect(
      appState.overdueSupplierExpenses.map((item) => item.id),
      contains('ex-005'),
    );

    expect(appState.notifications.length, 4);
    expect(appState.notifications.first.title, 'Budget exceeded alert');
  });

  test('offline mode queues and syncs local changes', () async {
    expect(appState.syncStatus.isOnline, isTrue);
    expect(appState.syncStatus.pendingChanges, 0);

    await appState.setConnectivity(false);

    expect(appState.syncStatus.isOffline, isTrue);
    expect(appState.syncStatus.pendingChanges, 2);

    await appState.setConnectivity(true);

    expect(appState.syncStatus.isOnline, isTrue);
    expect(appState.syncStatus.pendingChanges, 0);
    expect(appState.syncStatus.lastSyncedAt, DateTime(2026, 3, 8, 10, 30));
  });

  test('adding income persists in state and increments offline sync queue',
      () async {
    final initialRevenue = appState.businessSummary.revenue;

    await appState.setConnectivity(false);
    await appState.addIncome(
      contractId: 'ct-001',
      type: IncomeType.milestonePayment,
      amount: 9200,
      date: DateTime(2026, 3, 8),
      payer: 'Accra Metro Works',
      description: 'Bridge deck inspection payment.',
    );

    expect(appState.businessSummary.revenue, initialRevenue + 9200);
    expect(appState.syncStatus.pendingChanges, 3);
    expect(
      appState.income
          .any((item) => item.description == 'Bridge deck inspection payment.'),
      isTrue,
    );
  });

  test('saving credentials updates local settings state', () async {
    expect(appState.userCredentials.fullName, isEmpty);

    await appState.saveUserCredentials(
      fullName: 'Laud Shark',
      businessName: 'Shark Contracting',
      emailAddress: 'laud@example.com',
      phoneNumber: '+233200000000',
      roleTitle: 'Managing Director',
    );

    expect(appState.userCredentials.fullName, 'Laud Shark');
    expect(appState.userCredentials.businessName, 'Shark Contracting');
    expect(appState.userCredentials.emailAddress, 'laud@example.com');
    expect(appState.userCredentials.completionLabel, 'Ready');
  });

  test('preferences control notifications and auto sync behavior', () async {
    await appState.saveAppPreferences(
      autoSyncEnabled: false,
      budgetAlertsEnabled: false,
      weeklySummaryEnabled: true,
      overduePaymentsEnabled: false,
      contractRiskAlertsEnabled: true,
    );

    expect(appState.appPreferences.autoSyncEnabled, isFalse);
    expect(appState.syncStatus.autoSyncEnabled, isFalse);
    expect(
      appState.notifications.map((item) => item.type),
      isNot(contains(AppNotificationType.budgetExceeded)),
    );
    expect(
      appState.notifications.map((item) => item.type),
      isNot(contains(AppNotificationType.overdueSupplierPayment)),
    );
    expect(
      appState.notifications.map((item) => item.type),
      contains(AppNotificationType.weeklySummary),
    );

    await appState.setConnectivity(false);
    await appState.addExpense(
      category: ExpenseCategory.miscellaneous,
      amount: 100,
      date: DateTime(2026, 3, 8),
      paymentMethod: PaymentMethod.cash,
      vendor: 'Test Vendor',
      description: 'Offline test change',
    );

    expect(appState.syncStatus.pendingChanges, 3);

    await appState.setConnectivity(true);

    expect(appState.syncStatus.pendingChanges, 3);
  });
}
