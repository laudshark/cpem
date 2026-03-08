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
}
